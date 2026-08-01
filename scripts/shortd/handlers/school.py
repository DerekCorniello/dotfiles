from typing import Optional

LINKS = {
    "canvas": "https://uc.instructure.com/",
    "catalyst": "https://catalyst.uc.edu/",
    "email": "https://mail.uc.edu/",
}


def resolve(path: str) -> Optional[str]:
    parts = [p for p in path.split("/") if p][1:]
    if not parts:
        return None

    return LINKS.get(parts[0])
