from app.persistence.repositories.report_repo import report_repo


# =========================================================
# Report Service
# =========================================================
# Centralizes validation rules for artwork reporting.
#
# The service layer ensures moderation-related data remains
# consistent before storage.
# =========================================================


def submit_report(data):

    reporter_id = data.get("reporter_id")
    target_artwork_id = data.get(
        "target_artwork_id"
    )
    reason = data.get("reason")
    details = data.get("details")

    # Reports must always be tied to an authenticated user
    # so abusive or anonymous moderation actions are avoided.
    if not reporter_id:
        return {"error": "reporter_id is required"}, 400

    # Moderation workflows depend on identifying the exact
    # artwork that triggered the report.
    if not target_artwork_id:
        return {
            "error": "target_artwork_id is required"
        }, 400

    # A report without a reason provides no actionable
    # context for moderators reviewing the case.
    if not reason:
        return {"error": "reason is required"}, 400

    report = report_repo.create_report(
        reporter_id=reporter_id,
        target_artwork_id=target_artwork_id,
        reason=reason,
        details=details,
    )

    return {
        "message": "Report submitted successfully",
        "report": report.to_dict(),
    }, 201

def get_all_reports():
    reports = report_repo.list_all()

    return {
        "reports": [report.to_dict() for report in reports]
    }, 200

def update_report_status(report_id, status):
    allowed_statuses = {"open", "resolved", "dismissed"}

    if not status:
        return {"error": "status is required"}, 400

    if status not in allowed_statuses:
        return {
            "error": "status must be one of: open, resolved, dismissed"
        }, 400

    report = report_repo.get(report_id)

    if not report:
        return {"error": "Report not found"}, 404

    updated_report = report_repo.update_status(
        report,
        status,
    )

    return {
        "message": "Report status updated successfully",
        "report": updated_report.to_dict(),
    }, 200