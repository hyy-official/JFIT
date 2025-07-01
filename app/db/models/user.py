from datetime import date, datetime
from typing import Optional, List, TYPE_CHECKING
from sqlalchemy import String, Integer, Float, Date, DateTime, Boolean, Text, Enum as SqlEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship
import enum

from app.db.session import Base

if TYPE_CHECKING:
    from app.db.models.user_workout_routine import UserWorkoutRoutine
    from app.db.models.refresh_token import RefreshToken

class Gender(str, enum.Enum):
    MALE = "MALE"
    FEMALE = "FEMALE"
    OTHER = "OTHER"


class ActivityLevel(str, enum.Enum):
    SEDENTARY = "SEDENTARY"
    LIGHTLY_ACTIVE = "LIGHTLY_ACTIVE"
    MODERATELY_ACTIVE = "MODERATELY_ACTIVE"
    VERY_ACTIVE = "VERY_ACTIVE"
    EXTRA_ACTIVE = "EXTRA_ACTIVE"


class User(Base):
    __tablename__ = "users"

    # 데이터베이스 스키마와 정확히 일치하는 필드들
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)  # serial, auto-increment
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    username: Mapped[str] = mapped_column(String(50), nullable=False, index=True)  # NOT NULL
    full_name: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)  # nullable
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)  # NOT NULL
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)  # NOT NULL
    is_verified: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)  # NOT NULL
    
    # 개인 정보 (모두 nullable)
    date_of_birth: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    gender: Mapped[Optional[Gender]] = mapped_column(SqlEnum(Gender), nullable=True)
    height_cm: Mapped[Optional[float]] = mapped_column(Float, nullable=True, comment="키 (cm)")
    weight_kg: Mapped[Optional[float]] = mapped_column(Float, nullable=True, comment="체중 (kg)")
    activity_level: Mapped[Optional[ActivityLevel]] = mapped_column(SqlEnum(ActivityLevel), nullable=True)
    
    # 목표 정보 (모두 nullable)
    target_weight_kg: Mapped[Optional[float]] = mapped_column(Float, nullable=True, comment="목표 체중 (kg)")
    daily_calorie_goal: Mapped[Optional[int]] = mapped_column(Integer, nullable=True, comment="일일 칼로리 목표")
    
    # 메타 정보
    bio: Mapped[Optional[str]] = mapped_column(Text, nullable=True, comment="자기소개")
    created_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, default=datetime.utcnow)  # NOT NULL
    updated_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)  # nullable
    
    # Relationships
    workout_routines: Mapped[List["UserWorkoutRoutine"]] = relationship(
        "UserWorkoutRoutine", 
        back_populates="user"
    )
    refresh_tokens: Mapped[List["RefreshToken"]] = relationship(
        "RefreshToken",
        back_populates="user",
        cascade="all, delete-orphan"
    )