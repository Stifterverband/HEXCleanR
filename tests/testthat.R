# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
# * https://testthat.r-lib.org/articles/special-files.html

library(testthat)
library(HEXCleanR)

devtools::load_all()
testthat::test_local()

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
