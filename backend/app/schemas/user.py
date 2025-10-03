from pydantic import BaseModel, EmailStr, Field
from datetime import datetime
from typing import Optional


class UserBase(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=255)


class UserCreate(UserBase):
    google_id: str
    avatar_url: Optional[str] = None


class UserUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)


class UserBalance(BaseModel):
    balance: float
    free_generations_left: int
    free_try_ons_left: int


class UserResponse(UserBase):
    id: int
    avatar_url: Optional[str] = None
    balance: float
    free_generations_left: int
    free_try_ons_left: int
    role: str
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
