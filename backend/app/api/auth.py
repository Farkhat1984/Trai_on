from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import HTMLResponse, RedirectResponse
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
async def get_google_auth_url(account_type: str = "shop"):
    """Get Google OAuth authorization URL"""
    url = google_auth.get_authorization_url(account_type)
    return {"authorization_url": url}


@router.post("/test-token")
async def create_test_token(
    account_type: str = "user",
    db: AsyncSession = Depends(get_db)
):
    """
    Create test token for development (NO AUTHENTICATION)
    WARNING: This endpoint should be disabled in production!
    """
    if account_type == "user":
        # Get or create test user
        user = await user_service.get_by_email(db, "test@example.com")
        if not user:
            user_data = UserCreate(
                google_id="test_user",
                email="test@example.com",
                name="Test User",
            )
            user = await user_service.create(db, user_data)

        access_token = create_access_token({"user_id": user.id, "role": user.role.value})
        refresh_token = create_refresh_token({"user_id": user.id, "role": user.role.value})

        return GoogleAuthResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            user=UserResponse.model_validate(user).model_dump()
        )

    elif account_type == "shop":
        # Get or create test shop
        shop = await shop_service.get_by_email(db, "testshop@example.com")
        if not shop:
            shop_data = ShopCreate(
                google_id="test_shop",
                email="testshop@example.com",
                shop_name="Test Shop",
                owner_name="Test Owner"
            )
            shop = await shop_service.create(db, shop_data)

        access_token = create_access_token({"shop_id": shop.id})
        refresh_token = create_refresh_token({"shop_id": shop.id})

        return GoogleAuthResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            shop=ShopResponse.model_validate(shop).model_dump()
        )

    elif account_type == "admin":
        # Get or create test admin
        user = await user_service.get_by_email(db, "admin@example.com")
        if not user:
            user_data = UserCreate(
                google_id="test_admin",
                email="admin@example.com",
                name="Test Admin",
            )
            user = await user_service.create(db, user_data)
            # Set as admin
            user.role = "admin"
            await db.commit()
            await db.refresh(user)

        access_token = create_access_token({"user_id": user.id, "role": "admin"})
        refresh_token = create_refresh_token({"user_id": user.id, "role": "admin"})

        return GoogleAuthResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            user=UserResponse.model_validate(user).model_dump()
        )

    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid account_type. Must be 'user', 'shop', or 'admin'"
        )


@router.get("/google/callback", response_class=HTMLResponse)
async def google_callback(
    code: str,
    state: str = None,
    db: AsyncSession = Depends(get_db)
):
    """
    Google OAuth callback endpoint (GET)
    This is called by Google after user authorizes
    Returns HTML page that saves token and redirects
    """
    import json as json_lib

    try:
        # Verify Google OAuth code
        user_info = await google_auth.verify_oauth_code(code)
        if not user_info:
            return HTMLResponse(content=f"""
                <html>
                <body>
                    <h1>Ошибка авторизации</h1>
                    <p>Неверный код авторизации Google</p>
                    <a href="/index.html">Вернуться на главную</a>
                </body>
                </html>
            """, status_code=401)

        # First, check if user exists (might be admin)
        user = await user_service.get_by_google_id(db, user_info["google_id"])
        if user:
            # User exists - return user account (could be admin or regular user)
            role_str = user.role.value if hasattr(user.role, 'value') else str(user.role)
            access_token = create_access_token({"user_id": user.id, "role": role_str})
            account_type = 'admin' if role_str == 'admin' else 'user'
        else:
            # Check if shop exists
            shop = await shop_service.get_by_google_id(db, user_info["google_id"])
            if shop:
                # Shop exists
                access_token = create_access_token({"shop_id": shop.id})
                account_type = 'shop'
            else:
                # Create new shop by default
                shop_data = ShopCreate(
                    google_id=user_info["google_id"],
                    email=user_info["email"],
                    shop_name=user_info["name"],
                    owner_name=user_info["name"],
                    avatar_url=user_info.get("avatar_url")
                )
                shop = await shop_service.create(db, shop_data)
                access_token = create_access_token({"shop_id": shop.id})
                account_type = 'shop'

        # Return HTML that saves token and redirects
        return HTMLResponse(content=f"""
            <!DOCTYPE html>
            <html>
            <head>
                <title>Авторизация...</title>
                <style>
                    body {{
                        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        min-height: 100vh;
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        margin: 0;
                    }}
                    .loader {{
                        text-align: center;
                        color: white;
                    }}
                    .spinner {{
                        border: 4px solid rgba(255,255,255,0.3);
                        border-top: 4px solid white;
                        border-radius: 50%;
                        width: 50px;
                        height: 50px;
                        animation: spin 1s linear infinite;
                        margin: 0 auto 20px;
                    }}
                    @keyframes spin {{
                        0% {{ transform: rotate(0deg); }}
                        100% {{ transform: rotate(360deg); }}
                    }}
                </style>
            </head>
            <body>
                <div class="loader">
                    <div class="spinner"></div>
                    <p>Вход выполнен успешно! Перенаправление...</p>
                </div>
                <script>
                    localStorage.setItem('token', '{access_token}');
                    localStorage.setItem('accountType', '{account_type}');
                    console.log('Token saved:', '{access_token}');
                    console.log('Account type:', '{account_type}');
                    setTimeout(function() {{
                        window.location.href = '/index.html';
                    }}, 1000);
                </script>
            </body>
            </html>
        """)

    except Exception as e:
        import traceback
        error_details = traceback.format_exc()
        print(f"Error in google_callback: {error_details}")

        return HTMLResponse(content=f"""
            <html>
            <body style="font-family: monospace; padding: 20px;">
                <h1>Ошибка авторизации</h1>
                <p><strong>Сообщение:</strong> {str(e)}</p>
                <pre style="background: #f5f5f5; padding: 10px; overflow: auto;">{error_details}</pre>
                <a href="/index.html">Вернуться на главную</a>
            </body>
            </html>
        """, status_code=500)
