"""Speaker enrollment and verification endpoints on the ML service."""
import os
import tempfile
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from pipeline.speaker import extract_speaker_embedding, average_embeddings, verify_speaker

router = APIRouter(prefix="/ml", tags=["speaker"])


class EnrollRequest(BaseModel):
    audio_paths: list[str]  # MinIO object keys or local temp paths


class EnrollResponse(BaseModel):
    embedding: list[float]


class VerifyRequest(BaseModel):
    audio_path: str
    stored_embedding: list[float]


class VerifyResponse(BaseModel):
    similarity: float
    verified: bool


@router.post("/speaker-enroll", response_model=EnrollResponse)
async def enroll(body: EnrollRequest):
    """Extract and average speaker embeddings from enrollment audio files."""
    if not body.audio_paths:
        raise HTTPException(status_code=422, detail="Need at least one audio path")

    embeddings = []
    for path in body.audio_paths:
        # If path is a MinIO key, download first
        local_path = _resolve_path(path)
        emb = extract_speaker_embedding(local_path)
        embeddings.append(emb)

    averaged = average_embeddings(embeddings) if len(embeddings) > 1 else embeddings[0]
    return EnrollResponse(embedding=averaged)


@router.post("/speaker-verify", response_model=VerifyResponse)
async def verify(body: VerifyRequest):
    """Verify a speaker against stored enrollment embedding."""
    local_path = _resolve_path(body.audio_path)
    result = verify_speaker(local_path, body.stored_embedding)
    return VerifyResponse(similarity=result["similarity"], verified=result["verified"])


@router.post("/speaker-embedding")
async def get_embedding(body: dict):
    """Get embedding for a single audio (used by Flutter app verification flow)."""
    path = body.get("audio_path", "")
    local_path = _resolve_path(path)
    emb = extract_speaker_embedding(local_path)
    return {"embedding": emb}


def _resolve_path(path: str) -> str:
    """If path looks like a MinIO key (no leading /), download to temp dir."""
    if os.path.exists(path):
        return path

    # Download from MinIO
    try:
        from minio import Minio
        endpoint = os.environ["MINIO_ENDPOINT"]
        bucket = os.environ.get("MINIO_BUCKET", "bipolar-media")
        client = Minio(endpoint, access_key=os.environ["MINIO_ACCESS_KEY"], secret_key=os.environ["MINIO_SECRET_KEY"], secure=False)
        tmp = tempfile.mktemp(suffix=".wav")
        client.fget_object(bucket, path, tmp)
        return tmp
    except Exception as e:
        raise HTTPException(status_code=404, detail=f"Cannot resolve audio path: {e}")
