from shortd.config import GITHUB_USER, REPO_ALIASES, PROJECT_BOARDS

GITHUB_ACTIONS = {
    "issues": "issues",
    "prs": "pulls",
    "actions": "actions",
    "releases": "releases",
}


def resolve(path: str):
    parts = [p for p in path.split("/") if p]

    if not parts or parts[0] != "gh":
        return None

    parts = parts[1:]
    if not parts:
        return f"https://github.com/{GITHUB_USER}"

    if parts[0] == "prs":
        return f"https://github.com/{GITHUB_USER}/{parts[0]}"

    repo = parts[0]
    real = REPO_ALIASES.get(repo, repo)
    base = f"https://github.com/{GITHUB_USER}/{real}"

    if len(parts) == 1:
        return base

    section = parts[1]
    if repo in PROJECT_BOARDS and section == "board":
        return PROJECT_BOARDS[repo]

    action = GITHUB_ACTIONS.get(section)
    if action:
        return f"{base}/{action}"

    return f"{base}/{section}"
