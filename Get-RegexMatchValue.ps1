function Get-RegexMatchValue
{
    param([string]$Value,[string]$Pattern)
    
    ([regex]::Match($Value,$Pattern)).Groups[1].Value.Trim()
}
