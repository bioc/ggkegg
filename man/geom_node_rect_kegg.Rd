% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_functions.R
\name{geom_node_rect_kegg}
\alias{geom_node_rect_kegg}
\title{geom_node_rect_kegg}
\usage{
geom_node_rect_kegg(type = NULL, rect_fill = "grey")
}
\arguments{
\item{type}{type to be plotted (gene, map, compound ...)}

\item{rect_fill}{rectangular fill}
}
\value{
ggplot2 object
}
\description{
Wrapper function for plotting a certain type of nodes
with background color with geom_node_rect()
}
\examples{
test_pathway <- create_test_pathway()
plt <- ggraph(test_pathway, layout="manual", x=x, y=y) +
 geom_node_rect_kegg(type="gene")
}
