from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.services.generation_service import generation_service
from app.schemas.generation import GenerationRequest, TryOnRequest, GenerationResponse

router = APIRouter()


@router.post("/generate", response_model=GenerationResponse)
async def generate_fashion(
    request: GenerationRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Generate fashion based on prompt"""
    generation = await generation_service.generate_fashion(
        db,
        current_user.id,
        request.prompt,
        request.user_image_url
    )

    if not generation:
        raise HTTPException(
            status_code=400,
            detail="Failed to generate fashion. Check balance or try again."
        )

    return GenerationResponse.model_validate(generation)


@router.post("/try-on", response_model=GenerationResponse)
async def try_on_product(
    request: TryOnRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Try on product on user image"""
    generation = await generation_service.try_on_product(
        db,
        current_user.id,
        request.product_id,
        request.user_image_url
    )

    if not generation:
        raise HTTPException(
            status_code=400,
            detail="Failed to generate try-on. Check balance or try again."
        )

    return GenerationResponse.model_validate(generation)
