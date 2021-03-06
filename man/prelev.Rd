% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{prelev}
\alias{prelev}
\title{Presence of the disease per plot for the barplot}
\format{
data.frame 334x7
\describe{
\item{Id}{Plot identifier}
\item{X, Y}{WGS84 coordinates of the plot barycentre}
\item{Surface}{Area of the plot in hectares}
\item{Maladie}{Presence (Malade) or absence (Sain) of the disease}
\item{Date}{Date of the observation}
\item{COMMUNE}{Municipality of the observation}
}
}
\usage{
prelev
}
\description{
Several HLB samplings on the same plot may be possible, but if only one is positive, the whole plot is considered positive.
}
\keyword{datasets}
