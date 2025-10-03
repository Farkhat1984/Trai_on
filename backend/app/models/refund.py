from sqlalchemy import String, Integer, DateTime, ForeignKey, Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
import enum
from app.database import Base


class RefundStatus(str, enum.Enum):
    REQUESTED = "requested"
    APPROVED = "approved"
    REJECTED = "rejected"
    COMPLETED = "completed"


class Refund(Base):
    __tablename__ = "refunds"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    transaction_id: Mapped[int] = mapped_column(Integer, ForeignKey("transactions.id"), unique=True, nullable=False)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"), nullable=False)
    reason: Mapped[str] = mapped_column(String(1000), nullable=False)
    status: Mapped[RefundStatus] = mapped_column(
        Enum(RefundStatus), default=RefundStatus.REQUESTED, nullable=False
    )
    admin_notes: Mapped[str | None] = mapped_column(String(1000), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)
    processed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    # Relationships
    transaction: Mapped["Transaction"] = relationship("Transaction", back_populates="refund")
    user: Mapped["User"] = relationship("User", back_populates="refunds")

    def __repr__(self):
        return f"<Refund(id={self.id}, transaction_id={self.transaction_id}, status={self.status})>"
