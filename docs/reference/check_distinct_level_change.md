# Prüft Distinct-Werte-Änderungen für eine spezifische Variable

Berechnet die Anzahl eindeutiger Werte pro Gruppe und vergleicht diese
mit dem Median aller Gruppen, um Ausreißer zu identifizieren.

## Usage

``` r
check_distinct_level_change(
  data,
  group_col,
  target_col,
  threshold_low = 0.7,
  threshold_high = 1.5,
  min_distinct = 5
)
```

## Arguments

- data:

  Ein `data.frame` oder `tibble`.

- group_col:

  Die Gruppierungsvariable (ungequotet, z.B. semester).

- target_col:

  Die zu prüfende Variable (ungequotet).

- threshold_low:

  Unterer Schwellenwert (Standard: 0.70).

- threshold_high:

  Oberer Schwellenwert (Standard: 1.50).

- min_distinct:

  Mindestanzahl an Distinct-Werten im Median (Standard: 5).

## Value

Ein `tibble` mit den Ergebnissen, falls Abweichungen gefunden wurden.
