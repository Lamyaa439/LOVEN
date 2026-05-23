"""
Verification request facade.

Acts as the orchestration layer between:
- API routes
- business logic service layer

Responsibilities:
- Handle exceptions safely
- Convert service results into HTTP-friendly responses
- Keep Flask routes thin and clean
"""

from app.services.verification_request_service import (
    VerificationRequestService,
)


class VerificationRequestFacade:
    """
    Facade for verification request flows.
    """

    @staticmethod
    def create_request(user_id, data):
        """
        Create verification request for authenticated artist.

        Flow:
            Route -> Facade -> Service -> Repository
        """

        try:
            verification_request = (
                VerificationRequestService.create_request(
                    user_id,
                    data,
                )
            )

            return verification_request.to_dict(), 201

        except ValueError as error:
            return {"error": str(error)}, 400

        except Exception:
            return {
                "error": "Failed to create verification request"
            }, 500

    @staticmethod
    def get_all_requests():
        """
        Return all verification requests.
        """

        try:
            requests = (
                VerificationRequestService.get_all_requests()
            )

            return [
                request.to_dict()
                for request in requests
            ], 200

        except Exception:
            return {
                "error": "Failed to fetch verification requests"
            }, 500

    @staticmethod
    def get_request_by_id(request_id):
        """
        Return single verification request by ID.
        """

        try:
            verification_request = (
                VerificationRequestService.get_request_by_id(
                    request_id,
                )
            )

            return verification_request.to_dict(), 200

        except ValueError as error:
            return {"error": str(error)}, 404

        except Exception:
            return {
                "error": "Failed to fetch verification request"
            }, 500

    @staticmethod
    def update_request_status(request_id, status):
        """
        Update verification request status.

        Allowed statuses:
        - pending
        - approved
        - rejected
        """

        try:
            verification_request = (
                VerificationRequestService.update_request_status(
                    request_id,
                    status,
                )
            )

            return verification_request.to_dict(), 200

        except ValueError as error:
            message = str(error)

            if "not found" in message.lower():
                return {"error": message}, 404

            return {"error": message}, 400

        except Exception:
            return {
                "error": "Failed to update verification request"
            }, 500