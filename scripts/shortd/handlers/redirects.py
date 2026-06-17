from shortd.config import REDIRECTS


def resolve(path: str):
    parts = [p for p in path.split("/") if p]
    if not parts:
        return None

    url = REDIRECTS.get(parts[0])
    if not url:
        return None

    return url
