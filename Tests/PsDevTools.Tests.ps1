<#


#>

Describe 'PsDevTools Tests' {

    BeforeAll {
        Import-Module "PsDevTools" -ea 0 -Force
        $script:thisModule = Get-Module -Name "PsDevTools"
        $script:funcNames = $thisModule.ExportedCommands.Values |
            Where-Object {$_.CommandType -eq 'Function'} |
            Select-Object -ExpandProperty Name
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

    }

    Context 'Clean up' {

        It 'Ensures all public functions have tests' {
            $script:funcNames | Should -BeNullOrEmpty
        }
        
    }

}

