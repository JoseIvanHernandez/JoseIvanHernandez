# AI Development Assistant - PowerShell Companion
# Works with your C# AIFileInspector for complete workflow automation

param(
    [string]$Mode = "interactive",
    [string]$ProjectPath = (Get-Location),
    [switch]$EnableAI
)

# ===============================================
# 🧠 AI-Powered Development Workflow
# ===============================================

Write-Host "🚀 AI Development Assistant Initialized" -ForegroundColor Cyan
Write-Host "Project Path: $ProjectPath" -ForegroundColor Green

# AI Configuration (if API key is available)
$HasOpenAI = $env:OPENAI_API_KEY -ne $null -and $env:OPENAI_API_KEY -ne ""

if ($HasOpenAI -and $EnableAI) {
    Write-Host "🧠 OpenAI API Available - Enhanced AI features enabled" -ForegroundColor Magenta
} else {
    Write-Host "💡 Local AI features only - Set OPENAI_API_KEY for full capabilities" -ForegroundColor Yellow
}

# ===============================================
# 📁 Smart File Analysis Functions
# ===============================================

function Get-ProjectInsights {
    param([string]$Path = $ProjectPath)
    
    Write-Host "`n🔍 Analyzing project structure..." -ForegroundColor Cyan
    
    # Get all code files
    $CodeFiles = Get-ChildItem -Path $Path -Recurse -Include *.cs, *.ps1, *.py, *.js, *.ts -ErrorAction SilentlyContinue
    
    # Basic metrics
    $Stats = @{
        TotalFiles = $CodeFiles.Count
        CSharpFiles = ($CodeFiles | Where-Object { $_.Extension -eq ".cs" }).Count
        PowerShellFiles = ($CodeFiles | Where-Object { $_.Extension -eq ".ps1" }).Count
        TotalLines = 0
        RecentlyModified = ($CodeFiles | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }).Count
    }
    
    # Count total lines
    foreach ($file in $CodeFiles) {
        try {
            $lineCount = (Get-Content $file.FullName -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
            $Stats.TotalLines += $lineCount
        } catch {
            # Skip files that can't be read
        }
    }
    
    Write-Host "📊 Project Statistics:" -ForegroundColor Green
    Write-Host "  • Total Code Files: $($Stats.TotalFiles)" -ForegroundColor White
    Write-Host "  • C# Files: $($Stats.CSharpFiles)" -ForegroundColor White
    Write-Host "  • PowerShell Files: $($Stats.PowerShellFiles)" -ForegroundColor White
    Write-Host "  • Total Lines: $($Stats.TotalLines)" -ForegroundColor White
    Write-Host "  • Recently Modified: $($Stats.RecentlyModified)" -ForegroundColor White
    
    return $Stats
}

function Watch-CodeChanges {
    param(
        [string]$Path = $ProjectPath,
        [int]$DurationMinutes = 30
    )
    
    Write-Host "`n👁️ Watching for code changes for $DurationMinutes minutes..." -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
    
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $Path
    $watcher.Filter = "*.*"
    $watcher.IncludeSubdirectories = $true
    
    # Define the event action
    $action = {
        $path = $Event.SourceEventArgs.FullPath
        $changeType = $Event.SourceEventArgs.ChangeType
        $timeStamp = Get-Date -Format "HH:mm:ss"
        
        # Only log code files
        if ($path -match '\.(cs|ps1|py|js|ts|md)$') {
            $fileName = Split-Path $path -Leaf
            Write-Host "[$timeStamp] $changeType - $fileName" -ForegroundColor Green
            
            # AI Enhancement: Analyze the change if it's a C# file
            if ($path.EndsWith('.cs') -and $HasOpenAI -and $EnableAI) {
                Invoke-AICodeAnalysis -FilePath $path -ChangeType $changeType
            }
        }
    }
    
    # Register event handlers
    Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action
    Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action $action
    Register-ObjectEvent -InputObject $watcher -EventName "Deleted" -Action $action
    
    $watcher.EnableRaisingEvents = $true
    
    try {
        # Wait for the specified duration
        Start-Sleep -Seconds ($DurationMinutes * 60)
    } finally {
        $watcher.EnableRaisingEvents = $false
        $watcher.Dispose()
        Get-EventSubscriber | Unregister-Event
        Write-Host "`n🛑 File watching stopped" -ForegroundColor Red
    }
}

function Invoke-AICodeAnalysis {
    param(
        [string]$FilePath,
        [string]$ChangeType = "Modified"
    )
    
    if (-not $HasOpenAI) {
        return
    }
    
    try {
        $fileName = Split-Path $FilePath -Leaf
        $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue
        
        if ($content.Length -gt 0 -and $content.Length -lt 4000) {
            Write-Host "  🧠 AI analyzing $fileName..." -ForegroundColor Magenta
            
            # Simple local analysis for now
            $lines = $content -split "`n"
            $classCount = ($content | Select-String "class " -AllMatches).Matches.Count
            $methodCount = ($content | Select-String "(public|private|protected).*\(" -AllMatches).Matches.Count
            $commentCount = ($content | Select-String "//" -AllMatches).Matches.Count
            
            Write-Host "    • Classes: $classCount, Methods: $methodCount, Comments: $commentCount" -ForegroundColor Gray
            
            if ($commentCount -lt ($methodCount * 0.3)) {
                Write-Host "    ⚠️ Consider adding more documentation" -ForegroundColor Yellow
            }
            
            if ($lines.Count -gt 200) {
                Write-Host "    📏 Large file - consider refactoring" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "    ❌ Could not analyze $fileName" -ForegroundColor Red
    }
}
}

function Start-AIWorkflow {
    Write-Host "`n🤖 Starting AI-Enhanced Development Workflow" -ForegroundColor Magenta
    
    # Step 1: Analyze current project
    $insights = Get-ProjectInsights
    
    # Step 2: Show recent changes
    Write-Host "`n📋 Recent Changes:" -ForegroundColor Cyan
    Get-ChildItem -Path $ProjectPath -Recurse -Include *.cs, *.ps1 | 
        Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-24) } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 10 |
        ForEach-Object {
            $timeAgo = [math]::Round(((Get-Date) - $_.LastWriteTime).TotalHours, 1)
            Write-Host "  • $($_.Name) (${timeAgo}h ago)" -ForegroundColor White
        }
    
    # Step 3: Interactive menu
    do {
        Write-Host "`n🎯 Choose an action:" -ForegroundColor Cyan
        Write-Host "1. Watch code changes in real-time" -ForegroundColor White
        Write-Host "2. Analyze specific file" -ForegroundColor White
        Write-Host "3. Generate project README" -ForegroundColor White
        Write-Host "4. Run build checks" -ForegroundColor White
        Write-Host "5. Git status and suggestions" -ForegroundColor White
        Write-Host "0. Exit" -ForegroundColor Red
        
        $choice = Read-Host "Enter choice"
        
        switch ($choice) {
            "1" { 
                $duration = Read-Host "Watch duration in minutes (default: 30)"
                if ([string]::IsNullOrWhiteSpace($duration)) { $duration = 30 }
                Watch-CodeChanges -DurationMinutes $duration
            }
            "2" { 
                $file = Read-Host "File path (relative to project)"
                if (Test-Path (Join-Path $ProjectPath $file)) {
                    Invoke-AICodeAnalysis -FilePath (Join-Path $ProjectPath $file)
                } else {
                    Write-Host "File not found" -ForegroundColor Red
                }
            }
            "3" { 
                Write-Host "🚧 README generation - Coming soon!" -ForegroundColor Yellow
            }
            "4" { 
                Write-Host "🔍 Running build checks..." -ForegroundColor Cyan
                if (Test-Path "*.csproj") {
                    dotnet build 2>&1 | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
                } else {
                    Write-Host "No .csproj file found" -ForegroundColor Yellow
                }
            }
            "5" { 
                Write-Host "📊 Git Status:" -ForegroundColor Cyan
                git status 2>&1 | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
            }
        }
    } while ($choice -ne "0")
}

# ===============================================
# 🚀 Main Execution
# ===============================================

switch ($Mode.ToLower()) {
    "interactive" { Start-AIWorkflow }
    "watch" { Watch-CodeChanges }
    "analyze" { Get-ProjectInsights }
    default { 
        Write-Host "Usage: .\ai-assistant.ps1 [-Mode interactive|watch|analyze] [-EnableAI]" -ForegroundColor Yellow
        Get-ProjectInsights
    }
}

Write-Host "`n✨ AI Development Assistant session complete" -ForegroundColor Green
