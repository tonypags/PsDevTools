Function Send-FunctionToPsSession() {
    <#
    .SYNOPSIS
    Allows use of a local function remotely, in a PsRemoting ScriptBlock
    .DESCRIPTION
    Allows use of a local function remotely, in a PsRemoting ScriptBlock
    .EXAMPLE
    $sess = New-PsSession "wsus01" -Cred $Cred
    Send-FunctionToPsSession -FunctionName 'Get-SomethingCustom' -Session $sess
    $SB = {Get-SomethingCustom -Param 'item1'}
    $result = Invoke-Command -Session $sess -ScriptBlock $SB
    $sess | Remove-PsSession
    .NOTES
    Borrowed from:
    https://matthewjdegarmo.com/powershell/2021/03/31/how-to-import-a-locally-defined-function-into-a-remote-powershell-session.html
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [System.String[]]
        $FunctionName,
        
        [Parameter(Mandatory)]
        [System.Management.Automation.Runspaces.PSSession]
        $Session
    )

    Begin {}

    Process {
        $FunctionName | Foreach-Object {
            try {
                $Function = Get-Command -Name $_
                If ($Function) {
                    $Definition = @"
                        $($Function.CommandType) $_() {
                            $($Function.Definition)
                        }
"@

                    Invoke-Command -Session $Session -ScriptBlock {
                        Param($LoadMe)
                        . ([ScriptBlock]::Create($LoadMe))
                    } -ArgumentList $Definition
                }
            } catch [CommandNotFoundException] {
                Throw $_
            }
        }
    }

}#END: Send-FunctionToPsSession
