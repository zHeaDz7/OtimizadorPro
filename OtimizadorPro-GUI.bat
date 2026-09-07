@echo off
chcp 65001 >nul
title Otimizador Pro - GUI

:: Verifica se ja esta rodando como Administrador -- se nao, pede elevacao
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Pedindo permissao de Administrador...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0gui\main.ps1"
