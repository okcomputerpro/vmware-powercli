<#
.SYNOPSIS
  Configuration du service NTP sur un ou plusieurs hosts VMWare ESXi.

.DESCRIPTION
  Configuration du service NTP sur un ou plusieurs hosts VMWare ESXi.

.PARAMETER VMHost
  Serveur ESXi sur lequel sera configuré le NTP. Ce parametre est obligatoire

.PARAMETER Policy
  Policy à appliquer au service NTP (On, Off, Auto)

.PARAMETER NtpServer
  Liste des serveurs NTP. Ce parametre est obligatoire

.NOTES
  Il est necessaire d etre connecte a un serveur vCenter ou ESXi avant d'executer ce script. Ce script a été testé surdes ESXi en version 5.5 et 6.0.

.EXAMPLE
  Get-VMHost | Set-NTP -NtpServer 192.168.1.1 -Policy On

  Configure le service NTP sur l'ensemble des hosts renvoyé par la commande Get-VMHost

.LINK
  http://blog.okcomputer.io

#>

[CmdletBinding()]
Param (
  [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
  [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl[]]$VMHost,
  [Parameter(Mandatory=$True)]
  [String[]]$NtpServer,
  [String]$Policy="On"
)

Process {
  Write-Host "Configuring NTP on: $($VMHost.Name)" -ForegroundColor Blue

  Write-Host "*** Configuring Time" -ForegroundColor Cyan
  $VMHost | %{(Get-View $_.ExtensionData.configManager.DateTimeSystem).UpdateDateTime((Get-Date -format u)) }

  Write-Host "*** Removing old NTP Servers" -ForegroundColor Cyan
  $VMHost | Remove-VMHostNtpServer -NtpServer (Get-VMHostNtpServer $VMHost) -Confirm:$false | Out-Null

  Write-Host "*** Configuring NTP Servers" -ForegroundColor Cyan
  $VMHost | Add-VMHostNTPServer -NtpServer $NtpServer -Confirm:$false -ErrorAction SilentlyContinue | Out-Null

  Write-Host "*** Configuring NTP Client Policy" -ForegroundColor Cyan
  $VMHost | Get-VMHostService | where{$_.Key -eq "ntpd"} | Set-VMHostService -policy $Policy -Confirm:$false | Out-Null

  Write-Host "*** Restarting NTP Client" -ForegroundColor Cyan
  $VMHost | Get-VMHostService | where{$_.Key -eq "ntpd"} | Restart-VMHostService -Confirm:$false | Out-Null
}
