# Beispielaufruf mit 3 Key-Variablen
remotes::install_git("http://srv-data01:30080/hex/hexcleanr", force = TRUE)

getwd()
devtools::document()
devtools::install()
devtools::document()
devtools::load_all()

tools::checkRd("man/check_organisation.Rd")
tools::checkRd("man/check_db.Rd")
tools::checkRd("man/classify_fs.Rd")
tools::checkRd("man/merge_and_join_classified_data.Rd")
tools::checkRd("man/remove_semantic_na_values.Rd")
tools::checkRd("man/get_unclassified_data.Rd")

devtools::build_manual(path = "docs/manual")

deps <- renv::dependencies()
deps$Package
for (pkg in deps$Package) {
  usethis::use_package(pkg)
}

# 2. Dann Version erhoehen
usethis::use_version("patch")

# 3. aenderungen pushen
usethis::use_git_push() 

HEXCleanR::use_cleaning("my_cleaning_script.R")


# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# Update SVCleanR ----------------------------------------
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


getwd()
devtools::load_all() 
# Lade Testdaten
df <- data.frame(
  nummer = NA_character_,
  titel = c(
    "53-974 Berühmte Ungarn",
    "52-246 Auf dem Trödelmarkt der Träume: Michael Ende [IfG 225]",
    "58-101 Orientierungseinheit Katholische Theologie Gruppe B",
    "45-820 Vorlesung mit Tutorium: Einführung in die Fachdidaktik Mathematik",
    "56-712 (6 LP) S: Renaissance – eine musikhistorische Epoche? - PRÄSENZ (ONLINE AM 15.12.2021 UND 19.01.2022)",
    "64-135 Proseminar Bio-inspired Computing",
    "57-538 SK: Einführung in die Zoroastrisch-Mittelpersische Literatur: Lektüre und Textanalyse(Pahlavi III )[IRA 1][IRA W][ISL W][TUR W][FSWB-BA][[FSWB-MA]FW-uni][KS]",
    "56-638 (2LP) S Schatz oder Schandfleck? Baukulturelle Bildung und Denkmal-Vermittlung (Sommerkurs Denkmalpflege)",
    "71-02.506 Arbeits- und Organisationspsychologie, Aufbauseminar II, A: Online Coaching (WiSe 21/22)",
    "52-143a Übung zu Kulturgutdigitalisierung: Analoge Dokumente digital erschließen und erforschen [GL-M02] [SLM-WB] [Master-WB] [SG-SLM]"
  ),
  kursbeschreibung = c(
    "Die biblische Urgeschichte ... Übersetzungen zur Verfügung gestellt.",
    "This class is mainly aimed at students in the teaching degree programme ... business-related material to work on.",
    "Ludwig van Beethovens 9. Symphonie ... sogenannten Vokalsymphonie des langen 19. Jahrhunderts gegeben.",
    "Exkursion nach Burgund vom 6.-10. Juli 2022 ... keine Möglichkeit einer späteren Anmeldung während der Ummelde- und Korrekturphase).",
    "Das Proseminar bietet eine Einführung ... Bestehen der Abschlussklausur in der letzten Sitzung.",
    "Fehlerfortpflanzung, Koordinatensysteme ... Einführung zur Fourier-Analyse",
    "Die Mikroökonomik untersucht die Entscheidungen ... vertraut.",
    "In diesem Kurs beschäfitgen wir uns ... China, Korea und Japan.",
    "Das subsaharische Afrika gilt als einer der konfliktreichsten Regionen ... überprüft und abschließend in einem Vergleich zusammengeführt werden.",
    "2020 erhielt Anne Weber für Annette, ein Heldinnenepos ... Zwecke werden sie ausgerichtet?"
  ),
  lernziele = c(
    "Die Lehrveranstaltung verfolgt zwei übergeordnete Ziele ... und insbesondere die experimentelle Forschung als quantitative Forschungsmethode kennenzulernen.",
    "Ziel des Studienprojektes ist, Studierenden die Möglichkeit zu geben ... Präsentation und Publikation der Ergebnisse.",
    "- Sie vertiefen Ihre Kenntnisse über Grundvorstellungen ... Gestaltungsmöglichkeiten von Übungsprozessen anhand dieser Übungen.",
    "Die Lernziele des Kurses sind durch den Gemeinsamen Europäischen Referenzrahmen ... eigene Ideen oder Meinungen von jenen der Quellentexte zu unterscheiden.",
    "Das Modul bietet eine Einführung in multivariate Analyseverfahren ... Anwendung unterschiedlicher Techniken.",
    "Die Vorlesung soll einen Überblick über die methodischen Grundlagen ... eine herausragende Rolle, es handelt sich um eine Kernqualifikation für viele Medienberufe.",
    "Die Seminarteilnehmer:innen entwickeln ein vertieftes Verständnis einer digitalen Gesellschaft ... diskutieren.",
    "Die Seminarteilnehmer*innen entwickeln ein vertieftes Verständnis der Geschichte ... analysieren und diskutieren.",
    "Die Studierenden können ... Musikunterricht unter verschiedenen didaktischen Gesichtspunkten beobachten, analysieren und bewerten.",
    "Siehe FSB Teilstudiengang „Erziehungswissenschaft“ innerhalb der Lehramtsstudiengänge der Universität Hamburg Modulbeschreibung \"Einführung in die Fachdidaktik Sozialwissenschaften\""
  ),
  stringsAsFactors = FALSE
)


raw_data <- df
library(dplyr)
glimpse(raw_data)
db_data_path <- "vignettes/data/test_db.rds"
model_path <- "Chernoffface/fs-setfit-multilable-model"

resutl <- classify_fs(raw_data, db_data_path, model_path, key_vars = c("titel", "nummer"))
glimpse(resutl)
 # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
 # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
 # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
 # Update SVCleanR ----------------------------------------
 # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
 # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
 # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

getwd()
devtools::load_all()
library(dplyr)
library(pointblank)
library(tidyverse)

db_data_universitaet_jena <- readRDS("C:/SV/HEX/Scraping/data/single_universities/Friedrich-Schiller-Universitaet_Jena/db_data_fsu_jena.RDS")
 
set.seed(123) # Fuer Reproduzierbarkeit
n <- nrow(db_data_universitaet_hamburg)
na_indices <- sample(1:n, size = floor(0.1 * n)) # z.B. 10% der Zeilen
db_data_universitaet_hamburg$semester[na_indices] <- NA


agent <- check_db(db_data_universitaet_jena)
class(agent)

agent <- check_organisation(db_data_universitaet_jena, organisation_col = "organisation")

get_data_extracts(agent, i = 53)  |> pull(semester)


check_distinct_level_change(db_data_universitaet_jena, 
                            organisation, 
                            semester, 
                            threshold = 0.75)


devtools::document()
devtools::build_manual()

tinytex::pdflatex("--version")
tinytex::is_tinytex()
tinytex::add_tinytex_to_path()
tinytex::tinytex_root()
system("R CMD Rd2pdf .")
tinytex::install_tinytex(force = TRUE)
tinytex::tlmgr_install("makeindex")


Sys.setenv(
  PATH = paste(
    "C:/Users/mhu/AppData/Roaming/TinyTeX/bin/windows",
    Sys.getenv("PATH"),
    sep = .Platform$path.sep
  )
)


Sys.which("pdflatex")


# pkgdown::build_reference()
# usethis::use_pkgdown()
# pkgdown::build_site()
# pkgdown::build_site()
# pkgdown::clean_site()
pkgdown::clean_site(force = TRUE)
# pkgdown::build_site()

install.packages(c("bslib", "downlit", "xml2", "quarto", "jsonlite"))


devtools::load_all()

use_cleaning_template("my_university")

remove_semantic_na_values(db_data_universitaet_jena$kursbeschreibung, min_num_letters = 30)

db_data_universitaet_jena  |>
  mutate(
    kursbeschreibung_cleaned = remove_semantic_na_values(kursbeschreibung, min_num_letters = 30)
  )

devtools::document()
devtools::build_manual(path = "docs/manual")
