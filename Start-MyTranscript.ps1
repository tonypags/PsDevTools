function Start-MyTranscript {
    param (
        [string]$Path=(Join-Path $env:USERPROFILE 'Documents\WindowsPowerShell\Transcripts'),
        [string]$Label=$null
    )

    if ($Label) {$Label += '_'}
    
    # Create the Transcript folder if it doesn't exist
    $strNow = (Get-Date).ToString('yyyyMMddHHmmss')
    $tsPath = Join-Path $Path "$($Label)PowerShell_Transcript_$($strNow).txt"

    $tsParent = Split-Path $tsPath -Parent
    if (Test-Path $tsParent) {
        # Do Nothing
    } else {
        New-Item -ItemType Directory -Path $tsParent -Force | Out-Null
    }
    # Start Transcript
    New-Item -ItemType file -Path $tsPath -ea 0 | Out-Null
    Start-Transcript -Path $tsPath -ea 0 | Out-Null
}
