# DSpace Project Cleanup Script
# Removes unnecessary and duplicate files to streamline the project

Write-Host "🧹 DSpace Project Cleanup" -ForegroundColor Green
Write-Host "========================="

$filesToRemove = @(
    # Duplicate Docker Compose files (we use the main docker-compose.yml)
    "dspace-source\docker-compose.yml",
    "dspace-source\docker-compose-cli.yml",
    
    # Unnecessary documentation PDF (we have README.md files)
    "Installing DSpace - DSpace 9.x Documentation - LYRASIS Wiki.pdf",
    
    # Original DSpace Dockerfiles (we use custom ones in docker/ directory)
    "dspace-source\Dockerfile",
    "dspace-source\Dockerfile.cli", 
    "dspace-source\Dockerfile.dependencies",
    "dspace-source\Dockerfile.test"
)

$removedCount = 0
$totalSize = 0

foreach ($file in $filesToRemove) {
    $fullPath = Join-Path $PWD $file
    if (Test-Path $fullPath) {
        try {
            $fileInfo = Get-Item $fullPath
            $size = $fileInfo.Length
            $totalSize += $size
            
            Remove-Item $fullPath -Force
            Write-Host "✅ Removed: $file ($([math]::Round($size/1MB, 2)) MB)" -ForegroundColor Green
            $removedCount++
        }
        catch {
            Write-Host "❌ Failed to remove: $file" -ForegroundColor Red
        }
    }
    else {
        Write-Host "⚠️  Not found: $file" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "📊 Cleanup Summary:" -ForegroundColor Cyan
Write-Host "   Files removed: $removedCount"
Write-Host "   Space freed: $([math]::Round($totalSize/1MB, 2)) MB"

if ($removedCount -gt 0) {
    Write-Host ""
    Write-Host "🎉 Project cleanup completed successfully!" -ForegroundColor Green
    Write-Host "   Your DSpace project is now streamlined and ready to use."
}

Read-Host "`nPress Enter to continue"
