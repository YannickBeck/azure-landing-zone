#!/usr/bin/env pwsh
# =============================================================================
# Azure Landing Zone – Kunden-Minimal GUI Deployment
# Verwendung: .\deploy-gui.ps1
# Voraussetzung: Windows mit .NET / PowerShell 5.1+
# =============================================================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ── Bechtle Brand Colors ────────────────────────────────
$C_DARK    = [System.Drawing.Color]::FromArgb(5,  59,  37)   # #053B25
$C_MID     = [System.Drawing.Color]::FromArgb(7,  80,  51)   # #075033
$C_GREEN   = [System.Drawing.Color]::FromArgb(35, 169, 106)  # #23A96A
$C_LIME    = [System.Drawing.Color]::FromArgb(170, 222, 12)  # #AADE0C
$C_BG      = [System.Drawing.Color]::FromArgb(245, 248, 246)
$C_PANEL   = [System.Drawing.Color]::FromArgb(235, 242, 238)
$C_GREY    = [System.Drawing.Color]::FromArgb(100, 100, 100)

# ── Konfig-Datei (auto-save / auto-load) ───────────────
$ConfigFile = Join-Path $PSScriptRoot "deploy-config.json"

function Load-SavedConfig {
    if (Test-Path $ConfigFile) {
        try { return Get-Content $ConfigFile -Raw | ConvertFrom-Json }
        catch { return $null }
    }
    return $null
}

function Save-CurrentConfig($obj) {
    $obj | ConvertTo-Json -Depth 3 | Set-Content $ConfigFile -Encoding UTF8
}

# ── Haupt-Fenster ───────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text      = "Azure Landing Zone – Kunden-Minimal Deployment"
$form.Size      = New-Object System.Drawing.Size(740, 840)
$form.MinimumSize = New-Object System.Drawing.Size(740, 840)
$form.MaximumSize = New-Object System.Drawing.Size(740, 840)
$form.StartPosition = "CenterScreen"
$form.BackColor = $C_BG
$form.Font      = New-Object System.Drawing.Font("Segoe UI", 9)
$form.Icon      = [System.Drawing.SystemIcons]::Application

# ── Header ─────────────────────────────────────────────
$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Dock      = "Top"
$pnlHeader.Height    = 72
$pnlHeader.BackColor = $C_DARK
$form.Controls.Add($pnlHeader)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text      = "Azure Landing Zone  —  Kunden-Minimal"
$lblTitle.Font      = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = [System.Drawing.Color]::White
$lblTitle.Location  = New-Object System.Drawing.Point(18, 10)
$lblTitle.AutoSize  = $true
$pnlHeader.Controls.Add($lblTitle)

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text      = "3 Subscriptions  ·  8 Management Groups  ·  ~€765 / Monat"
$lblSub.Font      = New-Object System.Drawing.Font("Segoe UI", 9)
$lblSub.ForeColor = $C_LIME
$lblSub.Location  = New-Object System.Drawing.Point(20, 44)
$lblSub.AutoSize  = $true
$pnlHeader.Controls.Add($lblSub)

# ── Hilfs-Funktion: Label + TextBox ────────────────────
function New-Field {
    param($Parent, [string]$Label, [string]$Hint="", [int]$Y, [bool]$Optional=$false, [bool]$Password=$false)

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text      = if ($Optional) { "$Label  (optional)" } else { $Label }
    $lbl.Font      = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $lbl.ForeColor = if ($Optional) { $C_GREY } else { $C_DARK }
    $lbl.Location  = New-Object System.Drawing.Point(16, ($Y + 2))
    $lbl.Size      = New-Object System.Drawing.Size(210, 20)
    $Parent.Controls.Add($lbl)

    $txt = New-Object System.Windows.Forms.TextBox
    $txt.Location    = New-Object System.Drawing.Point(232, $Y)
    $txt.Size        = New-Object System.Drawing.Size(418, 24)
    $txt.Font        = New-Object System.Drawing.Font("Consolas", 9)
    $txt.BorderStyle = "FixedSingle"
    $txt.BackColor   = [System.Drawing.Color]::White
    if ($Password) { $txt.PasswordChar = "●" }
    if ($Hint) {
        $txt.Text      = $Hint
        $txt.ForeColor = [System.Drawing.Color]::Silver
        $txt.Add_Enter({
            if ($this.ForeColor -eq [System.Drawing.Color]::Silver) {
                $this.Text = ""; $this.ForeColor = [System.Drawing.Color]::Black
            }
        })
        $txt.Add_Leave({
            if ([string]::IsNullOrWhiteSpace($this.Text)) {
                $this.Text = $Hint; $this.ForeColor = [System.Drawing.Color]::Silver
            }
        })
    }
    $Parent.Controls.Add($txt)
    return $txt
}

function Get-FieldValue($txt, $Hint) {
    if ($txt.ForeColor -eq [System.Drawing.Color]::Silver) { return "" }
    return $txt.Text.Trim()
}

# ── Sektion: Zugangsdaten ───────────────────────────────
$grpCreds = New-Object System.Windows.Forms.GroupBox
$grpCreds.Text      = "  Azure Zugangsdaten"
$grpCreds.Font      = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$grpCreds.ForeColor = $C_DARK
$grpCreds.BackColor = $C_BG
$grpCreds.Location  = New-Object System.Drawing.Point(14, 82)
$grpCreds.Size      = New-Object System.Drawing.Size(706, 210)
$form.Controls.Add($grpCreds)

$txtTenant  = New-Field $grpCreds "Tenant ID *"              "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" 28
$txtConnSub = New-Field $grpCreds "Connectivity Sub ID *"    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" 63
$txtProdSub = New-Field $grpCreds "Produktion Sub ID"        "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" 98  $true
$txtSandSub = New-Field $grpCreds "Sandbox Sub ID"           "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" 133 $true

$lblReg = New-Object System.Windows.Forms.Label
$lblReg.Text      = "Region"
$lblReg.Font      = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$lblReg.ForeColor = $C_DARK
$lblReg.Location  = New-Object System.Drawing.Point(16, 172)
$lblReg.AutoSize  = $true
$grpCreds.Controls.Add($lblReg)

$cboRegion = New-Object System.Windows.Forms.ComboBox
$cboRegion.Location      = New-Object System.Drawing.Point(232, 169)
$cboRegion.Size          = New-Object System.Drawing.Size(300, 24)
$cboRegion.DropDownStyle = "DropDownList"
$cboRegion.Font          = New-Object System.Drawing.Font("Segoe UI", 9)
$cboRegion.Items.AddRange(@(
    "germanywestcentral  (Kunden-Minimal – empfohlen)",
    "germanywestcentral + northeurope  (Geo-Redundanz ~€1.800)"
))
$cboRegion.SelectedIndex = 0
$grpCreds.Controls.Add($cboRegion)

# ── Sektion: Deployment-Umfang ──────────────────────────
$grpScope = New-Object System.Windows.Forms.GroupBox
$grpScope.Text      = "  Deployment-Umfang"
$grpScope.Font      = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$grpScope.ForeColor = $C_DARK
$grpScope.BackColor = $C_BG
$grpScope.Location  = New-Object System.Drawing.Point(14, 304)
$grpScope.Size      = New-Object System.Drawing.Size(706, 180)
$form.Controls.Add($grpScope)

function New-CheckRow {
    param($Parent, [string]$Title, [string]$Desc, [string]$Cost="", [int]$X, [int]$Y, [bool]$Checked=$true)

    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text      = $Title
    $cb.Font      = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $cb.ForeColor = $C_DARK
    $cb.Location  = New-Object System.Drawing.Point($X, $Y)
    $cb.Size      = New-Object System.Drawing.Size(320, 22)
    $cb.Checked   = $Checked
    $Parent.Controls.Add($cb)

    $lDesc = New-Object System.Windows.Forms.Label
    $lDesc.Text      = $Desc
    $lDesc.Font      = New-Object System.Drawing.Font("Segoe UI", 8)
    $lDesc.ForeColor = $C_GREY
    $lDesc.Location  = New-Object System.Drawing.Point(($X + 22), ($Y + 21))
    $lDesc.Size      = New-Object System.Drawing.Size(270, 14)
    $Parent.Controls.Add($lDesc)

    if ($Cost) {
        $lCost = New-Object System.Windows.Forms.Label
        $lCost.Text      = $Cost
        $lCost.Font      = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
        $lCost.ForeColor = $C_GREEN
        $lCost.Location  = New-Object System.Drawing.Point(($X + 296), $Y)
        $lCost.AutoSize  = $true
        $Parent.Controls.Add($lCost)
    }
    return $cb
}

$chkMG      = New-CheckRow $grpScope "Management Groups (8 MGs)"  "alz + 149 Policies + 118 Assignments + RBAC"  ""          16  22
$chkLogging = New-CheckRow $grpScope "Logging"                     "Log Analytics in Connectivity Sub"             "~€50/Mon"  16  65
$chkNetwork = New-CheckRow $grpScope "Hub Networking"              "Azure Firewall Standard in Connectivity Sub"   "~€700/Mon" 370 22
$chkSpoke   = New-CheckRow $grpScope "Spoke Networking"            "Erstes VNet in Produktion Sub"                 ""          370 65  $false

$lblWI = New-Object System.Windows.Forms.Label
$lblWI.Text      = "Simulation / What-If:"
$lblWI.Font      = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$lblWI.ForeColor = $C_DARK
$lblWI.Location  = New-Object System.Drawing.Point(16, 138)
$lblWI.AutoSize  = $true
$grpScope.Controls.Add($lblWI)

$chkWhatIf = New-Object System.Windows.Forms.CheckBox
$chkWhatIf.Text      = "What-If (zeigt Änderungen, deployt nichts)"
$chkWhatIf.Font      = New-Object System.Drawing.Font("Segoe UI", 9)
$chkWhatIf.ForeColor = [System.Drawing.Color]::FromArgb(160, 80, 0)
$chkWhatIf.Location  = New-Object System.Drawing.Point(175, 135)
$chkWhatIf.Size      = New-Object System.Drawing.Size(340, 22)
$chkWhatIf.Checked   = $false
$grpScope.Controls.Add($chkWhatIf)

# ── Button-Leiste ───────────────────────────────────────
$pnlButtons = New-Object System.Windows.Forms.Panel
$pnlButtons.Location  = New-Object System.Drawing.Point(14, 496)
$pnlButtons.Size      = New-Object System.Drawing.Size(706, 50)
$pnlButtons.BackColor = $C_BG
$form.Controls.Add($pnlButtons)

function New-Btn {
    param([string]$Text, [int]$X, [int]$W,
          $BG=[System.Drawing.Color]::WhiteSmoke,
          $FG=[System.Drawing.Color]::Black,
          [bool]$Bold=$false)
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text      = $Text
    $btn.Location  = New-Object System.Drawing.Point($X, 6)
    $btn.Size      = New-Object System.Drawing.Size($W, 36)
    $btn.Font      = New-Object System.Drawing.Font("Segoe UI", 9, $(if ($Bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }))
    $btn.BackColor = $BG
    $btn.ForeColor = $FG
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(180,180,180)
    $pnlButtons.Controls.Add($btn)
    return $btn
}

$btnSave    = New-Btn "💾  Speichern"      0   130 ([System.Drawing.Color]::FromArgb(220,235,228))
$btnClear   = New-Btn "🗑  Log leeren"    140  130 ([System.Drawing.Color]::FromArgb(235,235,235))
$btnWhatIf  = New-Btn "🔍  Simulation"    280  150 ([System.Drawing.Color]::FromArgb(255,245,220))
$btnDeploy  = New-Btn "🚀  Jetzt deployen" 556 150 $C_GREEN ([System.Drawing.Color]::White) $true

# ── Log-Bereich ─────────────────────────────────────────
$grpLog = New-Object System.Windows.Forms.GroupBox
$grpLog.Text      = "  Deployment Log"
$grpLog.Font      = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$grpLog.ForeColor = $C_DARK
$grpLog.BackColor = $C_BG
$grpLog.Location  = New-Object System.Drawing.Point(14, 556)
$grpLog.Size      = New-Object System.Drawing.Size(706, 238)
$form.Controls.Add($grpLog)

$rtb = New-Object System.Windows.Forms.RichTextBox
$rtb.Location    = New-Object System.Drawing.Point(8, 20)
$rtb.Size        = New-Object System.Drawing.Size(688, 208)
$rtb.BackColor   = [System.Drawing.Color]::FromArgb(15, 15, 20)
$rtb.ForeColor   = [System.Drawing.Color]::LightGray
$rtb.Font        = New-Object System.Drawing.Font("Consolas", 8.5)
$rtb.ReadOnly    = $true
$rtb.ScrollBars  = "Vertical"
$rtb.BorderStyle = "None"
$grpLog.Controls.Add($rtb)

# ── Status-Bar ──────────────────────────────────────────
$statusBar = New-Object System.Windows.Forms.StatusStrip
$statusBar.BackColor = $C_PANEL
$form.Controls.Add($statusBar)

$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text      = "Bereit"
$statusLabel.ForeColor = $C_DARK
$statusBar.Items.Add($statusLabel) | Out-Null

$statusCost = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusCost.Text      = "~€765/Monat  |  Kunden-Minimal"
$statusCost.Spring    = $true
$statusCost.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
$statusCost.ForeColor = $C_GREEN
$statusBar.Items.Add($statusCost) | Out-Null

# ── Log Helpers ─────────────────────────────────────────
function Append-Log {
    param([string]$Text, $Color = [System.Drawing.Color]::LightGray)
    if ($rtb.InvokeRequired) {
        $rtb.Invoke([Action]{
            $rtb.SelectionStart  = $rtb.TextLength
            $rtb.SelectionLength = 0
            $rtb.SelectionColor  = $Color
            $rtb.AppendText($Text + "`n")
            $rtb.ScrollToCaret()
        })
    } else {
        $rtb.SelectionStart  = $rtb.TextLength
        $rtb.SelectionLength = 0
        $rtb.SelectionColor  = $Color
        $rtb.AppendText($Text + "`n")
        $rtb.ScrollToCaret()
    }
}

function Parse-LogLine([string]$Line) {
    $c = switch -Regex ($Line) {
        "^\[OK\]"                { [System.Drawing.Color]::FromArgb(80, 220, 120) }
        "^\[FAIL\]"              { [System.Drawing.Color]::FromArgb(255, 80, 80)  }
        "^\[STEP\]"              { [System.Drawing.Color]::FromArgb(255, 210, 60) }
        "^={3,}|^ [A-Z]"        { [System.Drawing.Color]::FromArgb(80, 200, 230) }
        "Zurueckgestellt|Zurück" { [System.Drawing.Color]::FromArgb(200, 160, 60) }
        "€765|€700|€50|€15"     { [System.Drawing.Color]::FromArgb(80, 220, 120) }
        "MODUS.*What-If"        { [System.Drawing.Color]::FromArgb(220, 140, 255) }
        default                  { [System.Drawing.Color]::FromArgb(200, 200, 200) }
    }
    Append-Log $Line $c
}

# ── Konfig laden ────────────────────────────────────────
$saved = Load-SavedConfig
if ($saved) {
    if ($saved.TenantId -and $saved.TenantId -notmatch "^x") {
        $txtTenant.Text = $saved.TenantId; $txtTenant.ForeColor = [System.Drawing.Color]::Black
    }
    if ($saved.ConnSub -and $saved.ConnSub -notmatch "^x") {
        $txtConnSub.Text = $saved.ConnSub; $txtConnSub.ForeColor = [System.Drawing.Color]::Black
    }
    if ($saved.ProdSub -and $saved.ProdSub -notmatch "^x") {
        $txtProdSub.Text = $saved.ProdSub; $txtProdSub.ForeColor = [System.Drawing.Color]::Black
    }
    if ($saved.SandSub -and $saved.SandSub -notmatch "^x") {
        $txtSandSub.Text = $saved.SandSub; $txtSandSub.ForeColor = [System.Drawing.Color]::Black
    }
    Append-Log "Gespeicherte Konfiguration geladen: $ConfigFile" ([System.Drawing.Color]::FromArgb(80,180,255))
}

# ── Button: Speichern ───────────────────────────────────
$btnSave.Add_Click({
    $cfg = [ordered]@{
        TenantId = (Get-FieldValue $txtTenant  "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
        ConnSub  = (Get-FieldValue $txtConnSub "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
        ProdSub  = (Get-FieldValue $txtProdSub "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
        SandSub  = (Get-FieldValue $txtSandSub "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
    }
    Save-CurrentConfig $cfg
    $statusLabel.Text = "Gespeichert: $ConfigFile"
    Append-Log "Konfiguration gespeichert  →  $ConfigFile" ([System.Drawing.Color]::FromArgb(80, 220, 120))
})

# ── Button: Log leeren ──────────────────────────────────
$btnClear.Add_Click({ $rtb.Clear() })

# ── Hintergrund-Job + Timer ─────────────────────────────
$script:runningJob = $null

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 400

$timer.Add_Tick({
    if ($null -eq $script:runningJob) { $timer.Stop(); return }

    $lines = Receive-Job $script:runningJob 2>&1
    foreach ($l in $lines) {
        if ($l) { Parse-LogLine $l.ToString() }
    }

    if ($script:runningJob.State -in @("Completed","Failed","Stopped")) {
        $timer.Stop()
        $state = $script:runningJob.State
        $ok    = $state -eq "Completed"
        $col   = if ($ok) { [System.Drawing.Color]::FromArgb(80,220,120) } else { [System.Drawing.Color]::FromArgb(255,80,80) }
        Append-Log ""
        Append-Log "══════════════════════════════════════════════════" $col
        Append-Log "  Deployment $state" $col
        Append-Log "══════════════════════════════════════════════════" $col
        Remove-Job $script:runningJob -Force
        $script:runningJob = $null

        $btnDeploy.Enabled  = $true
        $btnWhatIf.Enabled  = $true
        $statusLabel.Text   = if ($ok) { "✔ Erfolgreich" } else { "✖ Fehler – Details im Log" }
        $statusLabel.ForeColor = $col
    }
})

# ── Kern-Deploy Funktion ────────────────────────────────
function Start-Deployment([bool]$WhatIfMode) {
    $tenantId = Get-FieldValue $txtTenant  "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    $connSub  = Get-FieldValue $txtConnSub "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    $prodSub  = Get-FieldValue $txtProdSub "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    $sandSub  = Get-FieldValue $txtSandSub "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    $location = if ($cboRegion.SelectedIndex -eq 0) { "germanywestcentral" } else { "germanywestcentral" }

    if ([string]::IsNullOrWhiteSpace($tenantId)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Bitte Tenant ID eingeben.", "Fehlende Eingabe", "OK", "Warning") | Out-Null
        return
    }
    if ([string]::IsNullOrWhiteSpace($connSub)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Bitte Connectivity Subscription ID eingeben.", "Fehlende Eingabe", "OK", "Warning") | Out-Null
        return
    }

    $btnDeploy.Enabled = $false
    $btnWhatIf.Enabled = $false
    $rtb.Clear()

    $modeText = if ($WhatIfMode) { "SIMULATION (What-If)" } else { "DEPLOYMENT" }
    $statusLabel.Text      = if ($WhatIfMode) { "Simulation läuft..." } else { "Deployment läuft..." }
    $statusLabel.ForeColor = $C_DARK

    Append-Log "╔══════════════════════════════════════════════════╗" ([System.Drawing.Color]::FromArgb(80,200,230))
    Append-Log "  Azure Landing Zone  —  $modeText"               ([System.Drawing.Color]::FromArgb(80,200,230))
    Append-Log "╚══════════════════════════════════════════════════╝" ([System.Drawing.Color]::FromArgb(80,200,230))
    Append-Log "  Tenant:           $tenantId"    ([System.Drawing.Color]::LightGray)
    Append-Log "  Connectivity Sub: $connSub"     ([System.Drawing.Color]::LightGray)
    if ($prodSub) { Append-Log "  Produktion Sub:  $prodSub" ([System.Drawing.Color]::LightGray) }
    if ($sandSub) { Append-Log "  Sandbox Sub:     $sandSub" ([System.Drawing.Color]::LightGray) }
    Append-Log "──────────────────────────────────────────────────" ([System.Drawing.Color]::DarkGray)

    $cliScript   = Join-Path $PSScriptRoot "deploy-cli.ps1"
    $deployMG    = $chkMG.Checked
    $deployLog   = $chkLogging.Checked
    $deployNet   = $chkNetwork.Checked
    $deploySpoke = $chkSpoke.Checked -and -not [string]::IsNullOrWhiteSpace($prodSub)

    $script:runningJob = Start-Job -ScriptBlock {
        param($Script, $Tenant, $Conn, $Prod, $Sand, $Loc, $WI, $MG, $Log, $Net, $Spoke)

        $params = @{ TenantId = $Tenant; ConnectivitySubscriptionId = $Conn; PrimaryLocation = $Loc }
        if ($Prod)  { $params.ProduktionSubscriptionId = $Prod }
        if ($Sand)  { $params.SandboxSubscriptionId    = $Sand }
        if ($WI)    { $params.WhatIf = $true }
        if ($Spoke) { $params.DeploySpoke = $true }

        $scopeParts = @()
        if ($MG)  { $scopeParts += "ManagementGroups" }
        if ($Log) { $scopeParts += "Logging" }
        if ($Net) { $scopeParts += "Networking" }

        if ($scopeParts.Count -eq 3 -or $scopeParts.Count -eq 0) {
            $params.DeploymentScope = "All"
        } elseif ($scopeParts.Count -eq 1) {
            $params.DeploymentScope = $scopeParts[0]
        } else {
            # Mehrere Scopes: nacheinander ausführen
            foreach ($s in $scopeParts) {
                $params.DeploymentScope = $s
                & $Script @params *>&1
            }
            return
        }

        & $Script @params *>&1
    } -ArgumentList $cliScript, $tenantId, $connSub, $prodSub, $sandSub, $location,
                    $WhatIfMode, $deployMG, $deployLog, $deployNet, $deploySpoke

    $timer.Start()
}

# ── Button: What-If ─────────────────────────────────────
$btnWhatIf.Add_Click({ Start-Deployment $true })

# ── Button: Deployen ────────────────────────────────────
$btnDeploy.Add_Click({
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Azure Landing Zone jetzt deployen?`n`nDies erstellt echte Azure-Ressourcen (~€765/Monat).",
        "Deployment bestätigen",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {
        Start-Deployment $false
    }
})

# ── Beim Schließen Job abbrechen ────────────────────────
$form.Add_FormClosing({
    $timer.Stop()
    if ($script:runningJob) {
        Stop-Job  $script:runningJob -ErrorAction SilentlyContinue
        Remove-Job $script:runningJob -Force -ErrorAction SilentlyContinue
    }
})

# ── Starten ─────────────────────────────────────────────
[void]$form.ShowDialog()
