import logging
from typing import Optional
from shortd.config import REDIRECTS
from shortd.handlers.github import resolve as github_resolve
from shortd.handlers.redirects import resolve as redirects_resolve
from shortd.handlers.school import resolve as school_resolve
from shortd.handlers.social import LINKS as SOCIAL_LINKS
from shortd.handlers.social import resolve as social_resolve

HANDLERS = {
    "gh": github_resolve,
    "school": school_resolve,
}

for key in SOCIAL_LINKS:
    HANDLERS[key] = social_resolve

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
