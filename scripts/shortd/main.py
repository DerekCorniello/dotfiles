import logging
import os
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import unquote, urlparse

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from shortd.config import HOSTS_FILE, HOSTNAME, EXPECTED_IP
from shortd.router import resolve

log = logging.getLogger("shortd")


def fail_fast_check():
    try:
        with open(HOSTS_FILE) as f:
            content = f.read()
    except Exception as e:
        print(f"Cannot read {HOSTS_FILE}: {e}")
        sys.exit(1)

    valid = any(
        line.startswith(EXPECTED_IP) and HOSTNAME in line.split()
        for line in content.splitlines()
    )

    if not valid:
        print(f"'{EXPECTED_IP} {HOSTNAME}' not found in /etc/hosts")
        sys.exit(1)


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

    def log_message(self, fmt, *args):
        pass


def main():
    logging.basicConfig(
        level=logging.INFO,
        format="[shortd] %(message)s",
    )
    fail_fast_check()

    server = HTTPServer(("127.0.0.1", 80), Handler)
    log.info("shortd running on http://dc")
    server.serve_forever()


if __name__ == "__main__":
    main()
