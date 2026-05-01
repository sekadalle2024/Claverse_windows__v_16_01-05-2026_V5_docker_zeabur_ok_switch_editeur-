# Nettoyage global des secrets (Version Optimisee)
Write-Host "Nettoyage global des secrets (Google OAuth) - Version Rapide..." -ForegroundColor Yellow

$idPattern = '(\d{12}-[a-z0-9]{32}\.apps\.googleusercontent\.com)'
$secretPattern = '(GOCSPX-[a-zA-Z0-9_-]{28})'

# Liste des fichiers a ignorer
$excludeDirs = @("node_modules", ".git", ".netlify", ".kiro", ".hypothesis", ".pytest_cache")

# On recupere tous les fichiers textes interessants en ignorant les dossiers lourds
$files = Get-ChildItem -Path . -Recurse | Where-Object { 
    $_.FullName -notmatch ($excludeDirs -join "|") -and 
    $_.Extension -in @(".txt", ".md", ".js", ".tsx", ".ts", ".json", ".html") 
}

foreach ($file in $files) {
    if ($file.Attributes -match "Directory") { continue }
    
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if ([string]::IsNullOrWhiteSpace($content)) { continue }

    if ($content -match $idPattern -or $content -match $secretPattern) {
        Write-Host "Nettoyage: $($file.FullName)" -ForegroundColor Cyan
        $content = $content -replace $idPattern, '[VOTRE_GOOGLE_CLIENT_ID]'
        $content = $content -replace $secretPattern, '[VOTRE_GOOGLE_CLIENT_SECRET]'
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "  OK" -ForegroundColor Green
    }
}

Write-Host "Nettoyage global termine!" -ForegroundColor Green
