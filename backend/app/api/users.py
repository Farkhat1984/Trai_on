from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.services.user_service import user_service
from app.schemas.user import UserResponse, UserUpdate, UserBalance
from app.schemas.transaction import TransactionResponse
from app.schemas.generation import GenerationResponse
from typing import List

router = APIRouter()


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    current_user: User = Depends(get_current_user)
):
    """Get current user information"""
    return UserResponse.model_validate(current_user)


@router.put("/me", response_model=UserResponse)
async def update_current_user(
    user_data: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Update current user"""
    updated_user = await user_service.update(db, current_user.id, user_data)
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")
    return UserResponse.model_validate(updated_user)


@router.get("/me/balance", response_model=UserBalance)
async def get_user_balance(
    current_user: User = Depends(get_current_user)
):
    """Get user balance and free limits"""
    return UserBalance(
        balance=float(current_user.balance),
        free_generations_left=current_user.free_generations_left,
        free_try_ons_left=current_user.free_try_ons_left
    )


@router.get("/me/transactions", response_model=List[TransactionResponse])
async def get_user_transactions(
    skip: int = 0,
    limit: int = 50,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user transaction history"""
    transactions = await user_service.get_transactions(db, current_user.id, skip, limit)
    return [TransactionResponse.model_validate(t) for t in transactions]


@router.get("/me/history", response_model=List[GenerationResponse])
async def get_user_generation_history(
    skip: int = 0,
    limit: int = 50,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user generation/try-on history"""
    generations = await user_service.get_generations(db, current_user.id, skip, limit)
    return [GenerationResponse.model_validate(g) for g in generations]
