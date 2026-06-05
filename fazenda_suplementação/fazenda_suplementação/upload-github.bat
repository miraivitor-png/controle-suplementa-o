@echo off
chcp 65001 >nul
title Upload — App Lançamento Diário

:: ============================================================
::  CONFIGURE AQUI antes de rodar pela primeira vez
:: ============================================================
set USUARIO=SEU-USUARIO-AQUI
set REPO=lancamento
:: ============================================================

echo.
echo  ╔══════════════════════════════════════════╗
echo  ║   Upload GitHub — App Lancamento Diario  ║
echo  ╚══════════════════════════════════════════╝
echo.

:: Verifica se o usuário configurou o nome
if "%USUARIO%"=="SEU-USUARIO-AQUI" (
    echo  [ATENÇÃO] Edite este arquivo .bat e preencha
    echo  a variável USUARIO com seu usuário do GitHub.
    echo.
    echo  Abra o arquivo upload-github.bat no Bloco de Notas,
    echo  troque SEU-USUARIO-AQUI pelo seu usuário e salve.
    echo.
    pause
    exit /b 1
)

:: Verifica se Git está instalado
git --version >nul 2>&1
if errorlevel 1 (
    echo  [ERRO] Git não encontrado no computador.
    echo  Baixe e instale em: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

:: Garante que o .bat roda a partir da sua própria pasta
cd /d "%~dp0"

echo  Pasta: %CD%
echo  Repositório: github.com/%USUARIO%/%REPO%
echo.

:: ── PRIMEIRO UPLOAD (pasta .git ainda não existe) ──────────
if not exist ".git" (

    echo  [1/5] Inicializando repositório Git...
    git init -q
    git branch -M main
    echo        OK

    echo  [2/5] Adicionando arquivos...
    git add .
    echo        OK

    echo  [3/5] Criando commit inicial...
    git commit -q -m "App lançamento diário — upload inicial"
    echo        OK

    echo  [4/5] Conectando ao GitHub...
    git remote add origin https://github.com/%USUARIO%/%REPO%.git
    echo        OK

    echo  [5/5] Enviando para o GitHub...
    echo.
    git push -u origin main

    if errorlevel 1 (
        echo.
        echo  ╔══════════════════════════════════════════════════╗
        echo  ║  DICA: Se pediu senha e falhou, o GitHub não     ║
        echo  ║  aceita mais senha comum — use um Token.         ║
        echo  ║                                                  ║
        echo  ║  Crie em: github.com → Settings →               ║
        echo  ║  Developer settings → Personal access tokens     ║
        echo  ║  → Tokens (classic) → Generate new token        ║
        echo  ║  Marque a permissão: "repo"                      ║
        echo  ║  Use o token gerado como senha no prompt acima.  ║
        echo  ╚══════════════════════════════════════════════════╝
        echo.
        pause
        exit /b 1
    )

) else (
:: ── ATUALIZAÇÃO (repo já existe, só sobe as mudanças) ──────

    echo  [1/3] Verificando arquivos alterados...
    git add .

    :: Checa se há algo para commitar
    git diff --cached --quiet
    if not errorlevel 1 (
        echo.
        echo  Nenhum arquivo foi alterado desde o último upload.
        echo  Nada a enviar.
        echo.
        pause
        exit /b 0
    )

    echo  [2/3] Criando commit com data e hora...
    for /f "tokens=2 delims==" %%I in (
        'wmic os get localdatetime /value'
    ) do set DT=%%I
    set MSG=Atualização %DT:~6,2%/%DT:~4,2%/%DT:~0,4% %DT:~8,2%:%DT:~10,2%
    git commit -q -m "%MSG%"
    echo        OK

    echo  [3/3] Enviando para o GitHub...
    echo.
    git push

    if errorlevel 1 (
        echo.
        echo  [ERRO] Falha no envio. Verifique sua conexão ou
        echo  se o repositório ainda existe no GitHub.
        echo.
        pause
        exit /b 1
    )

)

:: ── SUCESSO ────────────────────────────────────────────────
echo.
echo  ╔══════════════════════════════════════════════════════╗
echo  ║   ✓  ENVIADO COM SUCESSO!                           ║
echo  ║                                                      ║
echo  ║   URL do app (compartilhe com o peão):              ║
echo  ║   https://%USUARIO%.github.io/%REPO%/peao.html
echo  ║                                                      ║
echo  ║   Aguarde ~1 min para o GitHub Pages atualizar.     ║
echo  ╚══════════════════════════════════════════════════════╝
echo.
pause
