from app.services.report_service import report_service

# =========================================================
# Report Facade
# =========================================================
# The facade keeps API routes lightweight while preparing
# the reporting flow for future moderation integrations.
#
# Examples:
# - admin moderation queues
# - automated flagging systems
# - notification workflows
# =========================================================


class ReportFacade:

    @staticmethod
    def create_report(data):
        return report_service.submit_report(data)

    @staticmethod
    def get_all_reports():
        return report_service.get_all_reports()

    @staticmethod
    def update_report_status(report_id, status):
        return report_service.update_report_status(
            report_id,
            status,
        )