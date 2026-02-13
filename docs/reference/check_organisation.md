# Prüft Organisations-Variable auf definierte Qualitätsregeln

Diese Funktion verwendet das Paket `pointblank`, um die Werte in der
Organisations-Variable systematisch zu validieren. Optional wird ein
HTML-Report mit Badges ausgegeben.

## Usage

``` r
check_organisation(
  data,
  organisation_col = "organisation",
  semester_col = "semester",
  stop_at = 1,
  show_report = TRUE
)
```

## Arguments

- data:

  Ein `data.frame`, das die zu prüfende Organisations-Variable enthält.

- organisation_col:

  Name der Organisations-Variable (Standard: `organisation`).

- semester_col:

  Name der Semester-Spalte (Standard: `semester`). Wird für den Check
  auf Schwankungen zwischen Semestern benötigt.

- stop_at:

  Schwellenwert für Fehler-Toleranz. Kann relativ (Anteil 0 bis 1) oder
  absolut (z. B. 1 für "Null Toleranz") angegeben werden. Standard: 1 (=
  Null Toleranz).

- show_report:

  Logisch; wenn `TRUE`, wird ein pointblank-Report mit Badges im Viewer
  ausgegeben. Standard: `TRUE`.

## Value

Ein `pointblank`-Agent-Objekt (invisible). Über
[`pointblank::get_agent_report()`](https://rstudio.github.io/pointblank/reference/get_agent_report.html)
kann der Report auch separat erzeugt werden.

## Details

Die folgenden Prüfungen werden durchgeführt:

1.  Nur korrektes Semikolon " ; " oder kein Semikolon.

2.  Kein "\|" enthalten.

3.  Kein "\>" enthalten.

4.  Länge der Zeichenkette ist kleiner oder gleich 1000.

5.  Keine überflüssigen Leerzeichen (entspricht
    [`stringr::str_squish()`](https://stringr.tidyverse.org/reference/str_trim.html)).

6.  Warnung bei Abschluss-Begriffen (z. B. Bachelor, Master, Diplom).
