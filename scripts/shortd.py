#!/usr/bin/env python3
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import unquote, urlparse

HOSTS_FILE = "/etc/hosts"
HOSTNAME = "dc"
EXPECTED_IP = "127.0.0.1"

GITHUB_USER = "DerekCorniello"

# if proj name and repo name differ
ALIASES = {
    "mux": "mux-lang",
}


def fail_fast_check():
    try:
        with open(HOSTS_FILE, "r") as f:
            content = f.read()
    except Exception as e:
        print(f"Cannot read {HOSTS_FILE}: {e}")
        sys.exit(1)

    valid = any(
        line.startswith(EXPECTED_IP) and HOSTNAME in line.split()
        for line in content.splitlines()
    )

    if not valid:
        print("'127.0.0.1 dc' not found in /etc/hosts")
        sys.exit(1)


def resolve_repo(name: str) -> str:
    # dynamic aliasing layer
    real = ALIASES.get(name, name)
    return f"https://github.com/{GITHUB_USER}/{real}"


def resolve(path):
    """
    path examples:
      gh/mux
      gh/mux/issues
      gh/hunch/pulls
    """
    parts = [p for p in path.split("/") if p]

    if not parts or parts[0] != "gh":
        return None

    # if gh is only passed, route to it
    parts = parts[1:]
    if not parts:
        return f"https://github.com/{GITHUB_USER}"

    repo = parts[0]
    base = resolve_repo(repo)

    if len(parts) == 1:
        return base

    section = parts[1]

    # special case for mux proj board
    if repo == "mux" and section == "board":
        return f"https://github.com/users/{GITHUB_USER}/projects/1"

    if section == "issues":
        return f"{base}/issues"

    if section == "prs":
        return f"{base}/pulls"

    # fallback: raw passthrough
    return f"{base}/{section}"


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        path = unquote(parsed.path).lstrip("/")
        url = resolve(path)

        if not url:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"unknown shortcut")
            return

        self.send_response(302)
        self.send_header("Location", url)
        self.end_headers()


def main():
    fail_fast_check()

    server = HTTPServer(("127.0.0.1", 80), Handler)
    print("shortd running on http://dc")
    server.serve_forever()


if __name__ == "__main__":
    main()
