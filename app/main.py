from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.api.v1.endpoints import auth, users, exercises, exercise_definitions, sync

# SQLAlchemy 메타데이터 강제 리로드
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("애플리케이션 시작 중...")
    # 메타데이터 캐시 클리어
    from app.db.session import Base
    from app.db.models import user, refresh_token  # 모든 모델 import
    Base.metadata.clear()
    yield
    # Shutdown
    print("애플리케이션 종료 중...")

app = FastAPI(
    lifespan=lifespan,
    title=settings.project_name,
    openapi_url=f"{settings.api_v1_str}/openapi.json"
) 