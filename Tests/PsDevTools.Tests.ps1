Describe 'PsDevTools Tests' {

    BeforeAll {
        Import-Module "PsDevTools" -ea 0 -Force
        $script:thisModule = Get-Module -Name "PsDevTools"
        $script:funcNames = $thisModule.ExportedCommands.Values |
            Where-Object {$_.CommandType -eq 'Function'} |
            Select-Object -ExpandProperty Name

        # dot-sourcing all functions: Required for Mocking
        $modParent = Split-Path $thisModule.Path -Parent
        Get-ChildItem   $modParent\Private\*.ps1,
                        $modParent\Public\*.ps1   |
        ForEach-Object {. $_.FullName}
    }

    Context 'Test Module import' {

        It 'Ensures module is imported' {
            $script:thisModule.Name | Should -Be 'PsDevTools'
        }

    }

    Context 'Test PsDevTools Functions' {

        # Remove the tested item from the initial array
        AfterEach {
            $script:funcNames = $script:funcNames | Where-Object {$_ -ne $script:thisName}
        }

        It 'Set-CamelCase test)' {
            $Valid = Set-CamelCase -String 'make this camel case'
            $Valid | Should -Be 'makeThisCamelCase'

            $Valid = Set-CamelCase -String 'camelCase'
            $Valid | Should -Be 'camelCase'

            $Valid = 'A very Long stRing of words IN miXed case' | Set-CamelCase
            $Valid | Should -Be 'aVeryLongStringOfWordsInMixedCase'

            $Valid = 'A very Long stRing of words IN miXed case' | Set-CamelCase -SkipToLower
            $Valid | Should -Be 'aVeryLongStRingOfWordsINMiXedCase'

            $script:thisName = 'Set-CamelCase'
        }

        It 'Compares array order' {
            $a1 = @('red','green','blue')
            $a2 = @('red','green','blue')
            $a3 = @('gray','blue','purple')
            $a4 = @('red','blue','green')
            $a5 = @('gray','blue','purple','red')
            Compare-ArrayOrder $a1 $a2 -wa 0 | Should -Be $true
            Compare-ArrayOrder $a3 $a2 -wa 0 | Should -Be $false
            Compare-ArrayOrder $a2 $a4 -wa 0 | Should -Be $false
            Compare-ArrayOrder $a3 $a5 -wa 0 | Should -Be $false

            $script:thisName = 'Compare-ArrayOrder'
        }

        It 'Averages an array' {
            $arr = @(1,3,44,3,14,6,100)
            Measure-Average $arr | Should -Be 24.4285714285714
            Measure-Average $arr Median | Should -Be 6
            Measure-Average $arr Mode | Should -Be 3

            $script:thisName = 'Measure-Average'
        }

        It 'Extracts a table from a web page 2 ways' {
            $w = Invoke-WebRequest 'https://www.w3schools.com/html/html_tables.asp'
            $byR = $w | ConvertFrom-Html
            $byH = $w.RawContent | ConvertFrom-html
            
            $colR = @($byR | Get-Member -Type '*Property').Name
            $colH = @($byH | Get-Member -Type '*Property').Name

            $byR.Count | Should -BeGreaterThan 2
            $byH.Count | Should -BeGreaterThan 2
            $byR."$($colR[0])" | Should -BeOfType [string]
            $byH."$($colH[0])" | Should -BeOfType [string]

            $script:thisName = 'ConvertFrom-Html'
        }

    }

    Context 'Clean up' {

        It 'Ensures all public functions have tests' {
            $script:funcNames | Should -BeNullOrEmpty
        }
        
    }

}

