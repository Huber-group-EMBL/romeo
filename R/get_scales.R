#' @keywords internal
.get_scales <- function(metadata, ome_version) {
  scales <- switch(
    ome_version,
    "0.3" = ,
    "0.4" = metadata$multiscales,
    "0.5" = metadata$ome$multiscales,
    stop("Unsupported OME version: ", ome_version)
  )
  return(scales[[1]])
}
