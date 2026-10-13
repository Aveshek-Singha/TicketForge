#requires -Version 7.0
# Exact compiler selection for every project Go command. See D-103, D-104.
# Keep arguments literal and restore the caller's environment after the command.
$ErrorActionPreference = 'Stop'
$taskGoArguments = @($args)
if ($taskGoArguments.Count -eq 0) { $taskGoArguments = @('version') }
$taskOldToolchain = [Environment]::GetEnvironmentVariable('GOTOOLCHAIN', 'Process')
$taskExitCode = 1
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
    $env:GOTOOLCHAIN = 'go1.27.2'
    $taskGo = Get-Command go -CommandType Application -ErrorAction Stop | Select-Object -First 1
    & $taskGo.Source @taskGoArguments
    $taskExitCode = $LASTEXITCODE
} finally {
    [Environment]::SetEnvironmentVariable('GOTOOLCHAIN', $taskOldToolchain, 'Process')
    Pop-Location
}
exit $taskExitCode
