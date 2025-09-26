# Histórico de Alterações

Todas as alterações notáveis deste projeto são documentadas neste arquivo.

O formato segue o Keep a Changelog e este projeto adere ao versionamento semântico (SemVer).

## [1.0.0] - 2025-09-26

### Adicionado
- Script de instalação automatizada (`setup_zsh.sh`) para Debian/Ubuntu usando `apt`.
- Instalação não interativa do Oh-My-Zsh.
- Tema Powerlevel10k e plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`.
- Arquivo `zshrc_final` ajustado com aliases, histórico compartilhado, cache de autocompletar e integração com `grc`.
- Logs de fingerprint no início e no fim (data/hora, usuário, host, versão do Zsh).
- Desinstalador (`uninstall_zsh.sh`) com dois modos:
  - `revert`: restaura o `~/.zshrc` anterior e mantém as customizações instaladas.
  - `full`: remove o Oh-My-Zsh, Powerlevel10k e volta o shell padrão para Bash.
- Melhorias no README e guia do Powerlevel10k em `docs/`.
- Arquivo de licença MIT.
