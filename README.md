# Configurar Git e GitHub

**Git** registra o histórico das alterações dos arquivos. **GitHub** é um site para guardar e compartilhar projetos Git.

Antes de começar, [crie uma conta no GitHub](https://github.com/signup).

## Recomendado: usar o Git pelo pendrive

1. Baixe o [Git for Windows Portable (64 bits)](https://git-scm.com/downloads/win). Na página, escolha **Portable** para **Windows/x64**.
2. Execute o arquivo baixado e extraia-o no pendrive. A pasta deve se chamar `PortableGit` e conter `git-bash.exe`.
3. Coloque `configurar-git.bat` que você vai encontrar nesse repositório na raiz do pendrive, ao lado da pasta `PortableGit`.
4. Execute `configurar-git.bat`. Informe seu nome e o e-mail usado no GitHub. Se for solicitado, crie uma senha para a chave SSH.

> **Atenção:** ao digitar a senha, os caracteres não aparecem na tela. Isso é normal. Guarde a senha: ela poderá ser solicitada ao acessar o GitHub pelo Git.

### Cadastrar a chave no GitHub

1. No pendrive, abra `PortableGit\home\aluno\.ssh` e abra o arquivo `id_ed25519.pub` com o Bloco de Notas.
2. Copie todo o conteúdo do arquivo.
3. No GitHub, acesse **Settings** (Configurações) → **SSH and GPG keys** (Chaves SSH e GPG) → **New SSH key** (Nova chave SSH).
4. Em **Title** (Título), escreva `Pendrive`. Cole o conteúdo copiado em **Key** (Chave) e clique em **Add SSH key** (Adicionar chave SSH).

**Importante:** copie apenas o conteúdo de `id_ed25519.pub`. Não envie o arquivo `id_ed25519` nem compartilhe sua senha.

### Usar nas próximas aulas

Abra `PortableGit\git-bash.exe`. Não precisa executar `configurar-git.bat` novamente.

Você pode testar se o Git está funcionando com:

```bash
git --version
```

Depois de cadastrar a chave, teste o acesso ao GitHub com:

```bash
ssh -T git@github.com
```

## Alternativa: instalar no computador

1. Na [página oficial do Git para Windows](https://git-scm.com/downloads/win), baixe **Standalone Installer** para **Windows/x64** e instale usando as opções padrão.
2. Abra **Git Bash** pelo menu Iniciar e configure seu nome e e-mail:

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu-email@exemplo.com"
```

3. Se ainda não tiver uma chave SSH nesse computador, crie uma:

```bash
ssh-keygen -t ed25519 -C "seu-email@exemplo.com"
```

Pressione Enter para aceitar o local sugerido. Para mostrar a chave que deve ser cadastrada no GitHub, execute:

```bash
cat ~/.ssh/id_ed25519.pub
```

Copie o resultado e siga os passos de cadastro no GitHub descritos acima.
