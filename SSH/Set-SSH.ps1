<#
.SYNOPSIS
  Configuration du service SSH sur un ou plusieurs hosts VMWare ESXi.

.DESCRIPTION
  Configuration du service SSH sur un ou plusieurs hosts VMWare ESXi.

.PARAMETER VMHost
  Serveur ESXi sur lequel sera configuré le SSH. Ce parametre est obligatoire

.PARAMETER Policy
  Policy à appliquer au service SSH (On, Off, Auto)

.NOTES
  Il est necessaire d etre connecte a un serveur vCenter ou ESXi avant d'executer ce script. Ce script a été testé surdes ESXi en version 5.5 et 6.0.

.EXAMPLE
  Get-VMHost | Set-SSH -Policy On

  Configure le service SSH sur l'ensemble des hosts renvoyé par la commande Get-VMHost

.LINK
  http://blog.okcomputer.io
#>

[CmdletBinding()]
Param (
  [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
  [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl[]]$VMHost,
  [Parameter(Mandatory=$True)]
  [String]$Policy
)
Process {

  Write-Host "Configuring SSH on: $($VMHost.Name)" -ForegroundColor Blue

  Write-Host "*** Configuring SSH activation policy" -ForegroundColor Cyan
  $VMHost | where{$_.Key -eq "TSM-SSH"} | Set-VMHostService -policy $policy -Confirm:$false  | Out-Null

  Write-Host "*** Start SSH service" -ForegroundColor Cyan
  $VMHost | where{$_.Key -eq "TSM-SSH"} | Start-VMHostService -Confirm:$false  | Out-Null

  Write-Host "*** Disable SSH warning" -ForegroundColor Cyan
  $VMHost | Get-AdvancedSetting -Name 'UserVars.SuppressShellWarning' | Set-AdvancedSetting -Value '1' -Confirm:$false  | Out-Null

}
