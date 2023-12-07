function Convert-DewPoint {
    <#
    .SYNOPSIS
    Converts temperature and relative humidity to dew point using Magnus coefficients.
    .DESCRIPTION
    Handles both Fahrenheit (default) and Celcius. Will return dew point to the same precision as the input temperature.
    .EXAMPLE
    Convert-DewPoint 67.5 32.5
    37
    .EXAMPLE
    Convert-DewPoint -F 67.500 -RH 32.5
    36.992
    .EXAMPLE
    Convert-DewPoint -C 23.5 -RH 32.5
    6.1
    .NOTES
    The parameters are string values so the input precisoin can be recorded.
    Otherwise PS will round it automatically.

    FORMULA FROM: https://www.omnicalculator.com/physics/dew-point#how-to-calculate-dew-point-how-to-calculate-relative-humidity
    Ts = (b × α(T,RH)) / (a - α(T,RH))
    where:
    Ts – Dew point (in degrees Celsius);
    T – Temperature (in degrees Celsius);
    RH - Relative humidity of the air (in percent);
    a and b are the Magnus coefficients. 
    As recommended by Alduchov and Eskridge, the value of these are:
    a = 17.625 and b = 243.04 °C; and α(T,RH) = ln(RH/100) + aT/(b+T)
    #>
    [CmdletBinding(DefaultParameterSetName='Fahrenheit')]
    param(
        [Parameter(Mandatory,Position=0,ParameterSetName='Celcius')]
        [ValidateRange(-273,500)]
        [Alias('C','TempC')]
        [string]
        $TemperatureC,

        [Parameter(Mandatory,Position=0,ParameterSetName='Fahrenheit')]
        [ValidateRange(-459,800)]
        [Alias('F','TempF')]
        [string]
        $TemperatureF,

        [Parameter(Mandatory,Position=1)]
        [ValidateRange(0,100)]
        [Alias('RH')]
        [string]
        $RelativeHumidity
    )

    # Count how many decimals were entered for temp
    $round = if ($PSCmdlet.ParameterSetName -eq 'Fahrenheit') {
        ($TemperatureF -split '\.')[1].length
    } else {
        ($TemperatureC -split '\.')[1].length
    }

    [decimal]$eConstant = 2.718
    $logarithmBase = $eConstant

    # Magnus coefficients in ºC
    [decimal]$aMagnus = 17.625
    [decimal]$bMagnus = 243.04

    [decimal]$TempC = if ($PSCmdlet.ParameterSetName -eq 'Fahrenheit') {
        Convert-FahrenheitToCelsius ([double]$TemperatureF)
    } else { $TemperatureC }

    $natLogOfRhOver100 = [math]::Log(($RelativeHumidity/100),$logarithmBase)
    $alpha = $natLogOfRhOver100 + ($aMagnus * $TempC) / ($bMagnus + $TempC)

    # Finally the dew point in ºC
    $dewPointC = ($bMagnus * $alpha) / ($aMagnus - $alpha)

    $Result = if ($PSCmdlet.ParameterSetName -eq 'Fahrenheit') {
        Convert-CelsiusToFahrenheit $dewPointC
    } else { $dewPointC }

    [math]::Round($Result,$round)

}#END: function Convert-DewPoint
