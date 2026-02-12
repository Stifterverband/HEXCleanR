
# HEXCleanR <img src="man/figures/HEXCleanR_Logo.svg" align="right" height="139" />

Willkommen bei **HEXCleanR** – Dem Werkzeugkasten für die Aufbereitung und Bereinigung von HEX-Daten.

---

## 🚀 Schnellstart

**1. Voraussetzungen:**

Installiere das Hilfspaket `remotes`, falls noch nicht vorhanden:

```r
install.packages("remotes")
```

**2. Installation vom internen Git-Server:**

```r
remotes::install_git("http://srv-data01:30080/hex/hexcleanr")
```

**3. Paket aktualisieren:**

Einfach den Installationsbefehl erneut ausführen, um die neueste Version zu erhalten.

**4. Installation eines bestimmten Branches/Commits:**

```r
remotes::install_github("maltehueckstaedt/HEXCleanR", ref = "dev")
```

Mit `force = TRUE` kann eine erzwungene Neuinstallation erfolgen:

```r
remotes::install_git("http://srv-data01:30080/hex/hexcleanr", force = TRUE)
```

---

## 📖 Was macht HEXCleanR?

HEXCleanR bietet einen modularen Werkzeugkasten für die Datenbereinigung und -prüfung im Hochschulkontext. Die wichtigsten Funktionen im Überblick:

- **Organisationsdaten prüfen & bereinigen:**
  - `check_organisation()`: Prüft Organisationsangaben auf definierte Qualitätsregeln und gibt einen übersichtlichen Report aus.

- **Kursdaten und Future Skills klassifizieren:**
  - `classify_fs()`: Identifiziert und klassifiziert Future-Skills-Schlagwörter in Kursdaten mithilfe eines KI-Modells.
  - get_unclassified_data(): Findet alle Kurse, die noch keiner Future-Skills-Kategorie zugeordnet wurden.

- **Sprachklassifikation automatisieren:**
  - `detect_lang_with_openai()`: Erkennt die Sprache von Texten (z. B. Kurstitel) automatisiert per OpenAI-API und ergänzt fehlende Werte.

- **Datenqualität und Plausibilität prüfen:**
  - `check_db()`: Führt umfassende Struktur-, Typ- und Plausibilitätsprüfungen für die aufbereiteten Daten durch.
  - check_nas(): Visualisiert die NA-Konzentration pro Variable und Semester.

- **Rohdaten vereinheitlichen & säubern:**
  - `remove_semantic_na_values()`: Setzt zu kurze oder inhaltlich leere Texte auf NA.
  - use_cleaning_template(): Erstellt ein individuelles Cleaning-Template für neue Universitäten/Projekte.

Alle Funktionen sind so gestaltet, dass sie sich flexibel in bestehende Workflows integrieren lassen und die Nachvollziehbarkeit der Datenaufbereitung erhöhen.

---

## 📚 Dokumentation

Die Dokumentation wird zukünftig als GitLab-Pages bereitgestellt. Bis dahin finden Sie die aktuelle `.pdf`-Dokumentation [hier](docs/manual).

---

## 🛠️ Problembehandlung

**Fehlermeldung bei der Installation?**

```
Fehler: Failed to install 'unknown package' from Git:
  Error in 'git2r_remote_ls': too many redirects or authentication replays
```

**Lösung:**

```r
# R Session neu starten
.rs.restartR()

# Danach Installation erneut versuchen (es sollte nach Passwort fragen):
remotes::install_git(
  "http://benutzerkuerzel@srv-data01:30080/hex/hexcleanr",
  git = "external"
) 
```