from pydantic import BaseModel, EmailStr
from typing import Optional


class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    user_id: Optional[int] = None
    shop_id: Optional[int] = None
    role: Optional[str] = None


class GoogleAuthRequest(BaseModel):
    code: str
    account_type: str  # "user" or "shop"


class GoogleAuthResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: Optional[dict] = None
    shop: Optional[dict] = None
