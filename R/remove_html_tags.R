#' HTML-Tags aus einem Dataframe entfernen
#'
#' Erkennt Zeichenspalten, die HTML-Tags oder kodierte Entitäten enthalten, und
#' bereinigt diese, indem zunächst HTML-Entitäten dekodiert und anschließend alle
#' HTML-Tags entfernt werden. Spalten ohne HTML-Inhalt bleiben unverändert.
#'
#' @param df Ein Dataframe.
#'
#' @return Der Eingabe-Dataframe, bei dem HTML-Tags und Entitäten aus allen
#'   erkannten Zeichenspalten entfernt wurden.
#'
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   name = c("Alice", "Bob"),
#'   bio  = c("<p>Hallo &amp; Willkommen</p>", "Kein HTML hier")
#' )
#' remove_html_tags(df)
#' }
#'
#' @importFrom textutils HTMLdecode HTMLrm
#' @importFrom dplyr select summarise across mutate filter pull
#' @importFrom tidyr pivot_longer
#' @importFrom stringr str_detect
#'
#' @export

remove_html_tags <- function(df) {

  if (!requireNamespace("textutils", quietly = TRUE)) {
    stop("Package 'textutils' is required for remove_html_tags(). Please install it using install.packages('textutils').")
  }

  html_pattern <- paste(
    "<[^>]+>",            # beliebiges HTML-Tag 
    "<!--.*?-->",         # HTML-Kommentare
    "&[a-zA-Z]+;",       # benannte Entitäten 
    "&#[0-9]+;",         # dezimale numerische Entitäten 
    "&#x[0-9a-fA-F]+;",  # hexadezimale numerische Entitäten
    sep = "|"
  )

  html_cols <- df |>
    select(where(is.character)) |>
    summarise(across(everything(), ~ any(str_detect(., html_pattern), na.rm = TRUE))) |>
    pivot_longer(everything()) |>
    filter(value) |>
    pull(name)

  if (length(html_cols) == 0) {
    message("No HTML detected. Returning df unchanged.")
    return(df)
  }

  decode_and_remove <- function(x) HTMLdecode(x) |> HTMLrm()

  n_cols <- length(html_cols)

  for (i in seq_along(html_cols)) {
    col <- html_cols[i]
    message(sprintf("[%d/%d] Cleaning HTML from column: %s", i, n_cols, col))

    df <- df |>
      mutate(!!sym(col) := {
        x <- .data[[col]]
        has_html <- str_detect(x, html_pattern) & !is.na(x)
        x[has_html] <- decode_and_remove(x[has_html])
        x
      })
  }

  message("Done.")
  df

}