#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# CONFIGURATION --------------------------------------------
#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

UNIVERSITY_FOLDER <- "Universitaet_Koblenz" 
BASE_PATH         <- "C:/SV/HEX/Scraping/data/single_universities"

#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# SETUP ----------------------------------------------------
#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, HEXCleanR)
devtools::load_all()

#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# LOAD & CLEAN ---------------------------------------------
#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

raw_data <- load_data_from_sp(university_folder = UNIVERSITY_FOLDER) |>
  drop_full_na_columns() |>
  squish_character_columns()

#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# CHECK DATA -----------------------------------------------
#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

raw_data |> 
  check_semester_n() 
  
raw_data |>
  plot_na_balloons(grp_var = semester_y)
    
#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# DATA PREPARATION -----------------------------------------
#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# auf NA gesetzt -------------------------------------------
# anmerkungen       – nicht vorhanden
# dozierende        – nur "N.N." Einträge
# ects              – nicht vorhanden
# organisation_orig – nicht vorhanden

## organisation_orig/organisation --------------------------

raw_data <- raw_data %>%
  mutate(organisation_orig = organisation) %>%
  mutate(organisation = map_chr(einrichtung, ~ paste(unlist(.x), collapse = " ; ")))

raw_data |>
  select(!is.list) |>
  check_organisation()

 

## --------------------- fakultaet -------------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment: 
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

## --------------------- hochschule ------------------------

raw_data$hochschule <- ""


## --------------------- hochschule_kurz -------------------

raw_data$hochschule_kurz <- ""

## --------------------- institut --------------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment: 
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- kursbeschreibung-------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- kursformat_original ---------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- kursformat_recoded ----------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment: 
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

raw_data <- raw_data %>%
  mutate(
    kurs_vorl = as.integer(str_detect(kursformat_original, regex("Vorlesung|Lecture", ignore_case = TRUE))),
    kurs_sem  = as.integer(str_detect(kursformat_original, regex("Seminar", ignore_case = TRUE))),
    kurs_ueb  = as.integer(str_detect(kursformat_original, regex("Übung|Tutorium|Exercise|Repetitorium", ignore_case = TRUE))),
    kurs_aus  = as.integer(str_detect(kursformat_original, regex("Kolleg|Colloquium|Arbeitsgemeinschaft", ignore_case = TRUE))),
    kurs_erfahr = as.integer(str_detect(kursformat_original, regex("Exkursion|Praktikum|Projekt", ignore_case = TRUE))),
    kurs_sprach = as.integer(str_detect(kursformat_original, regex("Sprachkurs", ignore_case = TRUE))))


raw_data <- raw_data %>%
  mutate(sum_format = kurs_vorl + kurs_sem + kurs_ueb + kurs_aus + kurs_erfahr + kurs_sprach,
        kursformat_recoded = case_when(
          sum_format == 1 & kurs_vorl == 1 ~ "Vorlesung",
          sum_format == 1 & kurs_sem == 1 ~ "Seminar",
          sum_format == 1 & kurs_ueb == 1 ~ "Übung",
          sum_format == 1 & kurs_aus == 1 ~ "Austausch",
          sum_format == 1 & kurs_erfahr == 1 ~ "Erfahrung",
          sum_format == 1 & kurs_sprach == 1 ~ "Sprachkurs",
          sum_format > 1 ~ "Sonstiges",
          sum_format == 0 & !is.na(kursformat_original) ~ "Sonstiges",
          TRUE ~ NA_character_
        ))


## --------------------- lehrtyp ---------------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- lernmethode -----------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- lernziele -------------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- literatur -------------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- module-----------------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- nummer ----------------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- pfad ------------------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- pruefung --------------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- scrape_datum ----------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- titel -----------------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- sprache_original ------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- sprache_recoded -------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# custom case_when to use all valid values
# from sprache_original
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

raw_data <- raw_data |>
  mutate(
    sprache_recoded = case_when(
      sprache_original %in% c("D", "DE") ~ "Deutsch",
      sprache_original == "Deutsch und Englisch" ~ "Deutsch/Englisch",
      sprache_original == "E" ~ "Englisch",
      sprache_original == "F" ~ "Französisch",
      sprache_original == "I" ~ "Italienisch",
      sprache_original == "E" ~ "Englisch",
      sprache_original %in% c("ED", "DF", "DI", "DS")  ~ "Sonstiges", #(bilingual)
      sprache_original == "SP" ~ "Spanisch",
      TRUE ~ NA_character_
    ))

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# If `sprache_recoded` is NA: Detect the language of
# `kursbeschreibung`.
# If no description is available, assign NA.
# Otherwise, use the detected language.
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

raw_data <- raw_data |>
  mutate(
    kursbeschreibung_sprach = if_else(
      is.na(sprache_recoded) & !is.na(kursbeschreibung),
      cld3::detect_language(kursbeschreibung),
      NA_character_
    )
  )

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# If `sprache_recoded` & `kursbeschreibung` is NA:
# Detect the primary language of the `titel` using
# cld2 and cld3.
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

raw_data <- raw_data |>
  mutate(
    titel_sprach = case_when(
      is.na(sprache_recoded) & is.na(kursbeschreibung) & !is.na(titel) ~ coalesce(
        cld3::detect_language(titel),
        cld2::detect_language(titel, plain_text = TRUE)
      ),
      TRUE ~ NA_character_
    )
  )

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Define the sprache_recoded based on several rules:
# - If sprache_recoded could already be extracted
#   from sprache_original: use sprache_recoded
# - If `sprache_recoded` is NA, use detected language
#   from `kursbeschreibung_sprach`.
# - If `sprache_recoded` is NA &
#   kursbeschreibung_sprach is NA, use detected
#   language from `titel_sprach`.
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

raw_data <- raw_data  |>
  mutate(
    sprache_recoded = case_when(
      !is.na(sprache_recoded) ~ sprache_recoded,
      kursbeschreibung_sprach == "en" ~ "Englisch",
      kursbeschreibung_sprach == "de" ~ "Deutsch",
      kursbeschreibung_sprach == "fr" ~ "Französisch",
      kursbeschreibung_sprach == "es" ~ "Spanisch",
      kursbeschreibung_sprach == "it" ~ "Italienisch",
      kursbeschreibung_sprach == "ru" ~ "Russisch",
      kursbeschreibung_sprach == "tr" ~ "Türkisch",
      kursbeschreibung_sprach == "pt" ~ "Portugiesisch",
      kursbeschreibung_sprach == "nl" ~ "Niederländisch",
      is.na(kursbeschreibung_sprach) & titel_sprach == "en" ~ "Englisch",
      is.na(kursbeschreibung_sprach) & titel_sprach == "de" ~ "Deutsch",
      is.na(kursbeschreibung_sprach) & titel_sprach == "fr" ~ "Französisch",
      is.na(kursbeschreibung_sprach) & titel_sprach == "es" ~ "Spanisch",
      is.na(kursbeschreibung_sprach) & titel_sprach == "it" ~ "Italienisch",
      is.na(kursbeschreibung_sprach) & titel_sprach == "ru" ~ "Russisch",
      is.na(kursbeschreibung_sprach) & titel_sprach == "tr" ~ "Türkisch",
      is.na(kursbeschreibung_sprach) & titel_sprach == "pt" ~ "Portugiesisch",
      is.na(kursbeschreibung_sprach) & titel_sprach == "nl" ~ "Niederländisch",
      is.na(kursbeschreibung_sprach) & is.na(titel_sprach) & is.na(sprache_original) & is.na(sprache_recoded) ~ NA_character_,
      TRUE ~ "Sonstiges"
    )
  )

## --------------------- studiengaenge ---------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- sws -------------------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- teilnehmerzahl --------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- url -------------------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## --------------------- voraussetzungen -------------------
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## ----------------------- zusatzinformationen -------------
# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment:
# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


## ------------- select relevant columns -------------------

raw_data <- raw_data %>%
  select(any_of(c(
    "anmerkungen", "dozierende", "ects", "fakultaet", "hochschule", "hochschule_kurz",
    "institut","jahr", "kursbeschreibung", "kursformat_original", "kursformat_recoded",
    "lehrtyp", "lernmethode", "lernziele", "literatur", "module", "nummer",
    "organisation_orig", "organisation", "pfad", "pruefung", "scrape_datum", "semester",
    "sprache_original","sprache_recoded", "studiengaenge", "sws", "teilnehmerzahl",
    "titel", "url", "voraussetzungen", "zusatzinformationen"
  )))

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# CLASSIFY FS-SKILLS ---------------------------------------
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

db_data_path <- "C:/SV/HEX/Scraping/data/single_universities/UNIVERITY_NAME/db_data_UNIVERSITY_NAME.rds"

raw_data_fs <- HEXCleanR::classify_fs(raw_data,
                                      db_data_path,
                                      model_path = "Chernoffface/fs-setfit-multilable-model",
                                      key_vars = c("titel", "nummer"))

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# CREATE DB AND SAFETY-CHECK -------------------------------
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


# creating codebook ----------------------------------------
codebook <- tibble(Variablen = colnames(raw_data))

# data wrangling for hex database --------------------------
db_data <- tibble(id = 1:nrow(raw_data))

db_data$anmerkungen              <- raw_data$anmerkungen
db_data$dozierende               <- raw_data$dozierende
db_data$ects                     <- raw_data$ects
db_data$fakultaet                <- raw_data$fakultaet
db_data$hochschule               <- raw_data$hochschule
db_data$hochschule_kurz          <- raw_data$hochschule_kurz
db_data$jahr                     <- raw_data$jahr
db_data$kursbeschreibung         <- HEXCleanR::remove_semantic_na_values(raw_data$kursbeschreibung)
db_data$kursformat_original      <- raw_data$kursformat_original
db_data$kursformat_recoded       <- raw_data$kursformat_recoded
db_data$lehrtyp                  <- raw_data$lehrtyp
db_data$lernmethode              <- raw_data$lernmethode
db_data$lernziele                <- raw_data$lernziele
db_data$literatur                <- raw_data$literatur
db_data$module                   <- raw_data$module
db_data$nummer                   <- raw_data$nummer
db_data$organisation_orig        <- raw_data$organisation_orig
db_data$organisation             <- raw_data$organisation
db_data$pfad                     <- raw_data$pfad
db_data$pruefung                 <- raw_data$pruefung
db_data$scrape_datum             <- raw_data$scrape_datum
db_data$semester                 <- raw_data$semester
db_data$sprache_original         <- raw_data$sprache_original
db_data$sprache_recoded          <- raw_data$sprache_recoded
db_data$studiengaenge            <- raw_data$studiengaenge
db_data$sws                      <- raw_data$sws
db_data$teilnehmerzahl           <- raw_data$teilnehmerzahl
db_data$titel                    <- raw_data$titel
db_data$url                      <- raw_data$url
db_data$voraussetzungen          <- raw_data$voraussetzungen
db_data$zusatzinformationen      <- raw_data$zusatzinformationen
db_data$institut                 <- raw_data$institut

db_data$data_analytics_ki        <- raw_data_fs$data_analytics_ki
db_data$softwareentwicklung      <- raw_data_fs$softwareentwicklung
db_data$nutzerzentriertes_design <- raw_data_fs$nutzerzentriertes_design
db_data$it_architektur           <- raw_data_fs$it_architektur
db_data$hardware_robotikentwicklung <- raw_data_fs$hardware_robotikentwicklung
db_data$quantencomputing         <- raw_data_fs$quantencomputing

db_data$lehr_und_forschungsbereich <- NA_character_
db_data$studienbereich             <- NA_character_
db_data$faechergruppe              <- NA_character_
db_data$luf_code                   <- NA_character_
db_data$stub_code                  <- NA_character_
db_data$fg_code                    <- NA_character_

db_data$matchingart                <- NA_character_


# Safety-Check ---------------------------------------------

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment: Wir führen den allgemeinen Check durch.
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

agent_check_db <- HEXCleanR::check_db(db_data_jena)
agent_check_db

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment: Wir führen den Check für die Variable
# Organisation durch.
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

agent_check_organisation <- HEXCleanR::check_organisation(db_data_jena)
agent_check_organisation

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment: Wir führen den Distinct-Level-Change-Check
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

HEXCleanR::check_distinct_level_change_df(
  data = db_data_jena,
  group_col = semester
)

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# MERGE WITH GERIT -----------------------------------------
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment: Spiele Matching Daten an:
# vorher Verbindung zum Sharepoint herstellen!
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
hexmatch::find_names()

db_data <-
  hexmatch::import_matching_data(
    add_to_this_file = db_data,
    name_folder = "UNIVERSITY_NAME",
    collect_matching_data_from_sharepoint = TRUE
  )

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# DATA EXPORT ----------------------------------------------
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

saveRDS(raw_data, "C:/SV/HEX/Scraping/data/single_universities/UNIVERSITY_NAME/data_UNIVERSITY_NAME.rds")
saveRDS(codebook, "C:/SV/HEX/Scraping/data/single_universities/UNIVERSITY_NAME/codebook_UNIVERSITY_NAME.rds")
saveRDS(db_data, "C:/SV/HEX/Scraping/data/single_universities/UNIVERSITY_NAME/db_data_UNIVERSITY_NAME.rds")

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment: create Baby-DB-Datas
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Iteriere über alle einzigartigen Semester
unique(db_data$semester) %>%
  walk(function(sem) {
    folder_path <- file.path(path, sem)
    file_path <- file.path(folder_path, paste0("db_data_", sem, ".rds"))
    
    # Nur speichern, wenn der Ordner existiert
    if (dir.exists(folder_path)) {
      db_data %>%
        filter(semester == sem) %>%
        saveRDS(file_path)
      message("✅ Gespeichert: ", file_path)
    } else {
      message("⚠️ Ordner fehlt: ", folder_path)
    }
  })