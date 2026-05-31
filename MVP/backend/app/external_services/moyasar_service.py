"""
Moyasar Payment Gateway — External HTTP Client.

Thin wrapper around the Moyasar REST API (https://api.moyasar.com).
This module is strictly an I/O boundary: it sends HTTP requests and
returns parsed Python dicts. It contains ZERO business logic and ZERO
database access.

Auth scheme: HTTP Basic Auth — (secret_key, "").

Usage flow:
    1. Flutter app captures a payment via the Moyasar SDK.
    2. Flutter sends the ``payment_id`` to our backend.
    3. Our backend calls ``MoyasarClient.fetch_payment(payment_id)``
       to verify amount, currency, and status before fulfilling the order.
"""

import logging
import os

import requests

logger = logging.getLogger(__name__)

_MOYASAR_BASE_URL = "https://api.moyasar.com/v1"
_REQUEST_TIMEOUT = 15  # seconds


class MoyasarError(Exception):
    """Raised when the Moyasar API returns a non-2xx response."""

    def __init__(self, status_code: int, detail: str):
        self.status_code = status_code
        self.detail = detail
        super().__init__(f"Moyasar API {status_code}: {detail}")


class MoyasarClient:
    """
    Stateless HTTP client for the Moyasar REST API.

    Instantiate once at app startup and pass it into services that need
    payment verification. The secret key is read from the ``Config`` object
    (sourced from the ``MOYASAR_SECRET_KEY`` env var).

    Example::

        client = MoyasarClient(secret_key=app.config["MOYASAR_SECRET_KEY"])
        payment = client.fetch_payment("pay_abc123")
    """

    def __init__(self, secret_key: str):
        if not secret_key:
            raise ValueError("MOYASAR_SECRET_KEY must be provided.")
        self._auth = (secret_key, "")

    # ------------------------------------------------------------------
    # Core: Fetch / Verify
    # ------------------------------------------------------------------

    def fetch_payment(self, payment_id: str) -> dict:
        """
        Retrieve the full payment object from Moyasar.

        This is the primary method used after the mobile SDK captures a
        payment. The caller (service layer) should verify that the
        returned ``amount``, ``currency``, and ``status`` match the
        expected order values before marking it as paid.

        Args:
            payment_id: The Moyasar payment ID (e.g. ``"pay_abc123"``).

        Returns:
            The raw JSON response as a dict. Key fields:
            ``id``, ``status``, ``amount`` (in halalah), ``currency``,
            ``source.type``, ``created_at``.

        Raises:
            MoyasarError: If the API returns a non-2xx status code.
        """
        url = f"{_MOYASAR_BASE_URL}/payments/{payment_id}"
        return self._get(url)

    # ------------------------------------------------------------------
    # Operations: Refund
    # ------------------------------------------------------------------

    def refund_payment(self, payment_id: str, amount: int | None = None) -> dict:
        """
        Refund a captured payment (full or partial).

        Args:
            payment_id: The Moyasar payment ID.
            amount: Amount to refund **in halalah** (smallest currency unit).
                    Omit for a full refund.

        Returns:
            The updated payment object from Moyasar.

        Raises:
            MoyasarError: If the API returns a non-2xx status code.
        """
        url = f"{_MOYASAR_BASE_URL}/payments/{payment_id}/refund"
        body = {}
        if amount is not None:
            body["amount"] = amount
        return self._post(url, json_body=body)

    # ------------------------------------------------------------------
    # Internal HTTP helpers
    # ------------------------------------------------------------------

    def _get(self, url: str) -> dict:
        """Send an authenticated GET request."""
        try:
            resp = requests.get(url, auth=self._auth, timeout=_REQUEST_TIMEOUT)
        except requests.RequestException as exc:
            logger.error("Moyasar network error (GET %s): %s", url, exc)
            raise MoyasarError(0, f"Network error: {exc}") from exc

        return self._handle_response(resp)

    def _post(self, url: str, json_body: dict | None = None) -> dict:
        """Send an authenticated POST request."""
        try:
            resp = requests.post(
                url, auth=self._auth, json=json_body, timeout=_REQUEST_TIMEOUT
            )
        except requests.RequestException as exc:
            logger.error("Moyasar network error (POST %s): %s", url, exc)
            raise MoyasarError(0, f"Network error: {exc}") from exc

        return self._handle_response(resp)

    @staticmethod
    def _handle_response(resp: requests.Response) -> dict:
        """Parse the response and raise on non-2xx status codes."""
        if resp.ok:
            return resp.json()

        try:
            detail = resp.json().get("message", resp.text)
        except ValueError:
            detail = resp.text

        logger.warning(
            "Moyasar API error %d: %s", resp.status_code, detail
        )
        raise MoyasarError(resp.status_code, detail)
