"""
Simple script to test if everything is set up correctly
"""
import os
import sys


def check_env_file():
    """Check if .env file exists"""
    if not os.path.exists('.env'):
        print("❌ .env file not found")
        print("   → Copy .env.example to .env and configure it")
        return False
    print("✅ .env file exists")
    return True


def check_env_variables():
    """Check if required environment variables are set"""
    from app.config import settings

    required = {
        'GOOGLE_CLIENT_ID': settings.GOOGLE_CLIENT_ID,
        'GOOGLE_CLIENT_SECRET': settings.GOOGLE_CLIENT_SECRET,
        'GEMINI_API_KEY': settings.GEMINI_API_KEY,
        'PAYPAL_CLIENT_ID': settings.PAYPAL_CLIENT_ID,
        'PAYPAL_CLIENT_SECRET': settings.PAYPAL_CLIENT_SECRET,
        'SMTP_USER': settings.SMTP_USER,
        'SMTP_PASSWORD': settings.SMTP_PASSWORD,
    }

    all_set = True
    for key, value in required.items():
        if not value or value.startswith('your-'):
            print(f"❌ {key} not configured")
            all_set = False
        else:
            print(f"✅ {key} configured")

    return all_set


def check_database():
    """Check if database exists"""
    if os.path.exists('fashion_platform.db'):
        print("✅ Database exists")
        return True
    else:
        print("⚠️  Database not found")
        print("   → Run: alembic upgrade head")
        return False


def check_uploads_dir():
    """Check if uploads directory exists"""
    if os.path.exists('uploads'):
        print("✅ Uploads directory exists")
        return True
    else:
        print("⚠️  Uploads directory not found")
        print("   → Will be created on startup")
        return True


def main():
    """Run all checks"""
    print("=" * 50)
    print("Fashion AI Platform - Setup Check")
    print("=" * 50)
    print()

    checks = [
        ("Environment file", check_env_file),
        ("Database", check_database),
        ("Uploads directory", check_uploads_dir),
    ]

    results = []
    for name, check_func in checks:
        print(f"\n📋 Checking: {name}")
        results.append(check_func())

    # Check env variables separately (requires .env to exist)
    if results[0]:  # If .env exists
        print(f"\n📋 Checking: Environment variables")
        results.append(check_env_variables())

    print()
    print("=" * 50)
    if all(results):
        print("✅ All checks passed! Ready to run:")
        print("   python run.py")
    else:
        print("⚠️  Some checks failed. Please fix the issues above.")
    print("=" * 50)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\n❌ Error during setup check: {e}")
        print("\nMake sure you've installed all dependencies:")
        print("   pip install -r requirements.txt")
        sys.exit(1)
