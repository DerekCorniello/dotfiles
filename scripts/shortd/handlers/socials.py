from typing import Optional

LINKS = {
    "linkedin": ("https://www.linkedin.com/", "in/derek-corniello"),
    "x": ("https://x.com/", "DerekCorniello"),
    "youtube": ("https://www.youtube.com/", "@DerekCornDev"),
    "github": ("https://github.com/", "DerekCorniello"),
    "me": ("https://derekcorn.dev/", ""),
}


def resolve(path: str) -> Optional[str]:
    parts = [p for p in path.split("/") if p]
    if not parts:
        return None

    base, suffix = LINKS.get(parts[0], (None, None))
    if base is None:
        return None

    return base + suffix if len(parts) > 1 and parts[1] == "me" else base
