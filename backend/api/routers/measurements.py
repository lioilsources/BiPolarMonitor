import io
import json
import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, File, Form, HTTPException, Request, UploadFile, BackgroundTasks
from fastapi.responses import Response
from pydantic import BaseModel
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db
from middleware.auth_middleware import get_current_user
from models.measurement import Measurement, MeasurementScore
from models.user import User
from services import storage_service, ml_client
from rate_limit import limiter

router = APIRouter(prefix="/measurements", tags=["measurements"])


class MeasurementSummary(BaseModel):
    id: str
    recorded_at: datetime
    duration_seconds: int
    analyzed: bool
    composite_zscore: float | None
    flags: list[str]
    trend_7d: str | None


class MeasurementDetail(BaseModel):
    id: str
    recorded_at: datetime
    duration_seconds: int
    questions_used: list[str]
    analyzed: bool
    speaker_verified: bool | None
    speaker_similarity: float | None
    notes: str | None
    scores: dict | None
    per_question: dict | None
    energy_profile: dict | None
    flags: list[str]
    baseline: dict | None
    trend_7d: str | None


@router.get("/report")
async def download_report(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Generate and return a PDF wellness report for the current user."""
    from reportlab.lib.pagesizes import A4
    from reportlab.lib.units import cm
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib import colors
    from reportlab.platypus import (
        SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, HRFlowable,
    )
    from reportlab.lib.enums import TA_CENTER, TA_LEFT

    # Fetch all measurements with scores
    result = await db.execute(
        select(Measurement)
        .where(Measurement.user_id == current_user.id)
        .order_by(Measurement.recorded_at)
    )
    measurements = result.scalars().all()

    rows_data = []
    composites = []
    for m in measurements:
        score_result = await db.execute(
            select(MeasurementScore).where(MeasurementScore.measurement_id == m.id)
        )
        score = score_result.scalar_one_or_none()
        composite = score.composite_zscore if score else None
        flags = json.loads(score.flags) if score and score.flags else []
        rows_data.append((m, score, composite, flags))
        if composite is not None:
            composites.append(composite)

    # Date range
    if measurements:
        date_from = measurements[0].recorded_at.strftime("%Y-%m-%d")
        date_to = measurements[-1].recorded_at.strftime("%Y-%m-%d")
        date_range = f"{date_from} – {date_to}"
    else:
        date_range = "No data"

    # Trend direction
    if len(composites) >= 2:
        delta = composites[-1] - composites[0]
        trend_direction = "improving" if delta < -0.2 else ("worsening" if delta > 0.2 else "stable")
    elif composites:
        trend_direction = "stable"
    else:
        trend_direction = "unknown"

    avg_composite = round(sum(composites) / len(composites), 2) if composites else None

    # Build PDF
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(
        buffer,
        pagesize=A4,
        leftMargin=2 * cm,
        rightMargin=2 * cm,
        topMargin=2 * cm,
        bottomMargin=2 * cm,
    )

    styles = getSampleStyleSheet()
    title_style = ParagraphStyle(
        "Title",
        parent=styles["Heading1"],
        alignment=TA_CENTER,
        fontSize=16,
        spaceAfter=6,
    )
    subtitle_style = ParagraphStyle(
        "Subtitle",
        parent=styles["Normal"],
        alignment=TA_CENTER,
        fontSize=11,
        textColor=colors.grey,
        spaceAfter=12,
    )
    section_style = ParagraphStyle(
        "Section",
        parent=styles["Heading2"],
        fontSize=12,
        spaceBefore=14,
        spaceAfter=6,
    )
    body_style = ParagraphStyle(
        "Body",
        parent=styles["Normal"],
        fontSize=10,
        spaceAfter=4,
    )
    disclaimer_style = ParagraphStyle(
        "Disclaimer",
        parent=styles["Normal"],
        fontSize=8,
        textColor=colors.grey,
        alignment=TA_CENTER,
        spaceBefore=20,
    )

    story = []

    # Title
    story.append(Paragraph("BipolarMonitor — Wellness Report", title_style))
    story.append(Paragraph(f"{current_user.display_name}  |  {date_range}", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=0.5, color=colors.lightgrey))
    story.append(Spacer(1, 0.4 * cm))

    # Summary table
    story.append(Paragraph("Measurement Summary", section_style))

    table_header = ["Date", "Duration (s)", "Composite Z-score", "Flags"]
    table_rows = [table_header]
    for m, score, composite, flags in rows_data:
        table_rows.append([
            m.recorded_at.strftime("%Y-%m-%d %H:%M"),
            str(m.duration_seconds),
            f"{composite:.2f}" if composite is not None else "—",
            ", ".join(flags) if flags else "—",
        ])

    if len(table_rows) == 1:
        story.append(Paragraph("No measurements recorded yet.", body_style))
    else:
        col_widths = [4.5 * cm, 3 * cm, 4 * cm, 5.5 * cm]
        t = Table(table_rows, colWidths=col_widths, repeatRows=1)
        t.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#4A90D9")),
            ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
            ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
            ("FONTSIZE", (0, 0), (-1, -1), 9),
            ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F5F5F5")]),
            ("GRID", (0, 0), (-1, -1), 0.3, colors.lightgrey),
            ("ALIGN", (1, 0), (2, -1), "CENTER"),
            ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
            ("TOPPADDING", (0, 0), (-1, -1), 4),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ]))
        story.append(t)

    # Trend section
    story.append(Spacer(1, 0.4 * cm))
    story.append(Paragraph("Trend Analysis", section_style))
    story.append(Paragraph(
        f"Average composite z-score: {avg_composite if avg_composite is not None else 'N/A'}",
        body_style,
    ))
    story.append(Paragraph(
        f"Total measurements: {len(measurements)}",
        body_style,
    ))
    story.append(Paragraph(
        f"Overall trend: {trend_direction.capitalize()}",
        body_style,
    ))

    # Footer disclaimer
    story.append(HRFlowable(width="100%", thickness=0.5, color=colors.lightgrey))
    story.append(Paragraph(
        "This is a wellness tracking report, not a medical diagnosis.",
        disclaimer_style,
    ))

    doc.build(story)
    pdf_bytes = buffer.getvalue()

    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={"Content-Disposition": "attachment; filename=bipolar_report.pdf"},
    )


@router.post("/upload", status_code=202)
@limiter.limit("5/hour")
async def upload_measurement(
    request: Request,
    background_tasks: BackgroundTasks,
    measurement_id: str = Form(...),
    questions_used: str = Form(...),       # JSON: ["Q1B","Q2A","Q3C","Q4A","Q5B"]
    question_timings: str = Form(None),    # JSON: {"Q1":{"start":0,"end":28.5},...}
    recorded_at: str = Form(...),          # ISO datetime
    duration_seconds: int = Form(...),
    notes: str = Form(None),
    video: UploadFile = File(...),
    audio: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    # Validate measurement_id format
    try:
        uuid.UUID(measurement_id)
    except ValueError:
        raise HTTPException(status_code=422, detail="Invalid measurement_id format")

    video_data = await video.read()
    audio_data = await audio.read()

    if len(video_data) > 200 * 1024 * 1024:
        raise HTTPException(status_code=413, detail="Video exceeds 200MB limit")

    video_key = f"{current_user.id}/{measurement_id}/video.mp4"
    audio_key = f"{current_user.id}/{measurement_id}/audio.wav"

    storage_service.upload_file(video_key, video_data, "video/mp4")
    storage_service.upload_file(audio_key, audio_data, "audio/wav")

    m = Measurement(
        id=measurement_id,
        user_id=current_user.id,
        recorded_at=datetime.fromisoformat(recorded_at).replace(tzinfo=None),
        duration_seconds=duration_seconds,
        video_path=video_key,
        audio_path=audio_key,
        questions_used=questions_used,
        question_timings=question_timings,
        uploaded=True,
        notes=notes,
    )
    db.add(m)
    current_user.total_measurements += 1
    await db.commit()

    background_tasks.add_task(
        ml_client.trigger_analysis, measurement_id, video_key, audio_key
    )

    return {"measurement_id": measurement_id, "status": "processing"}


@router.get("/", response_model=list[MeasurementSummary])
async def list_measurements(
    limit: int = 20,
    offset: int = 0,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Measurement)
        .where(Measurement.user_id == current_user.id)
        .order_by(desc(Measurement.recorded_at))
        .limit(limit)
        .offset(offset)
    )
    measurements = result.scalars().all()

    summaries = []
    for m in measurements:
        score_result = await db.execute(
            select(MeasurementScore).where(MeasurementScore.measurement_id == m.id)
        )
        score = score_result.scalar_one_or_none()
        summaries.append(MeasurementSummary(
            id=m.id,
            recorded_at=m.recorded_at,
            duration_seconds=m.duration_seconds,
            analyzed=m.analyzed,
            composite_zscore=score.composite_zscore if score else None,
            flags=json.loads(score.flags) if score and score.flags else [],
            trend_7d=score.trend_7d if score else None,
        ))

    return {"items": summaries}


@router.get("/{measurement_id}", response_model=MeasurementDetail)
async def get_measurement(
    measurement_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Measurement).where(
            Measurement.id == measurement_id,
            Measurement.user_id == current_user.id,
        )
    )
    m = result.scalar_one_or_none()
    if not m:
        raise HTTPException(status_code=404, detail="Measurement not found")

    score_result = await db.execute(
        select(MeasurementScore).where(MeasurementScore.measurement_id == m.id)
    )
    score = score_result.scalar_one_or_none()

    scores_dict = None
    if score:
        scores_dict = {
            "speech_rate_zscore": score.speech_rate_zscore,
            "pause_ratio_zscore": score.pause_ratio_zscore,
            "voice_energy_zscore": score.voice_energy_zscore,
            "f0_range_zscore": score.f0_range_zscore,
            "response_length_zscore": score.response_length_zscore,
            "cohesion_zscore": score.cohesion_zscore,
            "facial_affect_zscore": score.facial_affect_zscore,
            "composite_zscore": score.composite_zscore,
        }

    return MeasurementDetail(
        id=m.id,
        recorded_at=m.recorded_at,
        duration_seconds=m.duration_seconds,
        questions_used=json.loads(m.questions_used),
        analyzed=m.analyzed,
        speaker_verified=m.speaker_verified,
        speaker_similarity=m.speaker_similarity,
        notes=m.notes,
        scores=scores_dict,
        per_question=json.loads(score.per_question) if score and score.per_question else None,
        energy_profile=json.loads(score.energy_profile) if score and score.energy_profile else None,
        flags=json.loads(score.flags) if score and score.flags else [],
        baseline={
            "composite_mean": score.baseline_mean,
            "composite_std": score.baseline_std,
            "deviation_sigma": round((score.composite_zscore or 0), 2),
            "based_on_n": score.baseline_n,
        } if score else None,
        trend_7d=score.trend_7d if score else None,
    )


@router.delete("/{measurement_id}", status_code=204)
async def delete_measurement(
    measurement_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Measurement).where(
            Measurement.id == measurement_id,
            Measurement.user_id == current_user.id,
        )
    )
    m = result.scalar_one_or_none()
    if not m:
        raise HTTPException(status_code=404, detail="Measurement not found")

    if m.video_path:
        storage_service.delete_object(m.video_path)
    if m.audio_path:
        storage_service.delete_object(m.audio_path)

    score_result = await db.execute(
        select(MeasurementScore).where(MeasurementScore.measurement_id == m.id)
    )
    score = score_result.scalar_one_or_none()
    if score:
        await db.delete(score)

    await db.delete(m)
    await db.commit()
