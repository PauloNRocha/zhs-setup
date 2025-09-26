#!/usr/bin/env bash
# =====================================
# Script de Desinstalação do Setup Zsh
# Autor: Paulo Rocha + ChatGPT
# =====================================

set -euo pipefail

log_info()  { echo -e "\033[1;34mℹ️  $1\033[0m"; }
log_ok()    { echo -e "\033[1;32m✅ $1\033[0m"; }
log_warn()  { echo -e "\033[1;33m⚠️  $1\033[0m"; }
log_error() { echo -e "\033[1;31m❌ $1\033[0m"; }

print_fingerprint() {
  local stage="$1"
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S %Z")
  local zver="zsh não encontrado"
  if command -v zsh >/dev/null 2>&1; then
    zver=$(zsh --version)
  fi
  log_info "$stage"
  printf "   Data/Hora: %s\n" "$timestamp"
  printf "   Usuário: %s\n" "$(whoami)"
  printf "   Host: %s\n" "$(hostname)"
  printf "   Zsh: %s\n" "$zver"
}

usage() {
  cat <<'USAGE'
Uso: uninstall_zsh.sh [opções]
  -y, --yes                 Não perguntar confirmação
  --mode MODE               Define o modo: revert | full
  --remove-packages         Remove zsh, grc, fonts-powerline (apenas modo full)
  --remove-all-packages     Também remove git, curl, wget (apenas modo full)
  -v, --verbose             Mostra saída completa
  -h, --help                Mostra esta ajuda

Modos disponíveis:
  revert  -> Restaura o ~/.zshrc anterior (mantém Oh-My-Zsh, plugins e tema)
  full    -> Remove Oh-My-Zsh, tema Powerlevel10k, restaura ~/.zshrc e volta ao Bash
USAGE
}

VERBOSE=0
ASSUME_YES=0
REMOVE_PACKAGES=0
REMOVE_ALL_PACKAGES=0
MODE=""

while (($#)); do
  case "$1" in
    -y|--yes)
      ASSUME_YES=1
      shift
      ;;
    --mode)
      shift
      if (($# == 0)); then
        log_error "Faltou informar o modo após --mode"
        usage
        exit 1
      fi
      MODE="${1,,}"
      shift
      ;;
    --mode=*)
      MODE="${1#*=}"
      MODE="${MODE,,}"
      shift
      ;;
    --remove-packages)
      REMOVE_PACKAGES=1
      shift
      ;;
    --remove-all-packages)
      REMOVE_PACKAGES=1
      REMOVE_ALL_PACKAGES=1
      shift
      ;;
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

if [[ -n "$MODE" && "$MODE" != "revert" && "$MODE" != "full" ]]; then
  log_error "Modo inválido: $MODE (use revert ou full)"
  exit 1
fi

if [[ -z "$MODE" ]]; then
  if (( ASSUME_YES )); then
    MODE="full"
    log_warn "--yes informado sem --mode; assumindo remoção completa (full)."
  else
    echo "Escolha o modo de desinstalação:"
    echo "  [1] Reverter apenas o ~/.zshrc (mantém Oh-My-Zsh, tema e plugins)"
    echo "  [2] Remover completamente a personalização (Oh-My-Zsh, Powerlevel10k, voltar ao Bash)"
    read -r -p "Seleção [1/2, padrão 2]: " choice
    case "${choice:-2}" in
      1|revert|Revert) MODE="revert" ;;
      2|""|full|Full) MODE="full" ;;
      *)
        log_warn "Opção desconhecida (${choice}). Assumindo modo completo (2)."
        MODE="full"
        ;;
    esac
  fi
fi

if [[ "$MODE" == "revert" ]]; then
  log_info "Modo selecionado: revert (restaurar ~/.zshrc, manter customizações instaladas)."
else
  log_info "Modo selecionado: full (remover Oh-My-Zsh, tema e voltar ao Bash)."
fi

if [[ "$MODE" == "revert" && REMOVE_PACKAGES -eq 1 ]]; then
  log_warn "--remove-packages ignorado no modo revert. Use modo full para remover pacotes."
  REMOVE_PACKAGES=0
  REMOVE_ALL_PACKAGES=0
fi

TMP_DIR=$(mktemp -d)
RUN_CMD_COUNT=0
cleanup() { rm -rf "$TMP_DIR"; }
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
    "$@" || status=$?
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

print_fingerprint "🧾 Fingerprint inicial (desinstalação)"
if (( ASSUME_YES == 0 )); then
  if [[ "$MODE" == "revert" ]]; then
    read -r -p "Confirmar a reversão do ~/.zshrc? [y/N]: " answer
  else
    read -r -p "Confirmar a remoção completa da personalização do Zsh? [y/N]: " answer
  fi
  case "${answer,,}" in
    y|yes) : ;;
    *) log_warn "Cancelado pelo usuário."; exit 0 ;;
  esac
fi

if [ -f "$HOME/.zshrc" ]; then
  cp "$HOME/.zshrc" "$HOME/.zshrc.uninstall.bak" || true
fi

if [ -f "$HOME/.zshrc.bak" ]; then
  run_command "📄 Restaurando ~/.zshrc a partir do backup..." "~/.zshrc restaurado." \
    cp "$HOME/.zshrc.bak" "$HOME/.zshrc"
else
  run_command "🧹 Removendo ~/.zshrc (não há backup disponível)..." "~/.zshrc removido." \
    bash -lc 'rm -f "$HOME/.zshrc"'
fi

if [[ "$MODE" == "full" ]]; then
  if [ -f "$HOME/.zshrc" ] && grep -qiE 'oh-my-zsh|powerlevel10k' "$HOME/.zshrc"; then
    log_warn "O ~/.zshrc atual ainda possui referências ao Oh-My-Zsh. Criando configuração básica."
    run_command "🧼 Substituindo ~/.zshrc por uma versão mínima..." "~/.zshrc redefinido sem Oh-My-Zsh." \
      bash -lc 'printf "%s\n" "# ~/.zshrc redefinido pelo uninstall_zsh.sh (modo full)" \
        "# Adicione aqui suas configurações personalizadas de Zsh." \
        "" > "$HOME/.zshrc"'
  fi

  run_command "🧹 Removendo ~/.p10k.zsh..." "Arquivo ~/.p10k.zsh removido (se existia)." \
    bash -lc 'rm -f "$HOME/.p10k.zsh"'

  run_command "🧹 Limpando caches do Powerlevel10k..." "Caches removidos (se existiam)." \
    bash -lc 'rm -f "${XDG_CACHE_HOME:-$HOME/.cache}"/p10k-instant-prompt-*.zsh || true'

  if [ -d "$HOME/.oh-my-zsh" ]; then
    run_command "🗑 Removendo Oh-My-Zsh (~/.oh-my-zsh)..." "Oh-My-Zsh removido." \
      rm -rf "$HOME/.oh-my-zsh"
  else
    log_warn "~/.oh-my-zsh não encontrado, pulando..."
  fi

  if command -v bash >/dev/null 2>&1; then
    log_info "🖋 Alterando shell padrão para Bash..."
    log_info "   Digite sua senha se o sistema solicitar."
    if chsh -s "$(command -v bash)"; then
      log_ok "Shell padrão alterado para Bash."
    else
      log_warn "Não foi possível alterar o shell automaticamente. Execute: chsh -s $(command -v bash)"
    fi
  else
    log_warn "Bash não encontrado; não foi possível alterar o shell padrão."
  fi

  if (( REMOVE_PACKAGES )); then
    PKGS=(zsh grc fonts-powerline)
    if (( REMOVE_ALL_PACKAGES )); then
      PKGS+=(git curl wget)
    fi
    run_command "📦 Removendo pacotes: ${PKGS[*]}" "Pacotes removidos/verificados." \
      sudo apt remove -y "${PKGS[@]}" || true
    run_command "📦 Autoremove pacotes órfãos..." "Autoremove concluído." \
      sudo apt autoremove -y || true
  fi
else
  log_info "Mantendo Oh-My-Zsh, Powerlevel10k e plugins instalados (modo revert)."
fi

print_fingerprint "🧾 Fingerprint final (desinstalação)"
if [[ "$MODE" == "full" ]]; then
  echo -e "➡️  Feche e reabra o terminal. Se necessário, entre no Bash manualmente: \033[1;36mbash\033[0m"
else
  echo -e "➡️  Abra um shell Zsh para testar a configuração restaurada: \033[1;36mzsh\033[0m"
fi
