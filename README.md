# Zagrumes974 <img src='inst/app/www/logo-zagrumes974.png' height="300px" align="right" style="padding: 1px;"/>


<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/)
<!-- badges: end -->


**Zagrumes974** is a shiny app developped by CIRAD about epidemiological monitoring of citrus fruits against citrus greening (Huanglongbing) in Réunion Island.

***

<!-- - Contact email: ipsim-chayote@cirad.fr   -->
<!-- - Developped at CIRAD by [Anna Doizy](doana-r.com), Isaure Païtard, Frederic Chiroleu and Jean-Philippe Deguine   -->
<!-- - Associated publication: [Qualitative modeling of fruit fly injuries on chayote in Réunion: Development and transfer to users](https://doi.org/10.1016/j.cropro.2020.105367)   -->



## Online usage


<!-- Just go to https://pvbmt-apps.cirad.fr/apps/ipsim-chayote/?lang=en. -->

<!-- English, French and Spanish versions are available. -->



## Local usage

You can install **{zagrumes974}** R package from [gitlab](https://gitlab.com/doana-r/zagrumes974) with:

``` r
remotes::install_gitlab("doana-r/zagrumes974")
```


Run this command to launch the app locally:

``` r
library(zagrumes974)
run_app("en")

# or the french version:
run_app("fr")
```

