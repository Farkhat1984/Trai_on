from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.database import get_db
from app.api.deps import get_current_admin
from app.models.user import User
from app.models.shop import Shop
from app.models.product import Product, ModerationStatus
from app.models.transaction import Transaction, TransactionStatus
from app.models.generation import Generation
from app.models.moderation import ModerationQueue
from app.models.refund import Refund, RefundStatus
from app.models.settings import PlatformSettings
from app.services.product_service import product_service
from app.services.settings_service import settings_service
from app.core.email import email_service
from app.schemas.admin import (
    AdminSettings,
    AdminDashboard,
    ModerationAction,
    RefundAction,
    RefundResponse
)
from app.schemas.product import ProductResponse
from typing import List
from datetime import datetime

router = APIRouter()


@router.get("/dashboard", response_model=AdminDashboard)
async def get_dashboard(
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db)
):
    """Get admin dashboard statistics"""
    # Count users
    users_result = await db.execute(select(func.count(User.id)))
    total_users = users_result.scalar() or 0

    # Count shops
    shops_result = await db.execute(select(func.count(Shop.id)))
    total_shops = shops_result.scalar() or 0

    # Count products
    products_result = await db.execute(select(func.count(Product.id)))
    total_products = products_result.scalar() or 0

    active_products_result = await db.execute(
        select(func.count(Product.id)).where(Product.is_active == True)
    )
    active_products = active_products_result.scalar() or 0

    # Count generations
    generations_result = await db.execute(select(func.count(Generation.id)))
    total_generations = generations_result.scalar() or 0

    # Calculate revenue
    revenue_result = await db.execute(
        select(func.sum(Transaction.amount)).where(
            Transaction.status == TransactionStatus.COMPLETED
        )
    )
    total_revenue = float(revenue_result.scalar() or 0)

    # Pending moderation
    moderation_result = await db.execute(
        select(func.count(ModerationQueue.id)).where(
            ModerationQueue.reviewed_at.is_(None)
        )
    )
    pending_moderation = moderation_result.scalar() or 0

    # Pending refunds
    refunds_result = await db.execute(
        select(func.count(Refund.id)).where(
            Refund.status == RefundStatus.REQUESTED
        )
    )
    pending_refunds = refunds_result.scalar() or 0

    return AdminDashboard(
        total_users=total_users,
        total_shops=total_shops,
        total_products=total_products,
        active_products=active_products,
        total_generations=total_generations,
        total_revenue=total_revenue,
        pending_moderation=pending_moderation,
        pending_refunds=pending_refunds
    )


@router.get("/settings", response_model=List[AdminSettings])
async def get_settings(
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db)
):
    """Get all platform settings"""
    result = await db.execute(select(PlatformSettings))
    settings = result.scalars().all()
    return [AdminSettings.model_validate(s) for s in settings]


@router.put("/settings/{key}")
async def update_setting(
    key: str,
    setting: AdminSettings,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db)
):
    """Update platform setting"""
    await settings_service.set_setting(db, key, setting.value, setting.description)
    return {"message": "Setting updated successfully"}


@router.get("/moderation/queue", response_model=List[ProductResponse])
async def get_moderation_queue(
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db)
):
    """Get products pending moderation"""
    result = await db.execute(
        select(Product)
        .join(ModerationQueue)
        .where(
            Product.moderation_status == ModerationStatus.PENDING,
            ModerationQueue.reviewed_at.is_(None)
        )
        .order_by(ModerationQueue.submitted_at.asc())
    )
    products = result.scalars().all()
    return [ProductResponse.model_validate(p) for p in products]


@router.post("/moderation/{product_id}/approve")
async def approve_product(
    product_id: int,
    action: ModerationAction,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db)
):
    """Approve product"""
    product = await product_service.approve_product(db, product_id, admin.id, action.notes)
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    # Send email to shop
    from app.services.shop_service import shop_service
    shop = await shop_service.get_by_id(db, product.shop_id)
    if shop:
        await email_service.send_product_approved_notification(
            shop.email,
            shop.shop_name,
            product.name
        )

    return {"message": "Product approved successfully"}


@router.post("/moderation/{product_id}/reject")
async def reject_product(
    product_id: int,
    action: ModerationAction,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db)
):
    """Reject product"""
    if not action.notes:
        raise HTTPException(status_code=400, detail="Notes required for rejection")

    product = await product_service.reject_product(db, product_id, admin.id, action.notes)
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    # Send email to shop
    from app.services.shop_service import shop_service
    shop = await shop_service.get_by_id(db, product.shop_id)
    if shop:
        await email_service.send_product_rejected_notification(
            shop.email,
            shop.shop_name,
            product.name,
            action.notes
        )

    return {"message": "Product rejected successfully"}


@router.get("/refunds", response_model=List[RefundResponse])
async def get_refund_requests(
    status: str = None,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db)
):
    """Get refund requests"""
    query = select(Refund)
    if status:
        query = query.where(Refund.status == status)
    query = query.order_by(Refund.created_at.desc())

    result = await db.execute(query)
    refunds = result.scalars().all()
    return [RefundResponse.model_validate(r) for r in refunds]


@router.post("/refunds/{refund_id}/process")
async def process_refund(
    refund_id: int,
    action: RefundAction,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db)
):
    """Process refund request"""
    result = await db.execute(select(Refund).where(Refund.id == refund_id))
    refund = result.scalar_one_or_none()

    if not refund:
        raise HTTPException(status_code=404, detail="Refund not found")

    if action.action == "approve":
        refund.status = RefundStatus.APPROVED
        refund.admin_notes = action.admin_notes
        refund.processed_at = datetime.utcnow()

        # TODO: Process actual refund via PayPal
        # For MVP, just mark as completed
        refund.status = RefundStatus.COMPLETED

    elif action.action == "reject":
        refund.status = RefundStatus.REJECTED
        refund.admin_notes = action.admin_notes
        refund.processed_at = datetime.utcnow()

    await db.commit()
    return {"message": f"Refund {action.action}d successfully"}
