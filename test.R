# deployment to shinyapps.io with rsconnect

# SETUP
# git remote set-url --add --push origin git@github.com:anna-doizy/ipsimcirsium.git
# git remote set-url --add --push origin git@gitlab.com:doana-r/ipsimcirsium.git
# git remote -v
# origin  git@gitlab.com:doana-r/ipsimcirsium.git (fetch)
# origin  git@github.com:anna-doizy/ipsimcirsium.git (push)
# origin  git@gitlab.com:doana-r/ipsimcirsium.git (push)

# EACH TIME before deployment
# update all packages
# change "update date" in the ui
# check and install this package
# check if parse("inst/app/server.R"), parse("inst/app/ui.R") work
# commit & push
# restart R session
# remotes::install_github("anna-doizy/ipsimcirsium")
# publish the app

# nécessaire car comme l'application charge le package pour démarrer (récupère le jeu suivi), il a besoin d'être installé proprement dans le serveur distant. Pour l'instant RStudio (shinyapps) ne permet de faire cela qu'avec des packages classiques (CRAN) ou github, mais pas gitlab...




library(APPNAME)

lang <- "fr"

















