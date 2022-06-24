function Convert-CelsiusToFahrenheit {
    param(
        [double]
        $celsius
    )

    ( $celsius * 1.8 ) + 32

}
