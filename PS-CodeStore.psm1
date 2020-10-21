#Requires -RunAsAdministrator
#Requires -Version 4.0

# 1 - FUNCTION OF ADDING A LINE IN A CSV LOG FILE =========================================================================================

#[string]$ScriptDirectoryPath = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
#[string]$LogPath = "$ScriptDirectoryPath\log.csv"


function Add-ScriptLog {

    <#
        .SYNOPSIS
        Add a line to a log file
        .DESCRIPTION
        The function add a line in a specified log file with personalized information by dating and nominating the user of the function
        .PARAMETER LogPath
        Path to log file
        .PARAMETER Level
        Type of information (SUCCESS,INFORMATION,WARNING,ERROR)
        .PARAMETER LogMessage
        Message indicated in the log file
        .PARAMETER OutputMessage
        Message displayed in the host
        .EXAMPLE
        Add-ScriptLog -LogPath $logPath -Level "INFORMATION" -LogMessage "Message in the log file"
        .EXAMPLE
        Add-ScriptLog -LogPath $logPath -Level "INFORMATION" -LogMessage "Message in the log file" -OutputMessage "Message displayed in the host"
        .INPUTS
        .OUTPUTS
        .NOTES
        AUTHOR: Salas Nicolas
        LASTEDIT: 18/10/2020
        VERSION:1.0.0 Creation of the function
        .LINK
        http://www.nsalas.fr
        PS-CodeStore.ps1
    #>

    param (
        [Parameter(Mandatory)][string]$LogPath,
        [Parameter(Mandatory)][string]$Level,
        [Parameter(Mandatory)][string]$LogMessage,
        [string]$OutputMessage
    )

    BEGIN {
        $DateTime = Get-Date -Format "dd/MM/yyyy;HH:mm:ss"
        if ($OutputMessage -eq "") {
           $OutputMessage = $LogMessage 
        }
    }

    PROCESS{
        Add-Content -path $LogPath -Value "$DateTime;$Level;$env:UserName;$LogMessage"
    }

    END{
        if ($Level -eq "SUCCESS") {
            Write-Host $OutputMessage -ForegroundColor Green
        }
        elseif ($Level -eq "WARNING") {
            Write-Host $OutputMessage -ForegroundColor Yellow -BackgroundColor Black
        }
        elseif ($Level -eq "ERROR") {
            Add-Content -path $LogPath -Value "$DateTime;END;$env:UserName;FIN DU SCRIPT SUR ERREUR"
            Write-Host $OutputMessage -ForegroundColor Red -BackgroundColor Black -NoNewline
            Read-Host
            EXIT 
        }
        elseif ($Level -eq "END") {
            Read-Host $OutputMessage
            EXIT
        }
        else {
            Write-Host $OutputMessage
        }
    }

}


# 2 - FUNCTION OF EXECUTION LIST FILE VERIFICATION ========================================================================================

#[string]$ScriptDirectoryPath = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
#[string]$DataList = "$ScriptDirectoryPath\servers.csv"
#Need Add-ScriptLog function, to manage a log file


function Test-DataList {

    <#
        .SYNOPSIS
        Test a list data
        .DESCRIPTION
        The function test a list data by asking if the file has been completed and test if it is empty
        .PARAMETER DataList
        Path to the data of liste
        .PARAMETER LogPath
        Path to log file
        .EXAMPLE
        Test-DataList -DataList $DataList
        .INPUTS
        .OUTPUTS
        .NOTES
        AUTHOR: Salas Nicolas
        LASTEDIT: 18/10/2020
        VERSION:1.0.0 Creation of the function
        .LINK
        http://www.nsalas.fr
        PS-CodeStore.ps1
    #>

    param (
        [Parameter(Mandatory)][string]$DataList,
        [Parameter(Mandatory)][string]$LogPath
    )

    BEGIN {
        Write-Host "Avez-vous bien complété le fichier servers.csv [Oui] : " -ForegroundColor Cyan -NoNewline
        $ListOK = Read-Host
    }

    PROCESS{

        if ($ListOK -ne "y" -and $ListOK -ne "yes" -and $ListOK -ne "o" -and $ListOK -ne "oui" -and $ListOK -ne "") {
            Add-ScriptLog -LogPath $LogPath -Level "ERROR" -LogMessage "Le fichier server.csv n'a pas été configuré" -OutputMessage "Veuillez compléter le fichier server.csv, puis relancez ce script !"
        }

        $csv = import-csv $DataList

        if ($null -eq $csv) {
            Add-ScriptLog -LogPath $LogPath -Level "ERROR" -LogMessage "Le fichier server.csv est vide" -OutputMessage "Le fichier servers.csv est vide, veuillez le compléter, puis relancez ce script !"
        }
    }

    END{
        Add-ScriptLog -LogPath $LogPath -Level "SUCCESS" -LogMessage "le fichier server.csv a été complété"
    }

}

# 3 - FUNCTION OF CREDENTIAL CONTROL ON A DOMAIN ==========================================================================================

#[pscredential]$Credential = Get-Credential -Message "Entrez votre compte"
#[string]$Domain = "LDAP://DC=contoso,DC=com"
#Need Add-ScriptLog function, to manage a log file


function Test-Credential {

    <#
        .SYNOPSIS
        Test credentials on a domain
        .DESCRIPTION
        The function tests an entered credential on a domain
        .PARAMETER Credential
        Credential to test on a domain
        .PARAMETER Domain
        Domain on which to test the identifier, In the format "LDAP://DC=contoso,DC=com"
        .PARAMETER LogPath
        Path to log file
        .EXAMPLE
        Test-Credential -Credential $Credential
        .EXAMPLE
        Test-Credential -Credential $Credential -Domain "LDAP://DC=domain,DC=com"
        .INPUTS
        .OUTPUTS
        .NOTES
        AUTHOR: Salas Nicolas
        LASTEDIT: 18/10/2020
        VERSION:1.0.0 Creation of the function
        .LINK
        http://www.nsalas.fr
        PS-CodeStore.ps1
    #>

    param (
        [pscredential]$Credential,
        [string]$Domain,
        [Parameter(Mandatory)][string]$LogPath
    )

    BEGIN {
        if ($domain -eq "") {
            $Domain = "LDAP://DC=contoso,DC=com"
        }
        if ($null -eq $Credential) {
            Add-ScriptLog -LogPath $LogPath -Level "ERROR" -LogMessage "Aucn identifiants n'a été renseigné" -OutputMessage "Vous n'avez pas renseigné d'identifiants"
        }
    }

    PROCESS{
         $Username = $Credential.username
         $Password = $Credential.GetNetworkCredential().password
         $CredTest = New-Object System.DirectoryServices.DirectoryEntry($Domain,$Username,$Password)
         $Password = $null
         
         if ($null -eq $CredTest.name) {
            Add-ScriptLog -LogPath $LogPath -Level "ERROR" -LogMessage "Identifiants incorects" -OutputMessage "Les identifiants sont incorrects"
        }
         else {
            Add-ScriptLog -LogPath $LogPath -Level "SUCCESS" -LogMessage "Connecté avec le compte $Username"
         } 
    }

    END{

    }

}


# 4 - FUNCTION OF START REMOTE SERVICES ===================================================================================================

#Need Add-ScriptLog function, to manage a log file


function Start-RemoteServices {

    <#
        .SYNOPSIS
        Start the remote services
        .DESCRIPTION
        The function start and configure WinRM service, and enable PSRemoting (Enable-PSRemoting)
        .PARAMETER LogPath
        Path to log file
        .EXAMPLE
        Start-RemoteServices
        .INPUTS
        .OUTPUTS
        .NOTES
        AUTHOR: Salas Nicolas
        LASTEDIT: 18/10/2020
        VERSION:1.0.0 Creation of the function
        .LINK
        http://www.nsalas.fr
        PS-CodeStore.ps1
    #>

    param (
        [Parameter(Mandatory)][string]$LogPath
    )

    BEGIN {
        $WinRM = Get-Service WinRM
    }

    PROCESS{
        if ($WinRM.status.ToString() -ne "Running") {
            Add-ScriptLog -LogPath $LogPath -Level "INFORMATION" -LogMessage "Démarrage du service WinRM"
            winrm quickconfig
            $WinRM = Get-Service WinRM

            if ($WinRM.status.ToString() -ne "Running") {
                Add-ScriptLog -LogPath $LogPath -Level "ERROR" -LogMessage "Le service WinRM n'a pas démarré"
            }
            else {
                Add-ScriptLog -LogPath $LogPath -Level "INFORMATION" -LogMessage "Service WinRM démarré"
            }
        }
        else {
            Add-ScriptLog -LogPath $LogPath -Level "INFORMATION" -LogMessage "Le service WinRM est déjà démarré"
        }
    }

    END{
        Add-ScriptLog -LogPath $LogPath -Level "INFORMATION" -LogMessage "Configuration de PSRemoting..."

        try{
            Enable-PSRemoting -Force  -EA Stop
       }
       catch{
        Add-ScriptLog -LogPath $LogPath -Level "ERROR" -LogMessage "$_"
       }
        Add-ScriptLog -LogPath $LogPath -Level "INFORMATION" -LogMessage "PSRemoting est configuré"
    }

}


# 5 - FUNCTION OF ADDING USER ACCOUNTS IN LOCAL GROUPS ====================================================================================

#$session = New-PSSession -ComputerName $server.server -Credential $Credential
#[string]$ServerName = $server.server


function Add-UserRemoteLocalGroup {

    <#
        .SYNOPSIS
        Add User in a remote local group
        .DESCRIPTION
        The function add a user in a remote local group
        .PARAMETER Account
        Account to add to remote local group
        .PARAMETER LocalGroup
        Remote local group
        .PARAMETER Session
        PSSession Variable
        .PARAMETER ServerName
        Remote server name
        .PARAMETER LogPath
        Path to log file
        .EXAMPLE
        Add-UserRemoteLocalGroup -Account "Backup Operators" -LocalGroup "Domain\Account" -Session $session -ServerName $ServerName
        .INPUTS
        .OUTPUTS
        .NOTES
        AUTHOR: Salas Nicolas
        LASTEDIT: 18/10/2020
        VERSION:1.0.0 Creation of the function
        .LINK
        http://www.nsalas.fr
        PS-CodeStore.ps1
    #>

    param (
        [Parameter(Mandatory)][string]$Account,
        [Parameter(Mandatory)][string]$LocalGroup,
        [Parameter(Mandatory)][string]$Session,
        [Parameter(Mandatory)][String]$ServerName,
        [Parameter(Mandatory)][string]$LogPath
    )

    BEGIN {
    }

    PROCESS{
        Add-ScriptLog -LogPath $logPath -Level "INFORMATION" -LogMessage "Ajout du compte $Account au groupe $LocalGroup sur $ServerName"
            try{
                $Resultat = Invoke-Command -Session $Session -Scriptblock {
                    Add-LocalGroupMember -Group "{0}" -Member ("{1}") -f $using:LocalGroup, $using:Account
                } -EA Stop
           }
           catch{
            Add-ScriptLog -LogPath $LogPath -Level "ERROR" -LogMessage "$_"
           }
        Add-ScriptLog -LogPath $logPath -Level "INFORMATION" -LogMessage "$Resultat"
        Write-Host "$Resultat"
    }

    END{
    }

}


# 6 - INSTALLING SOFTWARE ON A REMOTE MACHINE =============================================================================================

#$session = New-PSSession -ComputerName $server.server -Credential $Credential
#[string]$ServerName = $server.server
#New-PSDrive -Name J -root "\\$servername\c$" -PSprovider FileSystem -credential $Credential
#[string]$SoftwarePath = "J:\Software\" 


function Install-RemoteSowtware {

    <#
        .SYNOPSIS
        Install a software on a remote server
        .DESCRIPTION
        The function install a software on a remote server
        .PARAMETER SoftwareName
        Name of the software to install
        .PARAMETER SoftwarePath
        Software path to install
        .PARAMETER Server
        Name of the server where to install the software
        .PARAMETER Credential
        Credentials to use to log in to the server
        .PARAMETER LogPath
        Path to log file
        .EXAMPLE
        Install-RemoteSowtware -LogPath $LogPath -Server $Server -Credential $Credential -SoftwareName $SoftwareName -SoftwareDestinationPath $SoftwareDestinationPath -SoftwareSourcePath $SoftwareSourcePath -Software $Software
        .INPUTS
        .OUTPUTS
        .NOTES
        AUTHOR: Salas Nicolas
        LASTEDIT: 18/10/2020
        VERSION:1.0.0 Creation of the function
        .LINK
        http://www.nsalas.fr
        PS-CodeStore.ps1
    #>

    param (
        [Parameter(Mandatory)][string]$SoftwareName,
        [Parameter(Mandatory)][string]$SoftwareDestinationPath,
        [Parameter(Mandatory)][string]$SoftwareSourcePath,
        [Parameter(Mandatory)][string]$Software,
        [Parameter(Mandatory)][string]$Server,
        [Parameter(Mandatory)][pscredential]$Credential,
        [Parameter(Mandatory)][string]$LogPath
    )

    BEGIN {
        New-Item "$SoftwareDestinationPath" -itemType Directory

    }

    PROCESS{

        try{
            $session = New-PSSession -ComputerName $server -Credential $Credential -EA Stop
        }
        catch{
            Add-ScriptLog -LogPath $LogPath -Level "WARNING" -LogMessage "$_"
            continue
        }

        Add-ScriptLog -LogPath $logPath -Level "INFORMATION" -LogMessage "Copie du ficher d'installation $SoftwareName"
        Copy-Item -Path $SoftwareSourcePath -Destination "$SoftwarePath"
    
        Add-ScriptLog -LogPath $logPath -Level "INFORMATION" -LogMessage "Installation de $SoftwareName sur $ServerName"
        Invoke-Command -Session $session -Scriptblock {
            Start-Process msiexec.exe -Wait -ArgumentList "/I {0}{1} /quiet" -f $using:SoftwarePath, $using:Software
        }
    
        Remove-Item -Path "$SoftwarePath"  -Force -recurse -ErrorAction Continue
    }

    END{
    }

}


# 7 - INSTALLING SOFTWARE ON A REMOTE MACHINE =============================================================================================
 
function Add-RemoteScheduledTask {

    <#
        .SYNOPSIS
        Start the remote services
        .DESCRIPTION
        The function start and configure WinRM service, and enable PSRemoting (Enable-PSRemoting)
        .EXAMPLE
        Add-RemoteScheduledTask -Server $ServerName -Credential $Credential -LogPath $logPath -ServerName $ServerName -Task $task -TaskName $TaskName -TaskUser $TaskUser -TaskPasswd $TaskPassword
        .INPUTS
        .OUTPUTS
        .NOTES
        AUTHOR: Salas Nicolas
        LASTEDIT: 18/10/2020
        VERSION:1.0.0 Creation of the function
        .LINK
        http://www.nsalas.fr
        PS-CodeStore.ps1
    #>

    param (
        [Parameter(Mandatory)][string]$LogPath,
        [Parameter(Mandatory)][string]$ServerName,
        [Parameter(Mandatory)][string]$Server,
        [Parameter(Mandatory)][pscredential]$Credential,
        [Parameter(Mandatory)][string]$Task,
        [Parameter(Mandatory)][string]$TaskName,
        [Parameter(Mandatory)][string]$TaskUser,
        [Parameter(Mandatory)][string]$TaskPasswd
    )

    BEGIN {
        Add-ScriptLog -LogPath $logPath -Level "INFORMATION" -LogMessage "Ajout de la tâche planifié Filelist sur $ServerName"
    }

    PROCESS{
        try{
            $session = New-PSSession -ComputerName $server -Credential $Credential -EA Stop
        }
        catch{
            Add-ScriptLog -LogPath $LogPath -Level "WARNING" -LogMessage "$_"
            continue
        }

        try{
            Invoke-Command -Session $session -Scriptblock {
                Register-ScheduledTask -Xml (get-content $Using:Task | out-string) -TaskName $using:TaskName -User $Using:TaskUser -Password $Using:TaskPasswd –Force
            } -EA Stop
        }
        catch{
            Add-ScriptLog -LogPath $LogPath -Level "WARNING" -LogMessage "$_"
            continue
        }
    }

    END{
        Add-ScriptLog -LogPath $logPath -Level "SUCCESS" -LogMessage "Tâche planifié ajouté sur $ServerName"
    }

}

Export-ModuleMember -Function *