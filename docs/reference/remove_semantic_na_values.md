# Setzt Werte einer String-Variable NA, wenn diese weniger als 20 Zeichen enthalten

Diese Funktion ersetzt Einträge in einem Vektor von Texten durch `NA`,
wenn die Anzahl der Buchstaben (ohne Satzzeichen) kleiner als ein
definierter Schwellenwert ist.

## Usage

``` r
remove_semantic_na_values(texts, min_num_letters = 20)
```

## Arguments

- texts:

  Ein Vektor von Zeichenketten (Character-Vektor), der bereinigt werden
  soll.

- min_num_letters:

  Minimale Anzahl an Buchstaben (Standard: 20), die ein Text enthalten
  muss, damit er nicht als semantisches NA betrachtet wird.

## Value

Ein Character-Vektor, in dem zu kurze Texte durch `NA` ersetzt wurden.
