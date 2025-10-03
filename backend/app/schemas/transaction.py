from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, Dict, List


class TransactionBase(BaseModel):
    type: str
    amount: float = Field(..., gt=0)


class TransactionCreate(TransactionBase):
    user_id: Optional[int] = None
    shop_id: Optional[int] = None
    extra_data: Optional[Dict] = None


class TransactionResponse(TransactionBase):
    id: int
    user_id: Optional[int] = None
    shop_id: Optional[int] = None
    paypal_order_id: Optional[str] = None
    paypal_capture_id: Optional[str] = None
    status: str
    extra_data: Optional[Dict] = None
    created_at: datetime

    model_config = {"from_attributes": True}


class TransactionList(BaseModel):
    transactions: List[TransactionResponse]
    total: int
    page: int
    page_size: int
