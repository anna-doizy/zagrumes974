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

#' Presence of the disease per plot for the barplot
#' 
#' Several HLB samplings on the same plot may be possible, but if only one is positive, the whole plot is considered positive.
#'
#' @format data.frame 334x7
#' \describe{
#'   \item{Id}{Plot identifier}
#'   \item{X, Y}{WGS84 coordinates of the plot barycentre}
#'   \item{Surface}{Area of the plot in hectares}
#'   \item{Maladie}{Presence (Malade) or absence (Sain) of the disease}
#'   \item{Date}{Date of the observation}
#'   \item{COMMUNE}{Municipality of the observation}
#' }
"prelev"

#' Dataframe with the total citrus plot area per commune
#'
#' @format data.frame 25x2
#' \describe{
#'   \item{Surface_tot}{Citrus plot area in square meters}
#'   \item{COMMUNE}{Municipality name}
#' }
"surface_agrume"

#' Polygon simple feature collection containing the shapes of the municipalities of Reunion island
#'
#' @format sf with 24 municipalities and 1 field
#' \describe{
#'   \item{COMMUNE}{Municipality name}
#' }
#' 
#' @import sf
"communes"

#' Barycentres of the known citrus plots in Reunion
#'
#' @format data.frame 782x3
#' \describe{
#'   \item{ID}{Plot identifier}
#'   \item{longitude, latitude}{WGS84 coordinates of the plot barycentre}
#' }
"par"

#' Data with positive HLB samplings for the interpolation
#' 
#' The sampling may have occured in a plot of not.
#'
#' @format data.frame 616x4
#' \describe{
#'   \item{id}{Plot identifier}
#'   \item{longitude, latitude}{WGS84 coordinates of the plot barycentre}
#'   \item{date}{Date of the observation}
#' }
"hlu"
