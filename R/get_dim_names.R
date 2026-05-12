#' @keywords internal
.get_dim_names <- function(metadata, ome_version) {
  dim_names <- switch(
    ome_version,
    "0.3" = metadata$multiscales[[1]]$axes,
    "0.4" = metadata$multiscales[[1]]$axes |>
      vapply(function(axis) axis$name, character(1)),
    "0.5" = metadata$ome$multiscales[[1]]$axes |>
      vapply(function(axis) axis$name, character(1)),
    stop("Unsupported OME version: ", ome_version)
  )
  return(dim_names)
}
