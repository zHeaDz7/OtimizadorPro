@echo off
chcp 65001 >nul
title Otimizador Pro

:: Verifica se ja esta rodando como Administrador -- se nao, pede elevacao
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Pedindo permissao de Administrador...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\_menu.ps1"
