# 🎨 Reconfigurando o Powerlevel10k

O **Powerlevel10k** é um tema altamente customizável para o Zsh, permitindo deixar seu terminal mais produtivo e visualmente bonito.  
Este guia explica como reconfigurar o Powerlevel10k usando o assistente interativo ou ajustes manuais.

---

## 🔄 Reconfiguração Rápida

1. Abra o terminal que já utiliza o Zsh + Powerlevel10k.  
2. Execute o comando:

   ```bash
   p10k configure
   ```

3. Será iniciado um **wizard interativo** com várias perguntas sobre o estilo do seu prompt.

---

## 🧙 Etapas do `p10k configure`

Durante a configuração, você poderá escolher:

- **Compatibilidade de fontes:**  
  Confirma se seu terminal suporta ícones Nerd Fonts (setas, ícones de Git, símbolos especiais).

- **Layout do prompt:**  
  - *Clássico* (estilo tradicional).  
  - *Moderno* (mais espaçado e com ícones).  
  - *Minimalista* (apenas informações básicas).  

- **Número de linhas:**  
  - *Uma linha* → compacto.  
  - *Duas linhas* → mais organizado.

- **Elementos exibidos:**  
  Atalhos para informações úteis, como:
  - Status do **Git**.  
  - Usuário e host.  
  - Tempo de execução de comandos.  
  - Status do último comando.

- **Cores:**  
  - Paleta *discreta*.  
  - Paleta *viva*.  
  - Paleta *arco-íris*.

No final, o Powerlevel10k gera automaticamente o arquivo `~/.p10k.zsh`.

---

## ⚙️ Arquivo de Configuração

- O arquivo principal é:

  ```bash
  ~/.p10k.zsh
  ```

- Para aplicar mudanças imediatamente após salvar edições:

  ```bash
  source ~/.zshrc
  ```

- Você pode abrir o arquivo para ajustes manuais:

  ```bash
  nano ~/.p10k.zsh
  ```

Esse arquivo contém comentários explicativos em cada linha, permitindo personalizar facilmente cores, ícones e layout.

---

## 💡 Dicas Extras

- Para testar novas fontes com ícones Nerd Fonts, configure seu terminal para usar uma fonte compatível como:  
  - **MesloLGS NF** (recomendada pelo Powerlevel10k).  
  - **FiraCode Nerd Font**.  
  - **Hack Nerd Font**.

- Caso o prompt fique desalinhado, troque a fonte no terminal e rode novamente:

  ```bash
  p10k configure
  ```

- Você pode manter várias versões do `~/.p10k.zsh` como backup, caso queira alternar entre estilos.

---

## ✅ Conclusão

O `p10k configure` permite recriar seu ambiente visual de forma rápida e interativa.  
Com ele, você pode escolher entre estilos minimalistas, modernos ou até ultra coloridos, sempre com a possibilidade de ajustar manualmente o arquivo `~/.p10k.zsh`.

> ✨ Recomendo salvar seu `~/.p10k.zsh` no GitHub ou em um backup pessoal. Assim, se formatar o sistema, pode restaurar sua configuração visual em segundos.
