# 🚀 Setup Zsh + Oh-My-Zsh + Powerlevel10k

![Shell](https://img.shields.io/badge/shell-zsh-green?logo=gnu-bash&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)


Um script simples, robusto e bem documentado para automatizar a configuração de um ambiente Zsh profissional no Linux.  
Perfeito para quem acabou de formatar o sistema e quer rapidamente um terminal bonito, funcional e com produtividade máxima.

---

## 🎯 Objetivo

Quando instalo ou formato uma máquina, perco tempo configurando manualmente Zsh, Oh-My-Zsh, Powerlevel10k, plugins e meu `.zshrc` personalizado.  
Este projeto nasceu para **resolver esse problema de uma vez por todas**, com um único comando que:

- Instala **Zsh** e dependências necessárias.
- Configura **Oh-My-Zsh** e o tema **Powerlevel10k**.
- Instala plugins úteis (`zsh-autosuggestions`, `zsh-syntax-highlighting`).
- Aplica um `.zshrc` bem organizado, com aliases, histórico compartilhado e autocompletar otimizado.
- Faz **backup automático** do `.zshrc` antigo antes de sobrescrever.
- Altera o shell padrão para Zsh de forma segura.

---

<!-- Seção de Demonstração removida -->

## 🛠 Recursos Instalados

- **Zsh** – Shell moderno e poderoso.
- **Oh-My-Zsh** – Framework para gerenciar configuração do Zsh.
- **Powerlevel10k** – Tema rápido e altamente customizável.
- **Plugins:**
  - `zsh-autosuggestions` – Sugere comandos baseados no histórico.
  - `zsh-syntax-highlighting` – Coloriza comandos antes da execução.
- **grc** – Colorização para comandos como `ping`, `netstat`, `traceroute`.
- **.zshrc Personalizado:**
  - Aliases para Git, Docker e manutenção do sistema.
  - Histórico compartilhado entre múltiplas sessões.
  - Cache de completions para inicialização rápida.
  - Proteção para `rm` (`rm -i` pergunta antes de deletar).
  - Cores nativas para `ls`, `grep`, `diff`.

---

## 📦 Instalação

Clone o repositório:

```bash
git clone https://github.com/PauloNRocha/zsh-setup.git
cd zsh-setup
```

Dê permissão de execução e rode o script:

```bash
chmod +x setup_zsh.sh
./setup_zsh.sh
```

> **Obs:** o script pode pedir sua senha para alterar o shell padrão com `chsh`.

Reinicie o terminal ou aplique imediatamente:

```bash
source ~/.zshrc
```

---

## ✅ Pré-requisitos

- Sistema baseado em Debian/Ubuntu (usa `apt`).
- Acesso a `sudo` para instalar pacotes e mudar o shell.
- Conexão com a internet (clona repositórios e baixa instaladores).

---

## 💻 Uso

Comandos básicos:

```bash
# execução padrão (silenciosa, com spinner)
./setup_zsh.sh

# modo verboso (mostra toda a saída)
./setup_zsh.sh -v

# ajuda
./setup_zsh.sh -h
```

Opções:

- `-v, --verbose` — mostra a saída completa dos comandos (sem spinner).
- `-h, --help` — exibe a ajuda e sai.

Após finalizar:

```bash
# torne o Zsh seu shell padrão (se necessário)
chsh -s "$(command -v zsh)"

# reabra o terminal ou aplique imediatamente
source ~/.zshrc
```

---

## 🎨 Powerlevel10k

Para ajustar o tema após a instalação, consulte o guia: [docs/powerlevel10k_configure.md](docs/powerlevel10k_configure.md).

Atalho rápido para reconfigurar:

```bash
p10k configure
```

---

## 🧠 Por Que Criar Este Projeto?

> **Motivação Pessoal:**  
> Eu sempre gostei de ambientes organizados e produtivos, mas cada vez que formatava minha máquina, tinha que repetir dezenas de passos manualmente.  
> Decidi transformar esse processo em um **script automatizado**, não só para economizar tempo, mas para aprender boas práticas de shell script e compartilhar algo útil com outras pessoas.

---

## 🛡 Boas Práticas Implementadas

- `set -e` → interrompe em erros críticos para evitar configuração inconsistente.
- **Mensagens coloridas** → melhor feedback visual.
- **Backup automático** → segurança ao sobrescrever arquivos.
- **Idempotência** → pode rodar várias vezes sem duplicar instalações.
- **Fingerprint inicial e final** → rastreabilidade (data, usuário, host e versão do Zsh).

---

## 📜 Licença

Este projeto é distribuído sob a licença [MIT](LICENSE).  
Sinta-se à vontade para usar, modificar e contribuir!
