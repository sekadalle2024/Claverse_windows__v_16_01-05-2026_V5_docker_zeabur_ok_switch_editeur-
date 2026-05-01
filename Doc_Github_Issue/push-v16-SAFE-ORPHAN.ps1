# Script de push V16 avec branche orpheline (Protection Secrets + Gros Fichiers)
# Date: 01 Mai 2026

$ErrorActionPreference = "Continue"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  Push ClaraVerse V16 SAFE (Orphan Branch Strategy)              " -ForegroundColor Cyan
Write-Host "  Repository: https://github.com/sekadalle2024/Claverse_windows__v_16_01-05-2026_V5_docker_zeabur_ok_switch_editeur-.git"
Write-Host "=================================================================" -ForegroundColor Cyan

$repoUrl = "https://github.com/sekadalle2024/Claverse_windows__v_16_01-05-2026_V5_docker_zeabur_ok_switch_editeur-.git"
$branche = "master"
$tempBranch = "v16_clean_backup"

# 1. Configuration Git
git config core.compression 0
git config http.postBuffer 1048576000

# 2. Creation d'une branche orpheline (historique propre)
Write-Host "Creation d'une branche orpheline pour eviter les secrets passes..." -ForegroundColor Yellow
git checkout --orphan $tempBranch
git rm -rf --cached . 2>$null
Write-Host "Branche orpheline cree." -ForegroundColor Green

# 3. Remote
git remote set-url origin $repoUrl 2>$null
if ($LASTEXITCODE -ne 0) { git remote add origin $repoUrl }

# Fonction Push
function Push-WithRetry {
    param([string]$chunk)
    for ($i=1; $i -le 3; $i++) {
        Write-Host "  Push $chunk (Tentative $i/3)..." -ForegroundColor Gray
        git push origin $tempBranch`:$branche -f
        if ($LASTEXITCODE -eq 0) { return $true }
        Start-Sleep -Seconds 5
    }
    return $false
}

# CHUNKS
Write-Host "Debut du push par chunks..." -ForegroundColor Cyan

# Chunk 1: src
if (Test-Path "src") {
    Write-Host "Chunk 1: src..." -ForegroundColor Yellow
    git add src/
    git commit -m "V16 - Part 1: src"
    if (-not (Push-WithRetry "src")) { exit 1 }
}

# Chunk 2: py_backend
if (Test-Path "py_backend") {
    Write-Host "Chunk 2: py_backend..." -ForegroundColor Yellow
    git add py_backend/
    git commit -m "V16 - Part 2: py_backend"
    if (-not (Push-WithRetry "py_backend")) { exit 1 }
}

# Chunk 3: docs dossiers
Write-Host "Chunk 3: Docs Dossiers..." -ForegroundColor Yellow
git add "Doc menu demarrer/" "Doc export rapport/" "Doc_Lead_Balance/" "Doc_Etat_Fin/" 2>$null
git commit -m "V16 - Part 3: Documentation Dossiers"
if (-not (Push-WithRetry "Docs Dossiers")) { exit 1 }

# Chunk 4: docs fichiers
Write-Host "Chunk 4: Docs Fichiers..." -ForegroundColor Yellow
git add *.md *.txt "Doc_Github_Issue/" "Doc backend github/" 2>$null
git commit -m "V16 - Part 4: Documentation Fichiers"
if (-not (Push-WithRetry "Docs Fichiers")) { exit 1 }

# Chunk 5: Reste
Write-Host "Chunk 5: Reste..." -ForegroundColor Yellow
git add .
git commit -m "V16 - Part 5: Restants"
if (-not (Push-WithRetry "Restants")) { exit 1 }

Write-Host "=================================================================" -ForegroundColor Green
Write-Host "           SAUVEGARDE TERMINEE AVEC SUCCES                       " -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green
