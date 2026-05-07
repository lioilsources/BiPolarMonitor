from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    jwt_secret: str
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 15
    refresh_token_expire_days: int = 30

    database_url: str
    minio_endpoint: str
    minio_access_key: str
    minio_secret_key: str
    minio_bucket: str = "bipolar-media"
    minio_secure: bool = False

    ml_service_url: str = "http://ml:8001"
    media_retention_days: int = 30

    class Config:
        env_file = ".env"


settings = Settings()
