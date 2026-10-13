#requires -Version 7.0
# Local tooling observation only. See D-103, D-104. This is not a production readiness check.
[CmdletBinding()]
param([ValidateRange(1, 60)][int]$TimeoutSeconds = 20)

$ErrorActionPreference = 'Stop'

function Invoke-ToolProbe {
    param([string]$Name, [string[]]$Arguments)
    $taskCommand = Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $taskCommand) { return @{ state = 'MISSING'; output = '' } }
    $taskStart = [Diagnostics.ProcessStartInfo]::new()
    $taskStart.FileName = $taskCommand.Source
    $taskStart.WorkingDirectory = (Get-Location).Path
    $taskStart.UseShellExecute = $false
    $taskStart.CreateNoWindow = $true
    $taskStart.RedirectStandardOutput = $true
    $taskStart.RedirectStandardError = $true
    foreach ($taskArgument in $Arguments) { $taskStart.ArgumentList.Add($taskArgument) }
    $taskProcess = [Diagnostics.Process]::new()
    $taskProcess.StartInfo = $taskStart
    try {
        $null = $taskProcess.Start()
        $taskOutput = $taskProcess.StandardOutput.ReadToEndAsync()
        $taskError = $taskProcess.StandardError.ReadToEndAsync()
        if (-not $taskProcess.WaitForExit($TimeoutSeconds * 1000)) {
            # Kill only this owned probe process, never the Docker engine or other workloads.
            $taskProcess.Kill($true)
            $taskProcess.WaitForExit()
            return @{ state = 'TIMEOUT'; output = '' }
        }
        $taskStdout = $taskOutput.GetAwaiter().GetResult().Trim()
        $null = $taskError.GetAwaiter().GetResult()
        if ($taskProcess.ExitCode -ne 0) { return @{ state = 'FAILED'; output = '' } }
        return @{ state = 'OBSERVED'; output = $taskStdout }
    } catch {
        return @{ state = 'FAILED'; output = '' }
    } finally {
        $taskProcess.Dispose()
    }
}

# Anchor module/toolchain selection to this checkout, not the caller's current directory.
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
    $taskGo = Invoke-ToolProbe 'go' @('version')
    $taskDocker = Invoke-ToolProbe 'docker' @('info', '--format', '{"os":"{{.OSType}}","version":"{{.ServerVersion}}","cpus":{{.NCPU}},"memory_bytes":{{.MemTotal}}}')
    $taskGoMatches = $taskGo.state -eq 'OBSERVED' -and $taskGo.output -match '^go version go1\.27\.2 '
    $taskEngine = $null
    if ($taskDocker.state -eq 'OBSERVED') {
        try { $taskEngine = $taskDocker.output | ConvertFrom-Json } catch { $taskDocker.state = 'FAILED' }
    }
    $taskLinux = $taskDocker.state -eq 'OBSERVED' -and $taskEngine.os -eq 'linux'
    [ordered]@{
        scope = 'local-tooling-only'
        go = @{ state = $taskGo.state; version = $taskGo.output; required = 'go1.27.2'; matches = $taskGoMatches }
        docker = @{ state = $taskDocker.state; engine = $taskEngine; linux = $taskLinux }
        native_booking_tests = 'NOT RUN'
        physical_recovery = 'UNVERIFIED'
        full_scale_capacity = 'UNVERIFIED'
        ready = $taskGoMatches -and $taskLinux
    } | ConvertTo-Json -Depth 6
    if (-not ($taskGoMatches -and $taskLinux)) { exit 1 }
} finally {
    Pop-Location
}
