# HEXcleanR [![HEXCleanR website](reference/figures/HEXCleanR_Logo.png)](https://github.com/Stifterverband/HEXCleanR)

Willkommen bei **HEXCleanR** – Dem Werkzeugkasten für die Aufbereitung
und Bereinigung von HEX-Daten.

------------------------------------------------------------------------

## 🚀 Schnellstart

**1. Voraussetzungen:**

Installiere das Hilfspaket `remotes`, falls noch nicht vorhanden:

``` r

install.packages("remotes")
```

**2. Installation von GitHub:**

``` r

remotes::install_github("Stifterverband/HEXCleanR")
```

**3. Paket aktualisieren:**

Führe den Installationsbefehl erneut aus, um die neueste Version zu
erhalten.

**4. Installation eines bestimmten Branches/Commits:**

``` r

remotes::install_github("Stifterverband/HEXCleanR", ref = "branchname")
```

Mit `force = TRUE` kann eine erzwungene Neuinstallation erfolgen:

``` r

remotes::install_github("Stifterverband/HEXCleanR", force = TRUE)
```

------------------------------------------------------------------------

## 📖 Was macht HEXCleanR?

HEXCleanR bietet einen modularen Werkzeugkasten für die Datenbereinigung
und -prüfung im Hochschulkontext. Die wichtigsten Funktionen im
Überblick:

- **Organisationsdaten prüfen & bereinigen:**
  - [`check_organisation()`](https://github.com/Stifterverband/HEXCleanR/reference/check_organisation.md):
    Prüft Organisationsangaben auf definierte Qualitätsregeln und gibt
    einen übersichtlichen Report aus.
- **Kursdaten und Future Skills klassifizieren:**
  - [`classify_fs()`](https://github.com/Stifterverband/HEXCleanR/reference/classify_fs.md):
    Identifiziert und klassifiziert Future-Skills-Schlagwörter in
    Kursdaten mithilfe eines KI-Modells.
  - get_unclassified_data(): Findet alle Kurse, die noch keiner
    Future-Skills-Kategorie zugeordnet wurden.
- **Sprachklassifikation automatisieren:**
  - [`detect_lang_with_openai()`](https://github.com/Stifterverband/HEXCleanR/reference/detect_lang_with_openai.md):
    Erkennt die Sprache von Texten (z. B. Kurstitel) automatisiert per
    OpenAI-API und ergänzt fehlende Werte.
- **Datenqualität und Plausibilität prüfen:**
  - [`check_db()`](https://github.com/Stifterverband/HEXCleanR/reference/check_db.md):
    Führt umfassende Struktur-, Typ- und Plausibilitätsprüfungen für die
    aufbereiteten Daten durch.
  - check_nas(): Visualisiert die NA-Konzentration pro Variable und
    Semester.
- **Rohdaten vereinheitlichen & säubern:**
  - [`remove_semantic_na_values()`](https://github.com/Stifterverband/HEXCleanR/reference/remove_semantic_na_values.md):
    Setzt zu kurze oder inhaltlich leere Texte auf NA.
  - use_cleaning_template(): Erstellt ein individuelles
    Cleaning-Template für neue Universitäten/Projekte.

Alle Funktionen sind so gestaltet, dass sie sich flexibel in bestehende
Workflows integrieren lassen und die Nachvollziehbarkeit der
Datenaufbereitung erhöhen.

------------------------------------------------------------------------

## 📚 Dokumentation

Die Dokumentation wird zukünftig als GitHub-Pages bereitgestellt. Bis
dahin finden Sie die aktuelle `.pdf`-Dokumentation
[hier](https://github.com/Stifterverband/HEXCleanR/docs/manual).

------------------------------------------------------------------------

## 🛠️ Problembehandlung

**Fehlermeldung bei der Installation?**

Bitte prüfe, ob das Paket `remotes` installiert ist und du eine aktuelle
R-Version verwendest. Bei Problemen mit GitHub-Authentifizierung ggf.
ein Personal Access Token (PAT) nutzen.
