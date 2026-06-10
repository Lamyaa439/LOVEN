from app.services import report_service


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