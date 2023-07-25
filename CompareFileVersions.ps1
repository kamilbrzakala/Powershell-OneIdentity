# Function to compare file versions and generate the report
function Compare-FileVersions {
    param (
        [string]$fileAPath,
        [string]$fileBPath,
        [string]$reportPath
    )

    # Read the contents of both files
    $fileAData = Import-Csv $fileAPath
    $fileBData = Import-Csv $fileBPath

    # Initialize an empty array to store the report data
    $reportData = @()

    # Loop through each record in File B
    foreach ($fileBRecord in $fileBData) {
        # Find the corresponding record in File A with the same FullPath and FileName
        $fileARecord = $fileAData | Where-Object { $_.FullPath -eq $fileBRecord.FullPath -and $_.FileName -eq $fileBRecord.FileName }

        # Prepare the output object
        $outputObject = [PSCustomObject]@{
            FullPath     = $fileBRecord.FullPath
            FileName     = $fileBRecord.FileName
            FileVersion  = $fileBRecord.FileVersion
            VersionChanged = if ($fileARecord -and $fileARecord.FileVersion -ne $fileBRecord.FileVersion) { "YES" } else { "NO" }
            Comments     = if (!$fileARecord) { "Additional file in File B" } else { "" }
        }

        # Add the object to the report data array
        $reportData += $outputObject
    }

    # Export the report data to CSV
    $reportData | Export-Csv -Path $reportPath -NoTypeInformation
}

# Paths to the input files and report file
$fileAPath = "$env:USERPROFILE\Documents\FileVersions.csv"
$fileBPath = "$env:USERPROFILE\Documents\FileVersionsAfterChange.csv"
$reportPath = "$env:USERPROFILE\Documents\FileVersionsReport.csv"

# Call the function to generate the report
Compare-FileVersions -fileAPath $fileAPath -fileBPath $fileBPath -reportPath $reportPath

# Output confirmation
Write-Host "FileVersionsReport.csv generated successfully."
