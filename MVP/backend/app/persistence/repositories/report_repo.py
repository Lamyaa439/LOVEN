"""
Report repository.

Handles ORM persistence for moderation reports.
"""

from app.models.report import Report
from app.persistence.repository import SQLAlchemyRepository


class ReportRepository(SQLAlchemyRepository):
    def __init__(self):
        super().__init__(Report)

    def create_report(
        self,
        reporter_id,
        target_artwork_id,
        reason,
        details=None,
        status="open",
    ):
        """Create and persist a moderation report."""
        report = Report(
            reporter_id=reporter_id,
            target_artwork_id=target_artwork_id,
            reason=reason,
            details=details,
            status=status,
        )
        return self.save(report)


report_repo = ReportRepository()
