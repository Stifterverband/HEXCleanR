# HEXCleanR <img src="man/figures/HEXCleanR_Logo.svg" align="right" height="139" />

## Beschreibung 

Das Paket stellt Hilfsfunktionen zur qualitätsgesicherten Aufbereitung und Bereinigung der im HEX anfallenden Daten bereit. Es unterstützt u.a. insbesondere bei der Prüfung und Säuberung von Organisationsangaben, dem Erkennen auffälliger Veränderungen in kategorialen Merkmalen über Semester hinweg sowie der Vereinheitlichung und Plausibilisierung von Rohdaten aus unterschiedlichen Quellen.

## Installation

`HEXCleanR` kann folgendermaßen installiert werden:

Installiere zuerst das Hilfspaket `remotes`, falls noch nicht vorhanden:

```r
install.packages("remotes")
```

Installation von der öffentlichen GitHub-Repository:

```r
remotes::install_github("maltehueckstaedt/HEXCleanR")
```

Paket aktualisieren: Einfach den Installationsbefehl erneut ausführen, um die neueste Version von GitHub zu installieren:

```r
remotes::install_github("maltehueckstaedt/HEXCleanR")
```

Installation eines bestimmten Branches oder Commits:

```r
remotes::install_github("maltehueckstaedt/HEXCleanR", ref = "dev")
```

Alternative: Installation vom internen Git-Server (bestehende Anleitung)

```r
remotes::install_git("http://srv-data01:30080/hex/hexcleanr")
```

Wenn das Paket vom internen Server mit Überschreiben/Erzwungener Neuinstallation installiert werden soll, kann `force = TRUE` verwendet werden:

```r
remotes::install_git("http://srv-data01:30080/hex/hexcleanr", force = TRUE)
```

## Dokumentation

Die Dokumentation von `HEXcleanR` soll mittelfristig als Gitlab-Pages bereitgestellt werden (Johannes eroiert das Feature für GitLab derzeit). Bis dahin kann die als `.pdf` vorliegende Dokumentation genutzt werden. Diese findest sich [hier](http://srv-data01:30080/hex/hexcleanr/-/raw/main/docs/manual/HEXCleanR_0.5.13.pdf?inline=false).