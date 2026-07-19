from shortd.config import GITHUB_USER, REPO_ALIASES, ORGS, PROJECT_BOARDS

GITHUB_ACTIONS = {
    "issues": "issues",
    "prs": "pulls",
    "actions": "actions",
    "releases": "releases",
}

ORG_SECTIONS = {
    "prs": ("pulls", "pr"),
    "issues": ("issues", "issue"),
}


def resolve(path: str):
    parts = [p for p in path.split("/") if p]

    if not parts or parts[0] != "gh":
        return None

    parts = parts[1:]
    if not parts:
        return f"https://github.com/{GITHUB_USER}"

    if parts[0] == "prs":
        return f"https://github.com/pulls?q=is%3Apr+author%3A{GITHUB_USER}"

    if parts[0] == "issues":
        return f"https://github.com/issues?q=is%3Aissue+is%3Aopen+author%3A{GITHUB_USER}"

    org = ORGS.get(parts[0])
    if org:
        if len(parts) == 1:
            return f"https://github.com/{org}"
        section = parts[1]
        mapped = ORG_SECTIONS.get(section)
        if mapped:
            action, qualifier = mapped
            qualifier_suffix = "+is%3Aopen" if qualifier == "issue" else ""
            return f"https://github.com/{action}?q=is%3A{qualifier}{qualifier_suffix}+org%3A{org}"
        return f"https://github.com/{org}"

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
