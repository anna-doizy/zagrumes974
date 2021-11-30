#' Translation of tabs
#'
#' @format data.frame with 4 columns and as many lines as tabs
#' \describe{
#'   \item{id}{shinydashboard::menuItem() tab name}
#'   \item{icon}{FontAwesome icon name}
#'   \item{fr}{tab text in French}
#'   \item{en}{tab text in English}
#' }
"onglets"

#' Translation of the rest of the user interface
#'
#' @format data.frame with 3 columns and as many lines as texts to translate
#' \describe{
#'   \item{id}{unique text identifier}
#'   \item{fr}{text in French}
#'   \item{en}{text in English}
#' }
"textesUI"

#' Raw data of the presence of the disease
#'
#' @format data.frame 267x7
#' \describe{
#'   \item{Id}{Plot identifier}
#'   \item{X, Y}{WGS84 coordinates of the plot barycentre}
#'   \item{Surface}{Area of the plot}
#'   \item{Altitude}{Elevation of the plot}
#'   \item{Maladie}{Presence (1) or absence (0) of the disease}
#'   \item{Date}{Date of the observation}
#' }
"prelev"


#' polygon simple feature collection containing the municipalities of Reunion island
#'
#' @format sf with 24 municipalities and 1 field
#' \describe{
#'   \item{COMMUNE}{Municipality name}
#' }
"communes"

