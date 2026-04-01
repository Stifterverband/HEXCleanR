#' Speichert semesterweise Teilmengen von `db_data` als RDS-Dateien
#'
#' Diese Funktion iteriert ueber alle eindeutigen Werte in `db_data$semester`
#' und speichert pro Semester eine Teilmenge als `db_data_<semester>.rds` in den
#' passenden Unterordner unterhalb von `path`. Gespeichert wird nur, wenn der
#' jeweilige Ordner bereits existiert.
#'
#' @param db_data Data Frame mit mindestens einer Spalte `semester`.
#' @param path Basisverzeichnis, unter dem pro Semester ein Unterordner erwartet
#'   wird.
#'
#' @return Unsichtbar eine Liste mit zwei Zeichenvektoren:
#'   \describe{
#'     \item{saved}{Dateipfade erfolgreich gespeicherter RDS-Dateien.}
#'     \item{missing_dirs}{Ordnerpfade, die nicht existierten.}
#'   }
#'
#' @examples
#' db_data <- tibble::tibble(
#'   semester = c("2025w", "2025w", "2026s"),
#'   titel = c("Kurs A", "Kurs B", "Kurs C")
#' )
#'
#' base_path <- tempdir()
#' dir.create(file.path(base_path, "2025w"))
#' dir.create(file.path(base_path, "2026s"))
#'
#' create_baby_dbs(db_data, base_path)
#'
#' @export
create_baby_dbs <- function(db_data, path) {
  if (missing(db_data) || !is.data.frame(db_data)) {
    stop("`db_data` muss als Data Frame uebergeben werden.", call. = FALSE)
  }

  if (!"semester" %in% names(db_data)) {
    stop("`db_data` muss eine Spalte `semester` enthalten.", call. = FALSE)
  }

  if (missing(path) || !is.character(path) || length(path) != 1 || !nzchar(path)) {
    stop("`path` muss als einzelner, nicht-leerer Zeichenwert uebergeben werden.", call. = FALSE)
  }

  semesters <- unique(as.character(db_data$semester))
  semesters <- semesters[!is.na(semesters)]

  saved_paths <- character()
  missing_dirs <- character()

  for (sem in semesters) {
    folder_path <- file.path(path, sem)
    file_path <- file.path(folder_path, paste0("db_data_", sem, ".rds"))

    if (dir.exists(folder_path)) {
      saveRDS(db_data[db_data$semester == sem, , drop = FALSE], file_path)
      message("Gespeichert: ", file_path)
      saved_paths <- c(saved_paths, file_path)
    } else {
      message("Ordner fehlt: ", folder_path)
      missing_dirs <- c(missing_dirs, folder_path)
    }
  }

  invisible(list(
    saved = saved_paths,
    missing_dirs = missing_dirs
  ))
}
