# HEXcleanR <a href="https://github.com/Stifterverband/HEXCleanR"><img src="man/figures/HEXCleanR_Logo.png" align="right" height="120" style="float:right; height:120px;" alt="HEXCleanR website" /></a>

HEXCleanR stellt Werkzeuge für die Aufbereitung und Bereinigung von Hochschul- und Future-Skills-Daten bereit. Das Paket bündelt wiederkehrende Arbeitsschritte, damit Analysen reproduzierbar und konsistent bleiben.

## Installation

### Voraussetzungen

Stelle sicher, dass das Paket `remotes` installiert ist:

```r
install.packages("remotes")
```

### Installation von GitHub

```r
remotes::install_github("Stifterverband/HEXCleanR")
```

Für einen bestimmten Branch oder Commit kann das Argument `ref` verwendet werden:

```r
remotes::install_github("Stifterverband/HEXCleanR", ref = "branchname")
```

Ein erneuter Aufruf aktualisiert das Paket auf die aktuelle Version. Mit `force = TRUE` erzwingst du eine Neuinstallation.

## Funktionsüberblick

HEXCleanR deckt zentrale Schritte der Datenbereinigung ab:

- **Organisationsdaten prüfen:** `check_organisation()` erzeugt Validierungsberichte auf Basis definierter Qualitätsregeln.
- **Future-Skills-Klassifikation:** `classify_fs()` ordnet Texte Kategorien zu, `get_unclassified_data()` listet Einträge ohne Klassifikation auf.
- **Sprach- und Inhaltsprüfung:** `detect_lang_with_openai()` ergänzt Sprachangaben, `remove_semantic_na_values()` markiert inhaltsleere Texte.
- **Qualitätskontrollen:** `check_db()` führt Struktur- und Plausibilitätschecks durch, `check_nas()` visualisiert fehlende Werte.
- **Projektvorbereitung:** `use_cleaning_template()` erstellt modulare Vorlagen für neue Datenquellen.

## Dokumentation

Die vollständige Paket-Website inklusive Referenz und Vignetten ist unter [stifterverband.github.io/HEXCleanR](https://stifterverband.github.io/HEXCleanR/) verfügbar.
