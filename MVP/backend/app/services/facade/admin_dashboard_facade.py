from app.services import admin_dashboard_service


class AdminDashboardFacade:

    @staticmethod
    def get_stats():
        return admin_dashboard_service.get_dashboard_stats()