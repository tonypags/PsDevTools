function Convert-FahrenheitToCelsius {
    param(
        [double]
        $fahrenheit
    )

    ( $fahrenheit - 32 ) / 1.8

}
