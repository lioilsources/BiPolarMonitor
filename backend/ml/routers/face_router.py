"""Face enrollment and verification endpoints on the ML service."""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from pipeline.face_embedder import (
    extract_face_embedding,
    average_face_embeddings,
    verify_face,
    extract_frame,
)

router = APIRouter(prefix="/ml", tags=["face"])


class FaceEnrollRequest(BaseModel):
    user_id: str
    image_paths: list[str]  # Paths on shared /tmp volume


class FaceEnrollResponse(BaseModel):
    embedding: list[float]
    enrolled_from: int  # Number of frames that yielded a valid face


class FaceVerifyRequest(BaseModel):
    video_path: str
    stored_embedding: list[float]


class FaceVerifyResponse(BaseModel):
    verified: bool | None
    similarity: float | None


@router.post("/face-enroll", response_model=FaceEnrollResponse)
async def face_enroll(body: FaceEnrollRequest):
    """
    Extract face embeddings from a list of image paths, average the valid ones,
    and return the normalized enrollment embedding.
    """
    if not body.image_paths:
        raise HTTPException(status_code=422, detail="Need at least one image path")

    valid_embeddings = []
    for path in body.image_paths:
        emb = extract_face_embedding(path)
        if emb is not None:
            valid_embeddings.append(emb)

    if not valid_embeddings:
        raise HTTPException(
            status_code=422,
            detail="No valid faces found in the provided images",
        )

    if len(valid_embeddings) == 1:
        averaged = valid_embeddings[0]
    else:
        averaged = average_face_embeddings(valid_embeddings)

    return FaceEnrollResponse(
        embedding=averaged,
        enrolled_from=len(valid_embeddings),
    )


@router.post("/face-verify", response_model=FaceVerifyResponse)
async def face_verify(body: FaceVerifyRequest):
    """
    Extract a frame at second 2.0 from the given video and verify the face
    against the stored enrollment embedding.
    """
    frame_path = extract_frame(body.video_path, second=2.0)
    if frame_path is None:
        return FaceVerifyResponse(verified=None, similarity=None)

    result = verify_face(frame_path, body.stored_embedding)
    return FaceVerifyResponse(
        verified=result["verified"],
        similarity=result["similarity"],
    )
