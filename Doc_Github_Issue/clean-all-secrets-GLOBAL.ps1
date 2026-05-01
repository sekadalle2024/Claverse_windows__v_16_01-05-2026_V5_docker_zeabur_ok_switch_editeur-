# Nettoyage global des secrets dans tous les fichiers texte et markdown
Write-Host "Nettoyage global des secrets (Google OAuth)..." -ForegroundColor Yellow

# On cherche tous les fichiers .txt, .md, .js, .tsx, .ts, .json dans le projet (excluant node_modules)
$files = Get-ChildItem -Path . -Include *.txt, *.md, *.js, *.tsx, *.ts, *.json, *.html -Recurse -Exclude "node_modules", ".git", ".netlify"

$idPattern = '(\d{12}-[a-z0-9]{32}\.apps\.googleusercontent\.com)'
$secretPattern = '(GOCSPX-[a-zA-Z0-9_-]{28})'

foreach ($file in $files) {
    $filePath = $file.FullName
    $content = Get-Content $filePath -Raw
    
    $hasId = $content -match $idPattern
    $hasSecret = $content -match $secretPattern
    
    if ($hasId -or $hasSecret) {
        Write-Host "Nettoyage: $($file.FullName)" -ForegroundColor Cyan
        $content = $content -replace $idPattern, '[VOTRE_GOOGLE_CLIENT_ID]'
        $content = $content -replace $secretPattern, '[VOTRE_GOOGLE_CLIENT_SECRET]'
        Set-Content -Path $filePath -Value $content -NoNewline
        Write-Host "  OK" -ForegroundColor Green
    }
}

Write-Host "Nettoyage global termine!" -ForegroundColor Green
