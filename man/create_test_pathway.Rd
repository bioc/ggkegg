% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pathway_functions.R
\name{create_test_pathway}
\alias{create_test_pathway}
\title{create_test_pathway}
\usage{
create_test_pathway(line = FALSE)
}
\arguments{
\item{line}{return example containing graphics type line}
}
\value{
tbl_graph
}
\description{
As downloading from KEGG API is not desirable
in vignettes or examples, return the `tbl_graph`
with two nodes and two edges.
}
\examples{
create_test_pathway()
}
