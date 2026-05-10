import io
from minio import Minio
from minio.error import S3Error
from config import settings

_client: Minio | None = None


def get_minio() -> Minio:
    global _client
    if _client is None:
        _client = Minio(
            settings.minio_endpoint,
            access_key=settings.minio_access_key,
            secret_key=settings.minio_secret_key,
            secure=settings.minio_secure,
            path_style=True,
        )
        if not _client.bucket_exists(settings.minio_bucket):
            _client.make_bucket(settings.minio_bucket)
    return _client


def upload_file(object_name: str, data: bytes, content_type: str) -> str:
    client = get_minio()
    client.put_object(
        settings.minio_bucket,
        object_name,
        io.BytesIO(data),
        length=len(data),
        content_type=content_type,
    )
    return object_name


def get_presigned_url(object_name: str, expires_seconds: int = 3600) -> str:
    from datetime import timedelta
    client = get_minio()
    return client.presigned_get_object(
        settings.minio_bucket,
        object_name,
        expires=timedelta(seconds=expires_seconds),
    )


def delete_object(object_name: str) -> None:
    client = get_minio()
    try:
        client.remove_object(settings.minio_bucket, object_name)
    except S3Error:
        pass
