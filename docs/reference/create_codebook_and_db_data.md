# Erstellt `codebook` und `db_data` aus Rohdaten

Diese Funktion bildet einen typischen Schritt im HEX-Cleaning ab: Aus
`raw_data` wird ein `codebook` mit den vorhandenen Variablennamen
erzeugt und daraus anschliessend ein `db_data`-Datensatz im erwarteten
HEX-Format aufgebaut. Die benoetigten Spalten in `raw_data` und
`raw_data_fs` muessen vollstaendig vorhanden sein. Nur die fachlichen
Metadatenfelder, die erst spaeter im Prozess befuellt werden, werden mit
`NA` angelegt.

## Usage

``` r
create_codebook_and_db_data(raw_data, raw_data_fs = NULL)
```

## Arguments

- raw_data:

  Data Frame mit den Rohdaten.

- raw_data_fs:

  Data Frame mit Future-Skills-Spalten.

## Value

Eine Liste mit zwei Elementen:

- codebook:

  Ein Tibble mit einer Spalte `Variablen`.

- db_data:

  Ein Tibble im erwarteten HEX-DB-Format.

## Examples

``` r
raw_data <- tibble::tibble(
  anmerkungen = "Hinweis",
  dozierende = "Prof. Beispiel",
  ects = "5",
  fakultaet = "Informatik",
  hochschule = "Universitaet Musterstadt",
  hochschule_kurz = "UMS",
  jahr = "2026",
  kursbeschreibung = "Dies ist eine ausreichend lange Kursbeschreibung.",
  kursformat_original = "Vorlesung",
  kursformat_recoded = "Vorlesung",
  lehrtyp = "Pflicht",
  lernmethode = "Praesenz",
  lernziele = "Lernziel",
  literatur = "Buch",
  module = "Modul A",
  nummer = "101",
  organisation_orig = "Original",
  organisation = "Organisation",
  pfad = "/tmp/pfad",
  pruefung = "Klausur",
  scrape_datum = "2026-04-01",
  semester = "2026s",
  sprache_original = "Deutsch",
  sprache_recoded = "Deutsch",
  studiengaenge = "BSc",
  sws = "2",
  teilnehmerzahl = "30",
  titel = "Kurs A",
  url = "https://example.org",
  voraussetzungen = "Keine",
  zusatzinformationen = "Info",
  institut = "Institut A"
)

raw_data_fs <- tibble::tibble(
  data_analytics_ki = 1,
  softwareentwicklung = 0,
  nutzerzentriertes_design = 0,
  it_architektur = 1,
  hardware_robotikentwicklung = 0,
  quantencomputing = 0
)

res <- create_codebook_and_db_data(raw_data, raw_data_fs)
res$codebook
#> # A tibble: 32 × 1
#>    Variablen          
#>    <chr>              
#>  1 anmerkungen        
#>  2 dozierende         
#>  3 ects               
#>  4 fakultaet          
#>  5 hochschule         
#>  6 hochschule_kurz    
#>  7 jahr               
#>  8 kursbeschreibung   
#>  9 kursformat_original
#> 10 kursformat_recoded 
#> # ℹ 22 more rows
res$db_data
#> # A tibble: 1 × 46
#>      id anmerkungen dozierende  ects  fakultaet hochschule hochschule_kurz jahr 
#>   <int> <chr>       <chr>       <chr> <chr>     <chr>      <chr>           <chr>
#> 1     1 Hinweis     Prof. Beis… 5     Informat… Universit… UMS             2026 
#> # ℹ 38 more variables: kursbeschreibung <chr>, kursformat_original <chr>,
#> #   kursformat_recoded <chr>, lehrtyp <chr>, lernmethode <chr>,
#> #   lernziele <chr>, literatur <chr>, module <chr>, nummer <chr>,
#> #   organisation_orig <chr>, organisation <chr>, pfad <chr>, pruefung <chr>,
#> #   scrape_datum <chr>, semester <chr>, sprache_original <chr>,
#> #   sprache_recoded <chr>, studiengaenge <chr>, sws <chr>,
#> #   teilnehmerzahl <chr>, titel <chr>, url <chr>, voraussetzungen <chr>, …
```
