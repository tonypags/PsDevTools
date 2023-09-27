function Test-PsCmdlet {
    [pscustomobject]@{
        MyInvocation = $MyInvocation
        NestedPromptLevel = $NestedPromptLevel
        ExecutionContext = $ExecutionContext
        PID = $PID
        Profile = $PROFILE
        PsCmdlet = $PsCmdlet
        PSCommandPath = $PSCommandPath
        PsCulture = $PsCulture
        PSDebugContext = $PSDebugContext
        PsHome = $PsHome
        PSScriptRoot = $PSScriptRoot
        PSSenderInfo = $PSSenderInfo
        PsUICulture = $PsUICulture
        PsVersionTable = $PsVersionTable
        Pwd = $Pwd
        xModuleBase = $MyInvocation.MyCommand.Module.ModuleBase
    }

}
