# HEXCleanR <img src="man/figures/HEXCleanR_Logo.png" alt="HEXCleanR Logo" align="right" height="250" />

## Hintergrund

`HEXCleanR` stellt verschiedene Funktionen zur qualitätsgesicherten Aufbereitung und Bereinigung der im HEX anfallenden Daten bereit. Es unterstützt insbesondere bei der Prüfung und Säuberung von Organisationsangaben, dem Erkennen auffälliger Veränderungen in kategorialen Merkmalen über Semester hinweg sowie der Vereinheitlichung und Plausibilisierung von Rohdaten aus unterschiedlichen Quellen. Darüber hinaus werden verschiedene Hilfsfunktionen angeboten, um beispielsweise Missings über Variablen und Semester hinweg intuitiv zu detektieren oder Scrapingdaten verschiedener Formate kompakt zu laden.

## Installation

`HEXCleanR` kann folgendermaßen installiert werden:

```r
install.packages("remotes")
remotes::install_github("Stifterverband/HEXCleanR")
```

Paket aktualisieren: Einfach den Installationsbefehl mit `force = TRUE` ausführen, um die neueste Version von GitHub zu installieren:

```r
remotes::install_github("Stifterverband/HEXCleanR", force = TRUE)
```

Installation eines bestimmten Branches:

```r
remotes::install_github("Stifterverband/HEXCleanR", ref = "dev")
```

## Dokumentation

Eine ausführliche Dokumentation von `HEXcleanR` findet sich hier: https://stifterverband.github.io/HEXCleanR/