#=========================================================================================================================================#
#                                                                                                                                         #
#                                                       DESCRIPTION COURTE DU SCRIPT                                                      #
#                                                       ----------------------------                                                      #
# NAME:                                                                                                                                   #
# DESCRIPTION:                                                                                                                            #
# AUTHOR:                                                                                                                                 #
# CLIENT:                                                                                                                                 #
# DATE:                                                                                                                                   #
#                                                                                                                                         #
# KEYWORDS:                                                                                                                               #
# VERSION:                                                                                                                                #
# COMMENTS:                                                                                                                               #
#                                                                                                                                         #
# UPDATE                                                                                                                                  #
# KEYWORDS:                                                                                                                               #
# VERSION:                                                                                                                                #
# COMMENTS:                                                                                                                               #
#=========================================================================================================================================#

#=========================================================================================================================================#
#                                                                                                                                         #
#                                                       DECLARATION DES VARIABLES                                                         #
#                                                       -------------------------                                                         #
#                                                                                                                                         #
[string]$CheminRepertoireScript = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)                                  #
[pscredential]$Credential = $null                                                                                                         #
[String]$ObjectListPath = "$CheminRepertoireScript\Liste.csv"                                                                             #
[object]$ObjectList = import-csv "$CheminRepertoireScript\liste.csv"                                                                      #
[String]$Domain = "LDAP://DC=contoso,DC=com"                                                                                              #
[string]$logPath = "$CheminRepertoireScript\log.csv"                                                                                      #
[int]$nbobjects = 0                                                                                                                       #
[int]$nbobjectsp = 1                                                                                                                      #
$object = $null                                                                                                                           #
#=========================================================================================================================================#
#                                                                                                                                         #
#                                                         IMPORT DES FONCTIONS                                                            #
#                                                         --------------------                                                            #
#                                                                                                                                         #
Import-Module "$CheminRepertoireScript\PS-CodeStore.psm1"                                                                                 #
#=========================================================================================================================================#

$ConfirmPreference = "None"                                                                                                              # Ne demande pas de confirmation d'execution de commande
Add-ScriptLog -LogPath $logPath -Level "START" -LogMessage "Début de l'éxécution du Script"
clear-host                                                                                                                                # Vide la fenetre Powershell

#=========================================================================================================================================#
#                                                                                                                                         #
#                                                       ENTETE DE DEBUT DE SCRIPT                                                         #
#                                                       -------------------------                                                         #
#                   #================================ DESCRIPTION COURTE DU SCRIPT =================================#                     #
#                   #     Description                                                                               #                     #
#                   #     Du                                                                                        #                     #
#                   #     Script                                                                                    #                     #
#                   #===============================================================================================#                     #
#                                                                                                                                         #
Write-Host "#================================ " -NoNewline -ForegroundColor Cyan                                                          #
Write-Host "DESCRIPTION COURTE DU SCRIPT" -NoNewline -ForegroundColor Yellow                                                              #
Write-Host " =================================#" -ForegroundColor Cyan                                                                    #
Write-Host "#" -NoNewline -ForegroundColor Cyan                                                                                           #
Write-Host "     Description" -NoNewline                                                                                                  #
Write-Host "                                                                               #" -ForegroundColor Cyan                       #
Write-Host "#" -NoNewline -ForegroundColor Cyan                                                                                           #
Write-Host "     Du" -NoNewlin                                                                                                            #
Write-Host "                                                                                        #" -ForegroundColor Cyan              #
Write-Host "#" -NoNewline -ForegroundColor Cyan                                                                                           #
Write-Host "     Script" -NoNewlin                                                                                                        #
Write-Host "                                                                                    #" -ForegroundColor Cyan                  #
Write-Host "#===============================================================================================#" -ForegroundColor Cyan      #
Write-Host                                                                                                                                #
#=========================================================================================================================================#

# 1 - CONTROLE DU FICHIER SERVER.CSV ======================================================================================================

Test-DataList -DataList $ObjectServerListPath -LogPath $logPath
$ObjectList = import-csv $ObjectListPath

# /1 ======================================================================================================================================


# 2 - CONTROLE DES IDENTIFIANTS SEBROOT ===================================================================================================

$Credential = Get-Credential -Message "Entrez votre compte sebroot" -EA Stop
Test-Credential -Credential $Credential -Domain $Domain -LogPath $logPath

# /2 ======================================================================================================================================

# 3 - ACTIVATION DES REMOTES SERVCES ======================================================================================================

Start-RemoteServices -LogPath $logPath

# /3 ======================================================================================================================================


# 4 - COMPTE LE NOMBRE DE SERVERS DANS LE FICHIER SERVER.CSV ==============================================================================

foreach ($object in $ObjectLis) {
    $nbobjects = $nbobjects + 1                                                                                                            # Compte le nombre de server presant dans la liste servers.csv et le met dans la variable $nbservers
    } 

# /4 ======================================================================================================================================


# 5 - SUR CHACUN DES OBJET DE LA LISTE ====================================================================================================

foreach ($object in $objectList) {
    $ObjectName = $Object.Name
    Write-Host ""
    Add-ScriptLog -LogPath $logPath -Level "INFORMATION" -LogMessage "Traitement de $ObjectName [$nbobjectsp/$nbobjects]" -OutputMessage "========== Traitement de $ObjectName [$nbobjectsp/$nbobjects] =========="
    $nbobjects = $nbobjects + 1                                                                                                         # Incremante de un le decompte du nombre de server execute

# /5 ======================================================================================================================================


# 6 - TRAITEMENT  =========================================================================================================================

<#
#>

# /6 =====================================================================================================================================
}

Add-ScriptLog -LogPath $logPath -Level "END" -LogMessage "Fin de l'éxécution du Script" -OutputMessage "Merci d'avoir utiliser ce script, appuyer sur ENTRER pour terminer"
EXIT