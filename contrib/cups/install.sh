#!/bin/sh
# Install the vc500w CUPS backend system-wide (run as root).
#
#   sudo contrib/cups/install.sh [PREFIX]
#
# PREFIX defaults to /opt/labelprinter-vc500w. The backend needs a Python
# environment readable by the CUPS user, so it gets its own venv there.
set -eu

PREFIX="${1:-/opt/labelprinter-vc500w}"
SRC="$(cd "$(dirname "$0")/../.." && pwd)"
BACKEND_DIR="$(cups-config --serverbin)/backend"

for tool in pdftoppm gs; do
    command -v "$tool" >/dev/null || echo "warning: $tool not found (needed for PDF / PostScript jobs)" >&2
done

if command -v uv >/dev/null; then
    uv venv --quiet --allow-existing "$PREFIX"
    uv pip install --quiet --python "$PREFIX/bin/python" --reinstall-package labelprinter "$SRC"
else
    python3 -m venv "$PREFIX"
    "$PREFIX/bin/pip" install --quiet --upgrade "$SRC"
fi

sed "s|@PREFIX@|$PREFIX|" "$SRC/contrib/cups/vc500w" > "$BACKEND_DIR/vc500w.tmp"
chmod 0755 "$BACKEND_DIR/vc500w.tmp"
mv "$BACKEND_DIR/vc500w.tmp" "$BACKEND_DIR/vc500w"

echo "Installed backend: $BACKEND_DIR/vc500w (Python in $PREFIX)"
echo "Create a queue, e.g.:"
echo "  lpadmin -p VC500W -E -v 'vc500w://VC-500W1234.local/?mode=vivid&cut=full' -m raw"
