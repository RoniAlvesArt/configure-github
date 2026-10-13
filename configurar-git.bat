@echo off
setlocal EnableExtensions
title Configurar Git Portatil

echo.
echo ==========================================
echo       CONFIGURACAO DO GIT PORTATIL
echo ==========================================
echo.

set "USB_ROOT=%~dp0"
set "GIT_DIR=%USB_ROOT%PortableGit"
set "GIT_EXE=%GIT_DIR%\cmd\git.exe"
set "SSH_KEYGEN=%GIT_DIR%\usr\bin\ssh-keygen.exe"
set "PROFILE=%GIT_DIR%\etc\profile"
set "GIT_HOME=%GIT_DIR%\home\aluno"
set "SSH_DIR=%GIT_HOME%\.ssh"

echo [1/6] Verificando a estrutura...

if not exist "%GIT_DIR%\" (
    echo ERRO: a pasta PortableGit nao foi encontrada.
    echo Coloque este arquivo ao lado da pasta PortableGit.
    goto FALHA
)

if not exist "%GIT_DIR%\git-bash.exe" (
    echo ERRO: git-bash.exe nao foi encontrado.
    goto FALHA
)

if not exist "%GIT_EXE%" (
    echo ERRO: cmd\git.exe nao foi encontrado.
    goto FALHA
)

if not exist "%SSH_KEYGEN%" (
    echo ERRO: ssh-keygen.exe nao foi encontrado.
    goto FALHA
)

if not exist "%PROFILE%" (
    echo ERRO: etc\profile nao foi encontrado.
    goto FALHA
)

if not exist "%GIT_HOME%\" mkdir "%GIT_HOME%"
if not exist "%GIT_HOME%\" (
    echo ERRO: nao foi possivel criar a pasta de configuracao.
    goto FALHA
)

if not exist "%SSH_DIR%\" mkdir "%SSH_DIR%"
if not exist "%SSH_DIR%\" (
    echo ERRO: nao foi possivel criar a pasta da chave SSH.
    goto FALHA
)

set "HOME=%GIT_HOME%"
set "PATH=%GIT_DIR%\cmd;%GIT_DIR%\usr\bin;%PATH%"

echo.
echo [2/6] Preparando o ambiente portatil...

findstr /C:"# BEGIN PORTABLE_HOME_CONFIG" "%PROFILE%" >nul 2>&1
if not errorlevel 1 goto PERFIL_PRONTO

if not exist "%PROFILE%.bak" (
    copy /y "%PROFILE%" "%PROFILE%.bak" >nul
    if errorlevel 1 (
        echo ERRO: nao foi possivel criar uma copia do perfil.
        goto FALHA
    )
)

(
    echo.
    echo # BEGIN PORTABLE_HOME_CONFIG
    echo export HOME="/home/aluno"
    echo # END PORTABLE_HOME_CONFIG
) >> "%PROFILE%"

if errorlevel 1 (
    echo ERRO: nao foi possivel configurar o ambiente portatil.
    goto FALHA
)

:PERFIL_PRONTO
echo Ambiente portatil verificado.

echo.
echo [3/6] Verificando a configuracao existente...

set "GIT_NAME="
set "GIT_EMAIL="

for /f "delims=" %%A in ('"%GIT_EXE%" config --global --get user.name 2^>nul') do set "GIT_NAME=%%A"
for /f "delims=" %%A in ('"%GIT_EXE%" config --global --get user.email 2^>nul') do set "GIT_EMAIL=%%A"

rem Se nome, e-mail e chave ja existem, nao reconfigura.
set "CONFIGURACAO_EXISTENTE="
if defined GIT_NAME if defined GIT_EMAIL if exist "%SSH_DIR%\id_ed25519" if exist "%SSH_DIR%\id_ed25519.pub" set "CONFIGURACAO_EXISTENTE=1"

if defined CONFIGURACAO_EXISTENTE goto JA_CONFIGURADO

echo.
echo Esta primeira configuracao solicitara apenas os dados ausentes.
echo.

if defined GIT_NAME goto NOME_PRONTO

set /p "GIT_NAME=Digite seu nome: "
if not defined GIT_NAME (
    echo ERRO: o nome nao pode ficar vazio.
    goto FALHA
)

"%GIT_EXE%" config --global user.name "%GIT_NAME%"
if errorlevel 1 (
    echo ERRO: nao foi possivel salvar o nome.
    goto FALHA
)

:NOME_PRONTO
echo Nome configurado: "%GIT_NAME%"

if defined GIT_EMAIL goto EMAIL_PRONTO

set /p "GIT_EMAIL=Digite seu e-mail: "
if not defined GIT_EMAIL (
    echo ERRO: o e-mail nao pode ficar vazio.
    goto FALHA
)

"%GIT_EXE%" config --global user.email "%GIT_EMAIL%"
if errorlevel 1 (
    echo ERRO: nao foi possivel salvar o e-mail.
    goto FALHA
)

:EMAIL_PRONTO
echo E-mail configurado: "%GIT_EMAIL%"

echo.
echo [4/6] Verificando a chave SSH...

if exist "%SSH_DIR%\id_ed25519" goto CHAVE_PRIVADA_EXISTE
if exist "%SSH_DIR%\id_ed25519.pub" goto CHAVE_PUBLICA_SEM_PRIVADA
goto CRIAR_CHAVE

:CHAVE_PRIVADA_EXISTE
if exist "%SSH_DIR%\id_ed25519.pub" goto CHAVE_PRONTA

echo A chave existente esta sem o arquivo complementar.
echo Tentando recuperar a chave para entrega.
echo Pode ser solicitada a senha que foi criada anteriormente.
echo.

"%SSH_KEYGEN%" -y -f "%SSH_DIR%\id_ed25519" > "%SSH_DIR%\id_ed25519.pub"

if errorlevel 1 (
    if exist "%SSH_DIR%\id_ed25519.pub" del "%SSH_DIR%\id_ed25519.pub" >nul 2>&1
    echo ERRO: nao foi possivel recuperar a chave.
    echo Verifique a senha da chave SSH.
    goto FALHA
)

if not exist "%SSH_DIR%\id_ed25519.pub" (
    echo ERRO: o arquivo da chave nao foi recuperado.
    goto FALHA
)

goto CHAVE_PRONTA

:CHAVE_PUBLICA_SEM_PRIVADA
echo ERRO: foi encontrada uma chave incompleta.
echo Procure o responsavel antes de criar outra chave.
goto FALHA

:CRIAR_CHAVE
echo Ainda nao existe uma chave SSH.
echo Agora sera criada uma nova chave.
echo Quando solicitado, digite uma senha e confirme-a.
echo A senha nao aparecera enquanto voce digita.
echo.

"%SSH_KEYGEN%" -t ed25519 -C "%GIT_EMAIL%" -f "%SSH_DIR%\id_ed25519"

if errorlevel 1 (
    echo ERRO: nao foi possivel criar a chave SSH.
    goto FALHA
)

if not exist "%SSH_DIR%\id_ed25519.pub" (
    echo ERRO: o arquivo da chave nao foi criado.
    goto FALHA
)

:CHAVE_PRONTA
echo Chave SSH encontrada.

goto RESULTADO

:JA_CONFIGURADO
echo.
echo ==========================================
echo ESTE GIT PORTATIL JA ESTA CONFIGURADO
echo ==========================================
echo.
echo A configuracao e a chave existentes serao preservadas.
echo Nenhuma nova chave sera criada.
echo.

:RESULTADO
echo.
echo [5/6] Testando o Git...

"%GIT_EXE%" --version
if errorlevel 1 (
    echo ERRO: o Git nao executou corretamente.
    goto FALHA
)

echo.
echo Configuracao registrada:
"%GIT_EXE%" config --global --show-origin --get-regexp "^(user\.name|user\.email)$"

echo.
echo [6/6] Sua chave SSH para cadastro:

echo.
type "%SSH_DIR%\id_ed25519.pub"
echo.

echo Copie a linha mostrada acima.

echo.
echo ==========================================
echo O QUE FAZER AGORA:
echo ==========================================
echo.
echo 1. Cadastre a chave copiada no GitHub.
echo 2. Acesse Settings ^> SSH and GPG keys ^> New SSH key.
echo 3. Cole a chave e salve.
echo.
echo ==========================================
echo PARA TESTAR DEPOIS:
echo ==========================================
echo Abra PortableGit\git-bash.exe e digite:
echo.
echo git --version
echo echo $HOME
echo ssh -T git@github.com
echo.
echo A senha da chave nao e exibida por este programa.
echo Nao compartilhe essa senha com outras pessoas.
echo.
pause
exit /b 0

:FALHA
echo.
echo ==========================================
echo CONFIGURACAO INTERROMPIDA
echo ==========================================
echo.
echo Leia a mensagem de erro acima.
echo Nenhuma chave existente sera substituida.
echo.
pause
exit /b 1