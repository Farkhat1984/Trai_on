from sqlalchemy import String, Integer, Numeric, DateTime, ForeignKey, Enum, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
import enum
from app.database import Base


class TransactionType(str, enum.Enum):
    TOP_UP = "top_up"  # Пополнение баланса пользователя
    GENERATION = "generation"  # Списание за генерацию
    TRY_ON = "try_on"  # Списание за примерку
    PRODUCT_RENT = "product_rent"  # Оплата аренды товара магазином
    PRODUCT_PURCHASE = "product_purchase"  # Покупка товара пользователем
    REFUND = "refund"  # Возврат средств
    COMMISSION = "commission"  # Комиссия платформы


class TransactionStatus(str, enum.Enum):
    PENDING = "pending"
    COMPLETED = "completed"
    FAILED = "failed"
    REFUNDED = "refunded"


class Transaction(Base):
    __tablename__ = "transactions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int | None] = mapped_column(Integer, ForeignKey("users.id"), nullable=True)
    shop_id: Mapped[int | None] = mapped_column(Integer, ForeignKey("shops.id"), nullable=True)
    type: Mapped[TransactionType] = mapped_column(Enum(TransactionType), nullable=False)
    amount: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    paypal_order_id: Mapped[str | None] = mapped_column(String(255), unique=True, nullable=True)
    paypal_capture_id: Mapped[str | None] = mapped_column(String(255), unique=True, nullable=True)
    status: Mapped[TransactionStatus] = mapped_column(
        Enum(TransactionStatus), default=TransactionStatus.PENDING, nullable=False
    )
    extra_data: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="transactions", foreign_keys=[user_id])
    shop: Mapped["Shop"] = relationship("Shop", back_populates="transactions", foreign_keys=[shop_id])
    refund: Mapped["Refund"] = relationship("Refund", back_populates="transaction", uselist=False)

    def __repr__(self):
        return f"<Transaction(id={self.id}, type={self.type}, amount={self.amount}, status={self.status})>"
