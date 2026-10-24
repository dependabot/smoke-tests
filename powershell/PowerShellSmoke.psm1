using module @{ ModuleName = 'GitHub'; RequiredVersion = '0.43.0' }

$ErrorActionPreference = 'Stop'

function Get-PowerShellSmoke {
    'ok'
}

Export-ModuleMember -Function Get-PowerShellSmoke
