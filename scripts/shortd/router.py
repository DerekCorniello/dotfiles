import logging
from typing import Optional
from shortd.config import REDIRECTS
from shortd.handlers.github import resolve as github_resolve
from shortd.handlers.redirects import resolve as redirects_resolve

HANDLERS = {
    "gh": github_resolve,
}

for key in REDIRECTS:
    HANDLERS[key] = redirects_resolve

log = logging.getLogger("shortd")


def resolve(path: str) -> Optional[str]:
    parts = [p for p in path.split("/") if p]
    if not parts:
        return None

    handler = HANDLERS.get(parts[0])
    if not handler:
        return None

    url = handler(path)
    if url:
        log.info("%s -> %s", path, url)
    return url
