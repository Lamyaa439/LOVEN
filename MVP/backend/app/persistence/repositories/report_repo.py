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
    
    def list_all(self):
        """Return all non-deleted moderation reports, newest first."""
        return (
            self.model.query
            .filter(self.model.deleted_at.is_(None))
            .order_by(self.model.created_at.desc())
            .all()
        )
    
    def update_status(self, report, status):
        """Update moderation report lifecycle status."""
        report.status = status
        return self.save(report)
    
    def count_open_reports(self):
        return (
            self.model.query
            .filter(self.model.deleted_at.is_(None))
            .filter(self.model.status == "open")
            .count()
        )

report_repo = ReportRepository()
