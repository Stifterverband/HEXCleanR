#' Setzt Werte einer String-Variable NA, wenn diese weniger als 20 Zeichen enthalten
#'
#' Diese Funktion ersetzt Einträge in einem Vektor von Texten durch `NA`,
#' wenn die Anzahl der Buchstaben (ohne Satzzeichen) kleiner als ein definierter Schwellenwert ist.
#'
#' @param texts Ein Vektor von Zeichenketten (Character-Vektor), der bereinigt werden soll.
#' @param min_num_letters Minimale Anzahl an Buchstaben (Standard: 20), die ein Text enthalten muss, 
#'   damit er nicht als semantisches NA betrachtet wird.
#'
#' @return Ein Character-Vektor, in dem zu kurze Texte durch `NA` ersetzt wurden.
#'
#' @importFrom stringr str_replace_all
#'
#' @export
remove_semantic_na_values <- function(texts, min_num_letters = 20) {
  letters_only <- stringr::str_replace_all(texts, "[[:punct:]]", "")
  length_letters_only <- lapply(letters_only, nchar)
  texts[length_letters_only < min_num_letters] <- NA
  return(texts)
}