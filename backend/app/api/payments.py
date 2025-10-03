from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.api.deps import get_current_user, get_current_shop
from app.models.user import User
from app.models.shop import Shop
from app.services.payment_service import payment_service
from app.schemas.payment import PaymentCreate, PaymentResponse

router = APIRouter()


@router.post("/user/top-up", response_model=PaymentResponse)
async def create_top_up_payment(
    payment_data: PaymentCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Create PayPal payment for user balance top-up"""
    if payment_data.payment_type != "top_up":
        raise HTTPException(status_code=400, detail="Invalid payment type")

    payment = await payment_service.create_top_up_payment(
        db, current_user.id, payment_data.amount
    )
    if not payment:
        raise HTTPException(status_code=400, detail="Failed to create payment")

    return PaymentResponse(
        order_id=payment["order_id"],
        approval_url=payment["approval_url"],
        amount=payment["amount"],
        status="pending"
    )


@router.post("/shop/rent-product", response_model=PaymentResponse)
async def create_rent_payment(
    payment_data: PaymentCreate,
    current_shop: Shop = Depends(get_current_shop),
    db: AsyncSession = Depends(get_db)
):
    """Create PayPal payment for product rent"""
    if payment_data.payment_type != "product_rent":
        raise HTTPException(status_code=400, detail="Invalid payment type")

    product_id = payment_data.extra_data.get("product_id")
    months = payment_data.extra_data.get("months", 1)

    if not product_id:
        raise HTTPException(status_code=400, detail="product_id required in extra_data")

    payment = await payment_service.create_rent_payment(
        db, current_shop.id, product_id, months
    )
    if not payment:
        raise HTTPException(status_code=400, detail="Failed to create payment")

    return PaymentResponse(
        order_id=payment["order_id"],
        approval_url=payment["approval_url"],
        amount=payment["amount"],
        status="pending"
    )


@router.post("/capture/{order_id}")
async def capture_payment(
    order_id: str,
    db: AsyncSession = Depends(get_db)
):
    """Capture PayPal payment after user approval"""
    transaction = await payment_service.capture_payment(db, order_id)
    if not transaction:
        raise HTTPException(status_code=400, detail="Failed to capture payment")

    # Complete product purchase if needed
    from app.models.transaction import TransactionType
    if transaction.type == TransactionType.PRODUCT_PURCHASE:
        await payment_service.complete_product_purchase(db, transaction)

    return {
        "message": "Payment captured successfully",
        "transaction_id": transaction.id,
        "status": transaction.status.value
    }


@router.post("/paypal/webhook")
async def paypal_webhook(
    request: Request,
    db: AsyncSession = Depends(get_db)
):
    """PayPal webhook handler"""
    # TODO: Verify webhook signature
    webhook_data = await request.json()

    event_type = webhook_data.get("event_type")
    resource = webhook_data.get("resource", {})

    # Handle different webhook events
    if event_type == "PAYMENT.CAPTURE.COMPLETED":
        order_id = resource.get("supplementary_data", {}).get("related_ids", {}).get("order_id")
        if order_id:
            await payment_service.capture_payment(db, order_id)

    return {"status": "received"}
