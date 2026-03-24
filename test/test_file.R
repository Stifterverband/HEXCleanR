# Beispielaufruf mit 3 Key-Variablen
remotes::install_git("http://srv-data01:30080/hex/hexcleanr", force = TRUE)
 
# 2. Dann Version erhoehen
usethis::use_version("patch")
 
devtools::document()
devtools::build_manual(path = "docs/manual")

devtools::load_all()
devtools::document()
devtools::unload()
pkgdown::clean_site(force = TRUE)
pkgdown::build_site()