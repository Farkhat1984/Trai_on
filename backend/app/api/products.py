from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.api.deps import get_current_shop, get_current_user_optional
from app.models.shop import Shop
from app.services.product_service import product_service
from app.services.payment_service import payment_service
from app.schemas.product import ProductCreate, ProductResponse, ProductUpdate, ProductList
from app.schemas.payment import PaymentResponse

router = APIRouter()


@router.get("/", response_model=ProductList)
async def get_products(
    skip: int = 0,
    limit: int = 50,
    search: str = None,
    db: AsyncSession = Depends(get_db)
):
    """Get active approved products"""
    products, total = await product_service.get_active_products(db, skip, limit, search)
    return ProductList(
        products=[ProductResponse.model_validate(p) for p in products],
        total=total,
        page=skip // limit + 1,
        page_size=limit
    )


@router.get("/{product_id}", response_model=ProductResponse)
async def get_product(
    product_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Get product by ID"""
    product = await product_service.get_by_id(db, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    # Increment views
    await product_service.increment_views(db, product_id)

    return ProductResponse.model_validate(product)


@router.post("/", response_model=ProductResponse)
async def create_product(
    product_data: ProductCreate,
    current_shop: Shop = Depends(get_current_shop),
    db: AsyncSession = Depends(get_db)
):
    """Create new product (shop only)"""
    product = await product_service.create(db, current_shop.id, product_data)
    return ProductResponse.model_validate(product)


@router.put("/{product_id}", response_model=ProductResponse)
async def update_product(
    product_id: int,
    product_data: ProductUpdate,
    current_shop: Shop = Depends(get_current_shop),
    db: AsyncSession = Depends(get_db)
):
    """Update product (shop only)"""
    product = await product_service.get_by_id(db, product_id)
    if not product or product.shop_id != current_shop.id:
        raise HTTPException(status_code=404, detail="Product not found")

    updated_product = await product_service.update(db, product_id, product_data)
    return ProductResponse.model_validate(updated_product)


@router.delete("/{product_id}")
async def delete_product(
    product_id: int,
    current_shop: Shop = Depends(get_current_shop),
    db: AsyncSession = Depends(get_db)
):
    """Delete product (shop only)"""
    product = await product_service.get_by_id(db, product_id)
    if not product or product.shop_id != current_shop.id:
        raise HTTPException(status_code=404, detail="Product not found")

    await product_service.delete(db, product_id)
    return {"message": "Product deleted successfully"}


@router.post("/{product_id}/purchase", response_model=PaymentResponse)
async def purchase_product(
    product_id: int,
    current_user = Depends(get_current_user_optional),
    db: AsyncSession = Depends(get_db)
):
    """Purchase product (user)"""
    from app.api.deps import get_current_user
    if not current_user:
        raise HTTPException(status_code=401, detail="Authentication required")

    payment = await payment_service.process_product_purchase(db, current_user.id, product_id)
    if not payment:
        raise HTTPException(status_code=400, detail="Failed to create payment")

    return PaymentResponse(
        order_id=payment["order_id"],
        approval_url=payment["approval_url"],
        amount=payment["amount"],
        status="pending"
    )
