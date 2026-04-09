# Visualisiert relative fehlende Werte pro Variable und Gruppierung als Balloon Plot

Die Funktion zaehlt fehlende Werte (`NA`) pro Variable und Gruppierung
und setzt diese ins Verhaeltnis zur Gruppengroesse. Die Kreisgroesse und
-farbe kodieren den Anteil fehlender Werte, optional werden die
Prozentwerte als Text in den Kreisen angezeigt. List-Spalten werden vor
der Umformung automatisch ausgeschlossen.

## Usage

``` r
plot_na_balloons(
  data,
  grp_var = NULL,
  title = "Anteil fehlender Zeilen pro Variable und Semester",
  max_size = 18,
  low_fill = "#ffffff",
  high_fill = "#e20000",
  show_labels = FALSE,
  print_table = FALSE
)
```

## Arguments

- data:

  Ein `data.frame` oder `tibble` mit den zu analysierenden Daten.

- grp_var:

  Unquotierter Spaltenname mit der Gruppierungsvariable. Standardmaessig
  wird `semester` verwendet.

- title:

  Titel des Plots.

- max_size:

  Maximale Punktgroesse fuer die Groessenskalierung.

- low_fill:

  Farbe fuer niedrige NA-Anteile.

- high_fill:

  Farbe fuer hohe NA-Anteile.

- show_labels:

  Logisch; wenn `TRUE`, werden Werte groesser 0 als Prozentwert im Punkt
  angezeigt. Standardmaessig werden keine Zahlen eingeblendet.

- print_table:

  Logisch; wenn `TRUE`, wird die aggregierte NA-Tabelle sortiert in der
  Konsole ausgegeben. Standardmaessig ist dies deaktiviert und erfolgt
  nur auf expliziten Befehl.

## Value

Ein `ggplot`-Objekt.
