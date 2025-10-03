from google.oauth2 import id_token
from google.auth.transport import requests
from google_auth_oauthlib.flow import Flow
from app.config import settings
import httpx
from typing import Optional, Dict


class GoogleAuth:
    """Google OAuth authentication handler"""

    def __init__(self):
        self.client_id = settings.GOOGLE_CLIENT_ID
        self.client_secret = settings.GOOGLE_CLIENT_SECRET
        self.redirect_uri = settings.GOOGLE_REDIRECT_URI

    def get_authorization_url(self) -> str:
        """Get Google OAuth authorization URL"""
        flow = Flow.from_client_config(
            {
                "web": {
                    "client_id": self.client_id,
                    "client_secret": self.client_secret,
                    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
                    "token_uri": "https://oauth2.googleapis.com/token",
                    "redirect_uris": [self.redirect_uri],
                }
            },
            scopes=[
                "openid",
                "https://www.googleapis.com/auth/userinfo.email",
                "https://www.googleapis.com/auth/userinfo.profile",
            ],
        )
        flow.redirect_uri = self.redirect_uri
        authorization_url, state = flow.authorization_url(
            access_type="offline", include_granted_scopes="true", prompt="consent"
        )
        return authorization_url

    async def verify_oauth_code(self, code: str) -> Optional[Dict]:
        """Exchange authorization code for user info"""
        try:
            flow = Flow.from_client_config(
                {
                    "web": {
                        "client_id": self.client_id,
                        "client_secret": self.client_secret,
                        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
                        "token_uri": "https://oauth2.googleapis.com/token",
                        "redirect_uris": [self.redirect_uri],
                    }
                },
                scopes=[
                    "openid",
                    "https://www.googleapis.com/auth/userinfo.email",
                    "https://www.googleapis.com/auth/userinfo.profile",
                ],
            )
            flow.redirect_uri = self.redirect_uri
            flow.fetch_token(code=code)

            credentials = flow.credentials

            # Get user info
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    "https://www.googleapis.com/oauth2/v2/userinfo",
                    headers={"Authorization": f"Bearer {credentials.token}"},
                )
                user_info = response.json()

            return {
                "google_id": user_info.get("id"),
                "email": user_info.get("email"),
                "name": user_info.get("name"),
                "avatar_url": user_info.get("picture"),
            }
        except Exception as e:
            print(f"Google OAuth error: {e}")
            return None

    def verify_id_token(self, token: str) -> Optional[Dict]:
        """Verify Google ID token (for mobile apps)"""
        try:
            idinfo = id_token.verify_oauth2_token(token, requests.Request(), self.client_id)
            return {
                "google_id": idinfo.get("sub"),
                "email": idinfo.get("email"),
                "name": idinfo.get("name"),
                "avatar_url": idinfo.get("picture"),
            }
        except Exception as e:
            print(f"Token verification error: {e}")
            return None


google_auth = GoogleAuth()
