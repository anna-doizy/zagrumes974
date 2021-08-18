
<!-- README.md is generated from README.Rmd. Please edit that file -->

# IPSIM-*Cirsium* <img src='inst/app/www/logo-ipsimcirsium.png' height="300px" align="right" style="padding: 1px;"/>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/)
<!-- badges: end -->

**IPSIM-*Cirsium*** is a tool developped by INRA for professionals in
agriculture to predict and manage the damage caused by thistle on crops
in France.

------------------------------------------------------------------------

<!-- - Contact email: ipsim-chayote@cirad.fr   -->
<!-- - Developped at CIRAD by [Anna Doizy](doana-r.com), Isaure Païtard, Frederic Chiroleu and Jean-Philippe Deguine   -->
<!-- - Associated publication: [Qualitative modeling of fruit fly injuries on chayote in Réunion: Development and transfer to users](https://doi.org/10.1016/j.cropro.2020.105367)   -->

## Online usage

<!-- Just go to https://pvbmt-apps.cirad.fr/apps/ipsim-chayote/?lang=en. -->
<!-- English, French and Spanish versions are available. -->

## Local usage

You can install **{ipsimcirsium}** R package from
[gitlab](https://gitlab.com/doana-r/ipsimcirsium) with:

``` r
remotes::install_gitlab("doana-r/ipsimcirsium")
```

Run this command to launch the app locally:

``` r
library(ipsimcirsium)
run_app("en")

# or the french version:
run_app("fr")
```
