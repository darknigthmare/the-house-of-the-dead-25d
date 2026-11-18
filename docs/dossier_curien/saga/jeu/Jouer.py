"""Lance la démo hors ligne sur une adresse locale libre."""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import webbrowser

handler = partial(SimpleHTTPRequestHandler, directory=str(Path(__file__).resolve().parent / "site"))
with ThreadingHTTPServer(("127.0.0.1", 0), handler) as server:
    url = "http://127.0.0.1:%d/" % server.server_port
    print("Dossier Curien —", url, flush=True)
    print("Gardez cette fenêtre ouverte pour jouer. Ctrl+C pour fermer.", flush=True)
    webbrowser.open(url)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
