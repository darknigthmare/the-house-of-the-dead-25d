# Build Guide

## Toolchain

- Godot 4.7.1 stable and matching official export templates.
- Node.js 20 or newer.
- Windows PowerShell for validation, exports and release packaging.
- Python 3 with Pillow and NumPy only when rebuilding the directional atlases from the ignored raw source sheets. Normal tests, gameplay and export do not require those Python packages.

The portable editor may be stored under `.tools/godot-4.7.1/`; `.tools`, raw generated sources and licensed/reference folders stay outside Git.

## Validation

```powershell
npm.cmd test
npm.cmd run qa
```

Final 2026-08-21 evidence: `npm.cmd test` 252/252; `npm.cmd run qa` 257/257; 232 core assertions; 57 manifest-atomicity assertions; directional smoke 35 bindings/seven representatives/eight directions. Gameplay, score, initials and complete-campaign smokes pass. The gameplay/campaign smokes report two non-blocking `ObjectDB` instances at shutdown.

## Exports

```powershell
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --export-release 'Windows Desktop'
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --export-release 'Linux'
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --export-release 'Web'
npm run fix:web-accessibility
npm.cmd run qa:web
npm.cmd run verify:web
```

Expected outputs are `build/windows/The_House_of_the_Dead_25D.exe`, `build/linux/The_House_of_the_Dead_25D.x86_64` and `build/web/index.html`. Final sizes are 202,088,128 bytes Windows, 166,452,720 Linux and 132,826,890 across nine Web files; PCK is 92,982,496 and WASM 39,513,091. Windows headless startup passes, `qa:web` is 256/256 and `verify:web` is OK.

Every Web export rewrites `index.html`; always rerun the accessibility patch before Web QA. The final local browser pass confirms `crossOriginIsolated=true`, PCK/WASM 200, two-player HUD/crosshairs, three target viewport shapes, zero page errors and axe 4.12 at 23 passes/0 violations.

## Atlas rebuild only

Install Python dependencies only if the ignored raw source sheets are present and atlas reconstruction is required:

```powershell
py -m pip install -r requirements-art.txt
py scripts/assemble_directional_atlases.py
node scripts/verify_sprite_atlas_v2.mjs
```

Do not claim a licensed reconstruction when the ignored/legal source material is absent.

## Release archives

Commit the exact verified tree first because the source archive is produced from `HEAD`, then run:

```powershell
& '.\scripts\package_release.ps1'
```

The script creates source, Windows, Linux and Web ZIP files plus `artifacts/release/SHA256SUMS.txt`. Recalculate/verify every SHA-256 before uploading. After extracting the Linux ZIP on Linux, restore its executable bit before launch:

```bash
chmod +x The_House_of_the_Dead_25D.x86_64
./The_House_of_the_Dead_25D.x86_64
```

## Publication and clean-machine gates

GitHub repository/release, Vercel deployment and public HTTP/browser QA are pending. Record exact commit and production URL only after they exist, then repeat COOP/COEP, WASM MIME, PCK/WASM 200, page-error, P1/P2, responsive and axe checks publicly.

On a clean Windows 64-bit machine or VM, extract only the Windows archive, start the executable and verify menu, one encounter, six shots, both reload methods and two-player join. Physical Gun4IR/Sinden devices remain separate hardware gates.
