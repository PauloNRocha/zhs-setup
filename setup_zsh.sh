#!/usr/bin/env bash
# =====================================
# Script de Setup Automático do Zsh
# Autor: Paulo Rocha + ChatGPT
# =====================================

set -euo pipefail

OH_MY_ZSH_INSTALLER_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

log_info()  { echo -e "\033[1;34mℹ️  $1\033[0m"; }
log_ok()    { echo -e "\033[1;32m✅ $1\033[0m"; }
log_warn()  { echo -e "\033[1;33m⚠️  $1\033[0m"; }
log_error() { echo -e "\033[1;31m❌ $1\033[0m"; }

print_fingerprint() {
  local stage="$1"
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S %Z")
  local current_user
  current_user=$(whoami)
  local host
  host=$(hostname)
  local zsh_version="zsh não encontrado"
  if command -v zsh >/dev/null 2>&1; then
    zsh_version=$(zsh --version)
  fi

  log_info "$stage"
  printf "   Data/Hora: %s\n" "$timestamp"
  printf "   Usuário: %s\n" "$current_user"
  printf "   Host: %s\n" "$host"
  printf "   Zsh: %s\n" "$zsh_version"
}

usage() {
  cat <<'USAGE'
Uso: setup_zsh.sh [opções]

Opções:
  -v, --verbose   Mostra a saída completa dos comandos
  -h, --help      Exibe esta ajuda

Por padrão o script é silencioso e mostra apenas o andamento geral.
Use --verbose para acompanhar todos os detalhes.
USAGE
}

VERBOSE=0

while (($#)); do
  case "$1" in
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log_error "Opção desconhecida: $1"
      usage
      exit 1
      ;;
  esac
done

print_fingerprint "🧾 Fingerprint inicial"

TMP_DIR=$(mktemp -d)
RUN_CMD_COUNT=0

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

spinner() {
  local pid=$1
  local -a frames=("|" "/" "-" "\\")
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r   %s" "${frames[i]}"
    i=$(( (i + 1) % ${#frames[@]} ))
    sleep 0.1
  done
  printf "\r   \r"
}

run_command() {
  local start_message="$1"
  local success_message="$2"
  shift 2

  log_info "$start_message"

  local status=0
  local log_file=""

  if (( VERBOSE )); then
    "$@"
    status=$?
  else
    log_file="$TMP_DIR/cmd_$(printf '%02d' "$RUN_CMD_COUNT").log"
    RUN_CMD_COUNT=$(( RUN_CMD_COUNT + 1 ))

    "$@" >"$log_file" 2>&1 &
    local pid=$!
    spinner "$pid"
    wait "$pid" || status=$?
  fi

  if (( status != 0 )); then
    log_error "Falha durante: $start_message"
    if (( VERBOSE )); then
      log_error "Execute novamente após resolver o problema."
    elif [ -s "$log_file" ]; then
      log_warn "Use --verbose para mais detalhes. Últimas linhas do log:"
      tail -n 20 "$log_file" || true
    else
      log_warn "Use --verbose para mais detalhes."
    fi
    exit "$status"
  fi

  log_ok "$success_message"
}

# ---------- Instalação de pacotes ----------
run_command "🔧 Atualizando lista de pacotes..." "Repositórios atualizados." sudo apt update -y
run_command "🔧 Verificando pacotes necessários..." "Pacotes instalados/verificados com sucesso." sudo apt install -y zsh git curl wget fonts-powerline grc

# ---------- Instalação do Oh-My-Zsh ----------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  run_command "📦 Instalando Oh-My-Zsh..." "Oh-My-Zsh instalado." sh -c "curl -fsSL \"$OH_MY_ZSH_INSTALLER_URL\" | sh -s -- --unattended"
else
  log_warn "Oh-My-Zsh já está instalado, pulando..."
fi

CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$CUSTOM_DIR/themes" "$CUSTOM_DIR/plugins"

# ---------- Instalação do Powerlevel10k ----------
THEME_PATH="$CUSTOM_DIR/themes/powerlevel10k"
if [ ! -d "$THEME_PATH" ]; then
  run_command "🎨 Instalando Powerlevel10k..." "Powerlevel10k instalado." git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$THEME_PATH"
else
  log_warn "Powerlevel10k já existe, pulando..."
fi

# ---------- Instalação dos plugins ----------
AUTOSUGGESTIONS_PATH="$CUSTOM_DIR/plugins/zsh-autosuggestions"
if [ ! -d "$AUTOSUGGESTIONS_PATH" ]; then
  run_command "🔌 Instalando zsh-autosuggestions..." "zsh-autosuggestions instalado." git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_PATH"
else
  log_warn "zsh-autosuggestions já existe, pulando..."
fi

SYNTAX_HIGHLIGHTING_PATH="$CUSTOM_DIR/plugins/zsh-syntax-highlighting"
if [ ! -d "$SYNTAX_HIGHLIGHTING_PATH" ]; then
  run_command "🔌 Instalando zsh-syntax-highlighting..." "zsh-syntax-highlighting instalado." git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_HIGHLIGHTING_PATH"
else
  log_warn "zsh-syntax-highlighting já existe, pulando..."
fi

# ---------- Aplicação do zshrc ----------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ZSHRC_SOURCE=""
if [ -f "$SCRIPT_DIR/.zshrc_final" ]; then
  ZSHRC_SOURCE="$SCRIPT_DIR/.zshrc_final"
elif [ -f "$SCRIPT_DIR/zshrc_final" ]; then
  ZSHRC_SOURCE="$SCRIPT_DIR/zshrc_final"
fi

if [ -n "$ZSHRC_SOURCE" ]; then
  if [ -f "$HOME/.zshrc" ]; then
    run_command "📄 Fazendo backup do .zshrc atual..." "Backup salvo em ~/.zshrc.bak." cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
  fi
  run_command "📄 Aplicando zshrc personalizado..." ".zshrc aplicado com sucesso." cp "$ZSHRC_SOURCE" "$HOME/.zshrc"
else
  log_warn "Arquivo zshrc_final não encontrado, pulei esta etapa."
fi

# ---------- Alteração do shell ----------
log_info "🖋 Alterando shell padrão para Zsh..."
log_info "   Digite sua senha se o sistema solicitar."
if chsh -s "$(command -v zsh)"; then
  log_ok "Shell padrão alterado."
else
  log_warn "Não foi possível alterar o shell automaticamente. Execute: chsh -s $(command -v zsh)"
fi

log_ok "Setup concluído!"
print_fingerprint "🧾 Fingerprint final"
echo -e "➡️  Reinicie o terminal ou execute: \033[1;36msource ~/.zshrc\033[0m"
