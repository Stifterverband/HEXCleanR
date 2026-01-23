# HEXCleanR <img src="man/figures/HEXCleanR_Logo.svg" align="right" height="139" />

## Beschreibung 

Das Paket stellt Hilfsfunktionen zur qualitätsgesicherten Aufbereitung und Bereinigung der im HEX anfallenden Daten bereit. Es unterstützt u.a. insbesondere bei der Prüfung und Säuberung von Organisationsangaben, dem Erkennen auffälliger Veränderungen in kategorialen Merkmalen über Semester hinweg sowie der Vereinheitlichung und Plausibilisierung von Rohdaten aus unterschiedlichen Quellen.

## Installation

`HEXCleanR` kann folgendermaßen installiert werden:

```r
remotes::install_git("http://srv-data01:30080/hex/hexcleanr")
```

### Paket-Update: Wie aktualisiere ich HEXCleanR?

Wenn du bereits eine ältere Version von `HEXCleanR` installiert hast und auf die neueste Version updaten möchtest, kannst du den Installationsbefehl mit dem Argument `force = TRUE` ausführen. Dadurch wird die aktuellste Version von GitHub installiert und die alte Version überschrieben:

```r
remotes::install_git("http://srv-data01:30080/hex/hexcleanr", force = TRUE)
```

Wenn das Paket aus einem bestimmten Branch installiert werden soll, geht dies so:

```r
remotes::install_git(
  url = "http://srv-data01:30080/hex/hexcleanr",
  ref = "dev",
  force = TRUE
)
```

## Dokumentation

Die Dokumentation von `HEXcleanR` soll mittelfristig als Gitlab-Pages bereitgestellt werden (Johannes eroiert das Feature für GitLab derzeit). Bis dahin kann die als `.pdf` vorliegende Dokumentation genutzt werden. Diese findest sich [hier](http://srv-data01:30080/hex/hexcleanr/-/raw/main/docs/manual/HEXCleanR_0.5.13.pdf?inline=false).