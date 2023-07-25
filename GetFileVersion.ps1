$parentFolder = "C:\Program Files\Notepad++"
$outputFile = "$env:USERPROFILE\Documents\FileVersions.csv"

# ArrayList to store file version objects
$fileVersions = New-Object System.Collections.ArrayList

# Function to recursively get file versions
function Get-FileVersion {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("FullName")]
        [string]$Path
    )

    if (Test-Path -Path $Path -PathType Leaf) {
        $fileVersion = (Get-Item $Path).VersionInfo.FileVersion
        $fileVersions.Add([PSCustomObject]@{
            FileName = Get-Item $Path
            FileVersion = $fileVersion
        }) | Out-Null

        Write-Output "$Path : $fileVersion"
    }
}

# Recursive function to process folders
function Process-Folder {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FolderPath
    )

    # Process files in the current folder
    Get-ChildItem -Path $FolderPath -File | ForEach-Object {
        Get-FileVersion -Path $_.FullName
    }

    # Process subfolders
    Get-ChildItem -Path $FolderPath -Directory | ForEach-Object {
        Process-Folder -FolderPath $_.FullName
    }
}

# Start processing from the parent folder
Process-Folder -FolderPath $parentFolder

# Export file versions to CSV
$fileVersions | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

# Display success message
Write-Host "File versions exported to: $outputFile"
