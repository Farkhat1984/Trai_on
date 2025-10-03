from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, Dict, List


class ProductBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = Field(None, max_length=2000)
    price: float = Field(..., gt=0)
    characteristics: Optional[Dict] = None


class ProductCreate(ProductBase):
    images: Optional[List[str]] = None


class ProductUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = Field(None, max_length=2000)
    price: Optional[float] = Field(None, gt=0)
    characteristics: Optional[Dict] = None
    images: Optional[List[str]] = None


class ProductResponse(ProductBase):
    id: int
    shop_id: int
    images: Optional[List[str]] = None
    rent_expires_at: Optional[datetime] = None
    is_active: bool
    moderation_status: str
    views_count: int
    try_ons_count: int
    purchases_count: int
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class ProductList(BaseModel):
    products: List[ProductResponse]
    total: int
    page: int
    page_size: int
