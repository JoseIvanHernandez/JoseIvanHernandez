# AI Development Assistant - Simple Version
# PowerShell companion for your C# development workflow

param(
    [string]$Mode = "interactive",
    [string]$ProjectPath = (Get-Location)
)

Write-Host "🚀 AI Development Assistant v2.0" -ForegroundColor Cyan
Write-Host "Project Path: $ProjectPath" -ForegroundColor Green

function Get-ProjectStats {
    Write-Host "`n🔍 Analyzing your project..." -ForegroundColor Cyan
    
    $CodeFiles = Get-ChildItem -Path $ProjectPath -Include *.cs, *.ps1, *.md -Recurse -ErrorAction SilentlyContinue
    
    $Stats = @{
        TotalFiles = $CodeFiles.Count
        CSharpFiles = ($CodeFiles | Where-Object { $_.Extension -eq ".cs" }).Count
        PowerShellFiles = ($CodeFiles | Where-Object { $_.Extension -eq ".ps1" }).Count
        MarkdownFiles = ($CodeFiles | Where-Object { $_.Extension -eq ".md" }).Count
        TotalLines = 0
        RecentFiles = ($CodeFiles | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }).Count
    }
    
    foreach ($file in $CodeFiles) {
        try {
            $lineCount = (Get-Content $file.FullName -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
            $Stats.TotalLines += $lineCount
        } catch {
            # Skip unreadable files
        }
    }
    
    Write-Host "📊 Project Statistics:" -ForegroundColor Green
    Write-Host "  • Total Files: $($Stats.TotalFiles)" -ForegroundColor White
    Write-Host "  • C# Files: $($Stats.CSharpFiles)" -ForegroundColor White
    Write-Host "  • PowerShell Files: $($Stats.PowerShellFiles)" -ForegroundColor White
    Write-Host "  • Markdown Files: $($Stats.MarkdownFiles)" -ForegroundColor White
    Write-Host "  • Total Lines of Code: $($Stats.TotalLines)" -ForegroundColor White
    Write-Host "  • Recently Modified: $($Stats.RecentFiles)" -ForegroundColor White
    
    # Show recent files
    Write-Host "`n📋 Recent Changes:" -ForegroundColor Cyan
    $RecentFiles = $CodeFiles | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) } | Sort-Object LastWriteTime -Descending | Select-Object -First 5
    
    if ($RecentFiles.Count -gt 0) {
        foreach ($file in $RecentFiles) {
            $timeAgo = [math]::Round(((Get-Date) - $file.LastWriteTime).TotalHours, 1)
            Write-Host "  • $($file.Name) (${timeAgo}h ago)" -ForegroundColor White
        }
    } else {
        Write-Host "  • No recent changes in the last 24 hours" -ForegroundColor Gray
    }
    
    return $Stats
}

function Analyze-CSharpFile {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "❌ File not found: $FilePath" -ForegroundColor Red
        return
    }
    
    try {
        $content = Get-Content $FilePath -Raw
        $fileName = Split-Path $FilePath -Leaf
        
        Write-Host "`n🧠 Analyzing $fileName..." -ForegroundColor Magenta
        
        # Count various code elements
        $lines = $content -split "`n"
        $classCount = ($content -split "class " | Measure-Object).Count - 1
        $methodCount = ($content -split "public\s+\w+\s+\w+\s*\(" | Measure-Object).Count - 1
        $methodCount += ($content -split "private\s+\w+\s+\w+\s*\(" | Measure-Object).Count - 1
        $commentCount = ($content -split "//" | Measure-Object).Count - 1
        $usingCount = ($content -split "using " | Measure-Object).Count - 1
        
        Write-Host "  📈 Code Metrics:" -ForegroundColor Green
        Write-Host "    • Lines: $($lines.Count)" -ForegroundColor White
        Write-Host "    • Classes: $classCount" -ForegroundColor White  
        Write-Host "    • Methods: $methodCount" -ForegroundColor White
        Write-Host "    • Comments: $commentCount" -ForegroundColor White
        Write-Host "    • Using statements: $usingCount" -ForegroundColor White
        
        # AI-style insights
        Write-Host "`n🎯 AI Insights:" -ForegroundColor Yellow
        
        if ($commentCount -lt ($methodCount * 0.5)) {
            Write-Host "    ⚠️ Consider adding more documentation" -ForegroundColor Yellow
        } else {
            Write-Host "    ✅ Good documentation coverage" -ForegroundColor Green
        }
        
        if ($lines.Count -gt 200) {
            Write-Host "    📏 Large file - consider refactoring into smaller classes" -ForegroundColor Yellow
        } else {
            Write-Host "    ✅ File size looks manageable" -ForegroundColor Green
        }
        
        if ($classCount -gt 3) {
            Write-Host "    🧩 Multiple classes in one file - consider splitting" -ForegroundColor Yellow
        }
        
        # Check for inheritance patterns
        if ($content -match ":\s*\w+") {
            Write-Host "    🧬 Inheritance detected - good OOP design!" -ForegroundColor Green
        }
        
        # Check for Unity-specific patterns
        if ($content -match "MonoBehaviour|GameObject|Transform") {
            Write-Host "    🎮 Unity script detected" -ForegroundColor Magenta
        }
        
    } catch {
        Write-Host "❌ Error analyzing file: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Watch-Files {
    param([int]$Minutes = 5)
    
    Write-Host "`n👁️ Watching for file changes for $Minutes minutes..." -ForegroundColor Cyan
    Write-Host "Edit any .cs file to see real-time analysis!" -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
    
    $endTime = (Get-Date).AddMinutes($Minutes)
    
    while ((Get-Date) -lt $endTime) {
        $recentChanges = Get-ChildItem -Path $ProjectPath -Include *.cs, *.ps1, *.md -Recurse -ErrorAction SilentlyContinue | 
                        Where-Object { $_.LastWriteTime -gt (Get-Date).AddSeconds(-5) }
        
        foreach ($file in $recentChanges) {
            $timeStamp = Get-Date -Format "HH:mm:ss"
            Write-Host "[$timeStamp] 📝 Change detected: $($file.Name)" -ForegroundColor Green
            
            if ($file.Extension -eq ".cs") {
                Analyze-CSharpFile -FilePath $file.FullName
            }
        }
        
        Start-Sleep -Seconds 2
    }
    
    Write-Host "`n🛑 File watching stopped" -ForegroundColor Red
}

function Show-Menu {
    Write-Host "`n🎯 AI Development Assistant Menu:" -ForegroundColor Cyan
    Write-Host "1. Analyze project statistics" -ForegroundColor White
    Write-Host "2. Analyze specific C# file" -ForegroundColor White
    Write-Host "3. Watch files for changes (5 min)" -ForegroundColor White
    Write-Host "4. Show recent git status" -ForegroundColor White
    Write-Host "5. List all C# files" -ForegroundColor White
    Write-Host "0. Exit" -ForegroundColor Red
    
    $choice = Read-Host "`nEnter your choice"
    return $choice
}

# Main execution
switch ($Mode.ToLower()) {
    "analyze" { 
        Get-ProjectStats
    }
    "watch" { 
        Watch-Files
    }
    "interactive" {
        do {
            $choice = Show-Menu
            
            switch ($choice) {
                "1" { Get-ProjectStats }
                "2" { 
                    $fileName = Read-Host "Enter C# filename (e.g., SuperBrain.cs)"
                    $fullPath = Join-Path $ProjectPath $fileName
                    Analyze-CSharpFile -FilePath $fullPath
                }
                "3" { Watch-Files }
                "4" { 
                    Write-Host "`n📊 Git Status:" -ForegroundColor Cyan
                    try {
                        git status 2>&1 | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
                    } catch {
                        Write-Host "Git not available or not a git repository" -ForegroundColor Yellow
                    }
                }
                "5" {
                    Write-Host "`n📁 C# Files in project:" -ForegroundColor Cyan
                    Get-ChildItem -Path $ProjectPath -Include *.cs -Recurse | ForEach-Object {
                        Write-Host "  • $($_.Name)" -ForegroundColor White
                    }
                }
            }
        } while ($choice -ne "0")
    }
    default {
        Write-Host "Usage: .\ai-assistant-simple.ps1 [-Mode interactive|analyze|watch]" -ForegroundColor Yellow
        Get-ProjectStats
    }
}

Write-Host "`n✨ AI Development Assistant complete!" -ForegroundColor Green
