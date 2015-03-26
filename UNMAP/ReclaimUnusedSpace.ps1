<#
.SYNOPSIS
  Reclame l'espace libre sur les datastores en thin provisionning.

.DESCRIPTION
  Reclame l'espace libre sur les datastores en thin provisionning.

.PARAMETER VMHost
  Nom du serveur ESXi depuis lequel sera reclame l'espace libre. Ce parametre est obligatoire

.PARAMETER Datastore
  Nom d'un datastore sur lequel sera reclame l'espace libre.

.PARAMETER asyncUnmapFilePourcentage
  Valeur utilisee pour calculer la taille du fichier asyncUnmapFile. Correspond au pourcentage de de l'esapce libre restant.

.NOTES
  Il est necessaire d etre connecte a un serveur vCenter ou ESXi avant d'executer ce script. Ce script est compatible vSphere 5.5 uniquement.

.EXAMPLE
  ReclaimUnusedSpace -VMHost NomDuServeurESXi

  Reclamer l'espace libre sur tous les datasores.

.EXAMPLE
  ReclaimUnusedSpace -VMHost NomDuServeurESXi -Datastore NomDuDatastore

  Reclamer l'espace libre sur un datasore specifique.

.LINK
  http://blog.okcomputer.io
#>

Param (
  [Parameter(Mandatory=$true)]
  [string]$VMHost,
  [string]$Datastore="*",
  [int]$asyncUnmapFilePourcentage=50
)

# Récupere les informations sur le ou les datastore(s)
$Datastores = Get-Datastore -Name $Datastore

# Réclamation de l'espace libre sur chaque datastore
foreach ($DS in $Datastores) {

  #Calcul de la taille du fichier asyncUnmapFile en fonction du pourcentage passé en argument. Par défaut 50%
  [int]$FreeSpace = $DS.FreeSpaceMB
  $asyncUnmapFileSize = [math]::Round($FreeSpace / $asyncUnmapFilePourcentage)

  # Esxcli
  $esxcli = get-vmhost -Name $VMHost | Get-EsxCli

  Write-Host "Reclamation de l'espace libre sur $($DS.name) par bloc de $asyncUnmapFileSize Mo et depuis le serveur $VMHost"

  #Execution de la commande avec gestion des erreurs
  Try {
    $result = $esxcli.storage.vmfs.unmap($asyncUnmapFileSize, $DS.name, $null)
  }
  Catch [VMware.VimAutomation.Sdk.Types.V1.ErrorHandling.VimException.ViError] {
    Write-Host "Erreur lors de la réclamation de l'espace libre sur $($DS.name)"
    Write-Host $_.Exception.Message
  }
}
