# SDD Kit — Install Script (Windows PowerShell)
# Supports: Claude Code and VS Code Copilot

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== SDD Kit Installer ===" -ForegroundColor Cyan
Write-Host "Source: $ScriptDir"
Write-Host ""

# ── Target selection ─────────────────────────────────────────────────────────

$installClaude = $true
$installVSCode = $false
$installSkillCreator = $false

$claudeChoice = Read-Host "Install for Claude Code? [Y/n]"
if ($claudeChoice -eq 'n' -or $claudeChoice -eq 'N') { $installClaude = $false }

$skillCreatorChoice = Read-Host "Install skill-creator? (lets the AI create new skills) [y/N]"
if ($skillCreatorChoice -eq 'y' -or $skillCreatorChoice -eq 'Y') { $installSkillCreator = $true }

$vsCodeUserDir = "$env:APPDATA\Code\User"
if (Test-Path $vsCodeUserDir) {
    $vsCodeChoice = Read-Host "VS Code detected. Install for VS Code Copilot? [Y/n]"
    if ($vsCodeChoice -ne 'n' -and $vsCodeChoice -ne 'N') { $installVSCode = $true }
} else {
    Write-Host "VS Code not detected — skipping VS Code Copilot." -ForegroundColor DarkGray
}

if (-not $installClaude -and -not $installVSCode) {
    Write-Host "Nothing to install. Exiting." -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# ── Helper: install skills to a target directory ─────────────────────────────

function Install-Skills {
    param([string]$SkillsDir)

    New-Item -ItemType Directory -Force -Path "$SkillsDir\_shared" | Out-Null
    Copy-Item "$ScriptDir\_shared-openspec-convention.md"  "$SkillsDir\_shared\openspec-convention.md"  -Force
    Copy-Item "$ScriptDir\_shared-persistence-contract.md" "$SkillsDir\_shared\persistence-contract.md" -Force
    Copy-Item "$ScriptDir\_shared-sdd-phase-common.md"     "$SkillsDir\_shared\sdd-phase-common.md"     -Force
    Copy-Item "$ScriptDir\_shared-skill-resolver.md"        "$SkillsDir\_shared\skill-resolver.md"       -Force

    $skills = @("sdd-init","sdd-explore","sdd-propose","sdd-spec","sdd-design","sdd-tasks","sdd-apply","sdd-verify","sdd-archive","sdd-onboard","work-unit-commits","chained-pr","judgment-day")
    foreach ($skill in $skills) {
        New-Item -ItemType Directory -Force -Path "$SkillsDir\$skill" | Out-Null
        Copy-Item "$ScriptDir\$skill.md" "$SkillsDir\$skill\SKILL.md" -Force
    }

    Copy-Item "$ScriptDir\sdd-apply-strict-tdd.md"  "$SkillsDir\sdd-apply\strict-tdd.md"        -Force
    Copy-Item "$ScriptDir\sdd-verify-strict-tdd.md" "$SkillsDir\sdd-verify\strict-tdd-verify.md" -Force

    # skill-creator (optional)
    if ($installSkillCreator) {
        New-Item -ItemType Directory -Force -Path "$SkillsDir\skill-creator" | Out-Null
        Copy-Item "$ScriptDir\skill-creator.md" "$SkillsDir\skill-creator\SKILL.md" -Force
    }

    # Custom skills from skills/ subfolder (optional)
    $customSkills = Get-ChildItem "$ScriptDir\skills\*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "TEMPLATE.md" }
    foreach ($customSkill in $customSkills) {
        $skillName = [System.IO.Path]::GetFileNameWithoutExtension($customSkill.Name)
        New-Item -ItemType Directory -Force -Path "$SkillsDir\$skillName" | Out-Null
        Copy-Item $customSkill.FullName "$SkillsDir\$skillName\SKILL.md" -Force
    }
}

# ── Claude Code ──────────────────────────────────────────────────────────────

if ($installClaude) {
    $ClaudeDir = "$env:USERPROFILE\.claude"
    Write-Host "→ Installing for Claude Code ($ClaudeDir)..." -ForegroundColor Yellow

    Install-Skills -SkillsDir "$ClaudeDir\skills"

    $CommandsDir = "$ClaudeDir\commands"
    New-Item -ItemType Directory -Force -Path $CommandsDir | Out-Null
    Copy-Item "$ScriptDir\commands\*.md" $CommandsDir -Force

    Write-Host "  ✓ Skills installed to ~/.claude/skills/" -ForegroundColor Green
    Write-Host "  ✓ Commands installed to ~/.claude/commands/" -ForegroundColor Green

    $ClaudeMd = "$ClaudeDir\CLAUDE.md"
    Write-Host ""
    Write-Host "─────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "Claude Code — NEXT STEP (manual)" -ForegroundColor White
    Write-Host "─────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Open: $ClaudeMd"
    Write-Host "If the file doesn't exist, create it."
    Write-Host ""
    Write-Host "1. (Optional) Add the PERSONA section:"
    Write-Host "   Copy content from: $ScriptDir\CLAUDE-persona.md"
    Write-Host ""
    Write-Host "2. (Required) Add the SDD ORCHESTRATOR section:"
    Write-Host "   Copy content from: $ScriptDir\CLAUDE-sdd-orchestrator.md"
    Write-Host ""
    Write-Host "Wrap each block in markers:"
    Write-Host ""
    Write-Host "  <!-- sdd:persona -->"           -ForegroundColor DarkGray
    Write-Host "  [content of CLAUDE-persona.md]" -ForegroundColor DarkGray
    Write-Host "  <!-- /sdd:persona -->"           -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  <!-- sdd:orchestrator -->"                    -ForegroundColor DarkGray
    Write-Host "  [content of CLAUDE-sdd-orchestrator.md]"     -ForegroundColor DarkGray
    Write-Host "  <!-- /sdd:orchestrator -->"                   -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "─────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
}

# ── VS Code Copilot ──────────────────────────────────────────────────────────

if ($installVSCode) {
    $CopilotSkillsDir = "$env:USERPROFILE\.copilot\skills"
    $PromptsDir       = "$vsCodeUserDir\prompts"

    Write-Host "→ Installing for VS Code Copilot..." -ForegroundColor Yellow

    Install-Skills -SkillsDir $CopilotSkillsDir

    New-Item -ItemType Directory -Force -Path $PromptsDir | Out-Null
    Copy-Item "$ScriptDir\sdd.instructions.md" "$PromptsDir\sdd.instructions.md" -Force

    Write-Host "  ✓ Skills installed to ~/.copilot/skills/" -ForegroundColor Green
    Write-Host "  ✓ sdd.instructions.md installed to Code\User\prompts\" -ForegroundColor Green

    Write-Host ""
    Write-Host "─────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "VS Code Copilot — NEXT STEP (manual)" -ForegroundColor White
    Write-Host "─────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Enable instructions files in VS Code settings:"
    Write-Host "  Open: File > Preferences > Settings"
    Write-Host "  Search: github.copilot.chat.codeGeneration.useInstructionFiles"
    Write-Host "  Set to: true"
    Write-Host ""
    Write-Host "To verify: open Copilot Chat in VS Code and type /sdd-init"
    Write-Host "─────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
}

# ── Done ─────────────────────────────────────────────────────────────────────

Write-Host "=== Installation complete ===" -ForegroundColor Cyan
Write-Host ""
if ($installClaude) {
    Write-Host "Claude Code: open any project and type /sdd-init" -ForegroundColor White
}
if ($installVSCode) {
    Write-Host "VS Code:     open Copilot Chat and type /sdd-init" -ForegroundColor White
}
