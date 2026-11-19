"""Sends one payment request. The key comes from the environment (.env in development)."""
import os


def headers():
    return {"Authorization": "Bearer " + os.environ["PAYMENTS_API_KEY"]}
