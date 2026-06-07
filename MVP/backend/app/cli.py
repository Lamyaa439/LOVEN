"""
Flask CLI commands for scheduled notification jobs.

Register via :func:`register_cli_commands` inside ``create_app()``.
"""

import json

import click
from flask.cli import with_appcontext

from app.jobs.scheduled_notification_jobs import (
    run_artist_order_reminders,
    run_cart_inactivity_reminders,
)


@click.group(name="notifications")
def notifications_cli():
    """Scheduled notification reminder commands for cron / Render jobs."""


@notifications_cli.command("artist-order-reminders")
@with_appcontext
def artist_order_reminders_command():
    """Notify artists about paid orders awaiting fulfillment for 24h+."""
    summary = run_artist_order_reminders()
    click.echo(json.dumps(summary, default=str))


@notifications_cli.command("cart-inactivity-reminders")
@with_appcontext
def cart_inactivity_reminders_command():
    """Notify users about carts with items inactive for 24h+."""
    summary = run_cart_inactivity_reminders()
    click.echo(json.dumps(summary, default=str))


@notifications_cli.command("run-all-reminders")
@with_appcontext
def run_all_reminders_command():
    """Run all scheduled notification reminder jobs."""
    summary = {
        "artist_order_reminders": run_artist_order_reminders(),
        "cart_inactivity_reminders": run_cart_inactivity_reminders(),
    }
    click.echo(json.dumps(summary, default=str))


def register_cli_commands(app):
    """Attach notification job commands to the Flask app CLI."""
    app.cli.add_command(notifications_cli)
