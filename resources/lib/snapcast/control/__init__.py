"""Snapcast control for Snapcast 0.11.1."""

import asyncio
from snapcast.control.server import Snapserver, CONTROL_PORT


@asyncio.coroutine
def create_server(loop, host, port=CONTROL_PORT, reconnect=False):
    """Server factory."""
    server = Snapserver(loop, host, port, reconnect)
    yield from server.start()
    return server
