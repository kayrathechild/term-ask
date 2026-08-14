#!/usr/bin/env bash
# term-ask.sh — term-ask için taşınabilir başlatıcı
# Bağımlılıklar: Python 3.10+, sanal ortam (.venv veya venv)

set -euo pipefail

# Script'in bulunduğu dizine git (her yerden çalıştırılabilir)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# .env yükle (varsa)
if [[ -f "$SCRIPT_DIR/.env" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/.env"
    set +a
fi

# Sanal ortamı bul ve aktive et
if [[ -f "$SCRIPT_DIR/.venv/bin/activate" ]]; then
    VENV_PATH="$SCRIPT_DIR/.venv"
elif [[ -f "$SCRIPT_DIR/venv/bin/activate" ]]; then
    VENV_PATH="$SCRIPT_DIR/venv"
else
    echo "[term-ask] HATA: Sanal ortam bulunamadı (.venv veya venv)." >&2
    echo "           Lütfen önce: python3 -m venv .venv && .venv/bin/pip install -r requirements.txt" >&2
    exit 1
fi

# shellcheck source=/dev/null
source "$VENV_PATH/bin/activate"

# Bağımlılıkları kontrol et (sadece ilk çalıştırmada yavaş olabilir)
if ! python3 -c "import textual, litellm, rich, pyperclip" &>/dev/null; then
    echo "[term-ask] Bağımlılıklar yükleniyor..." >&2
    pip install -q -r "$SCRIPT_DIR/requirements.txt"
fi

# Uygulamayı başlat
exec python3 "$SCRIPT_DIR/run.py" "$@"
