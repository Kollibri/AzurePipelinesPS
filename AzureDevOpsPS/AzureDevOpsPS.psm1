# Module Variables
$Script:PSModuleRoot = $PSScriptRoot
$Script:ModuleName = 'AzureDevopsPS'
$Script:ModuleData = "$env:APPDATA\$Script:ModuleName"
$Script:ModuleDataPath = "$Script:ModuleData\DefaultServer.xml"

$folders = 'Private', 'Public'
foreach ($folder in $folders)
{
    $folderPath = Join-Path -Path $PSScriptRoot -ChildPath $folder
    if (Test-Path -Path $folderPath)
    {
        Write-Verbose -Message "Importing files from [$folder]..."
        $files = Get-ChildItem -Path $folderPath -Filter '*.ps1' -File -Recurse |
            Where-Object Name -notlike '*.Tests.ps1'

        foreach ($file in $files)
        {
            Write-Verbose -Message "Dot sourcing [$($file.BaseName)]..."
            . $file.FullName
        }
    }
}

Write-Verbose -Message 'Exporting Public functions...'
$functions = Get-ChildItem -Path "$PSScriptRoot\Public" -Filter '*.ps1' -File
Export-ModuleMember -Function $functions.BaseName