import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from database import engine, Base, AsyncSessionLocal
from rate_limit import limiter
from routers import auth, measurements, dialog, user
from routers.push import router as push_router
from tasks.retention import run_retention_loop


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Schema is managed by Alembic (runs before uvicorn in Dockerfile CMD)
    retention_task = asyncio.create_task(run_retention_loop(AsyncSessionLocal))

    yield

    retention_task.cancel()
    await engine.dispose()


app = FastAPI(
    title="BipolarMonitor API",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url=None,
)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://bipolar.ol1n.com"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/v1")
app.include_router(measurements.router, prefix="/api/v1")
app.include_router(dialog.router, prefix="/api/v1")
app.include_router(user.router, prefix="/api/v1")
app.include_router(push_router, prefix="/api/v1")


@app.get("/health")
async def health():
    return {"status": "ok"}
