from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.core.google_auth import google_auth
from app.core.security import create_access_token, create_refresh_token, verify_token
from app.services.user_service import user_service
from app.services.shop_service import shop_service
from app.schemas.auth import GoogleAuthRequest, GoogleAuthResponse, Token
from app.schemas.user import UserCreate, UserResponse
from app.schemas.shop import ShopCreate, ShopResponse

router = APIRouter()


@router.post("/google/login", response_model=GoogleAuthResponse)
async def google_login(
    request: GoogleAuthRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Authenticate user/shop via Google OAuth
    account_type: 'user' or 'shop'
    """
    # Verify Google OAuth code
    user_info = await google_auth.verify_oauth_code(request.code)
    if not user_info:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Google authentication code"
        )

    if request.account_type == "user":
        # Check if user exists
        user = await user_service.get_by_google_id(db, user_info["google_id"])
        if not user:
            # Create new user
            user_data = UserCreate(
                google_id=user_info["google_id"],
                email=user_info["email"],
                name=user_info["name"],
                avatar_url=user_info.get("avatar_url")
            )
            user = await user_service.create(db, user_data)

        # Create tokens
        access_token = create_access_token({"user_id": user.id, "role": user.role.value})
        refresh_token = create_refresh_token({"user_id": user.id, "role": user.role.value})

        return GoogleAuthResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            user=UserResponse.model_validate(user).model_dump()
        )

    elif request.account_type == "shop":
        # Check if shop exists
        shop = await shop_service.get_by_google_id(db, user_info["google_id"])
        if not shop:
            # Create new shop
            shop_data = ShopCreate(
                google_id=user_info["google_id"],
                email=user_info["email"],
                shop_name=user_info["name"],  # Can be updated later
                owner_name=user_info["name"],
                avatar_url=user_info.get("avatar_url")
            )
            shop = await shop_service.create(db, shop_data)

        # Create tokens
        access_token = create_access_token({"shop_id": shop.id})
        refresh_token = create_refresh_token({"shop_id": shop.id})

        return GoogleAuthResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            shop=ShopResponse.model_validate(shop).model_dump()
        )

    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid account_type. Must be 'user' or 'shop'"
        )


@router.post("/refresh", response_model=Token)
async def refresh_access_token(
    refresh_token: str,
    db: AsyncSession = Depends(get_db)
):
    """Refresh access token using refresh token"""
    payload = verify_token(refresh_token, "refresh")
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token"
        )

    # Create new access token with same payload
    new_access_token = create_access_token({
        k: v for k, v in payload.items() if k not in ["exp", "type"]
    })

    return Token(
        access_token=new_access_token,
        refresh_token=refresh_token
    )


@router.get("/google/url")
async def get_google_auth_url():
    """Get Google OAuth authorization URL"""
    url = google_auth.get_authorization_url()
    return {"authorization_url": url}


@router.get("/google/callback")
async def google_callback(
    code: str,
    state: str = None,
    account_type: str = "user",
    db: AsyncSession = Depends(get_db)
):
    """
    Google OAuth callback endpoint (GET)
    This is called by Google after user authorizes
    account_type can be passed as query param: ?account_type=user or ?account_type=shop
    """
    # Verify Google OAuth code
    user_info = await google_auth.verify_oauth_code(code)
    if not user_info:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Google authentication code"
        )

    if account_type == "user":
        # Check if user exists
        user = await user_service.get_by_google_id(db, user_info["google_id"])
        if not user:
            # Create new user
            user_data = UserCreate(
                google_id=user_info["google_id"],
                email=user_info["email"],
                name=user_info["name"],
                avatar_url=user_info.get("avatar_url")
            )
            user = await user_service.create(db, user_data)

        # Create tokens
        access_token = create_access_token({"user_id": user.id, "role": user.role.value})
        refresh_token = create_refresh_token({"user_id": user.id, "role": user.role.value})

        return GoogleAuthResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            user=UserResponse.model_validate(user).model_dump()
        )

    elif account_type == "shop":
        # Check if shop exists
        shop = await shop_service.get_by_google_id(db, user_info["google_id"])
        if not shop:
            # Create new shop
            shop_data = ShopCreate(
                google_id=user_info["google_id"],
                email=user_info["email"],
                shop_name=user_info["name"],  # Can be updated later
                owner_name=user_info["name"],
                avatar_url=user_info.get("avatar_url")
            )
            shop = await shop_service.create(db, shop_data)

        # Create tokens
        access_token = create_access_token({"shop_id": shop.id})
        refresh_token = create_refresh_token({"shop_id": shop.id})

        return GoogleAuthResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            shop=ShopResponse.model_validate(shop).model_dump()
        )

    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid account_type. Must be 'user' or 'shop'"
        )
