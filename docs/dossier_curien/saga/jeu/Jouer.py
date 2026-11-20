"""Lance la version navigateur sur une adresse locale stable pour les records."""
import errno
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import webbrowser

PREFERRED_PORT = 28716


def serve():
    handler = partial(SimpleHTTPRequestHandler, directory=str(Path(__file__).resolve().parent / "site"))
    try:
        server = ThreadingHTTPServer(("127.0.0.1", PREFERRED_PORT), handler)
    except OSError as exc:
        if exc.errno != errno.EADDRINUSE:
            raise
        server = ThreadingHTTPServer(("127.0.0.1", 0), handler)
        print("Le port habituel est occupé. Cette partie aura ses propres records de navigateur.", flush=True)
    with server:
        url = "http://127.0.0.1:%d/" % server.server_port
        print("Dossier Curien —", url, flush=True)
        print("Gardez cette fenêtre ouverte pour jouer. Ctrl+C pour fermer.", flush=True)
        webbrowser.open(url)
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass


if __name__ == "__main__":
    serve()
