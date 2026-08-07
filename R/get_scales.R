#' @keywords internal
.get_multiscales <- function(metadata, ome_version) {
  scales <- switch(
    ome_version,
    "0.3" = ,
    "0.4" = metadata$multiscales,
    "0.5" = ,
    "0.5-dev-spatialdata" = metadata$ome$multiscales,
    stop("Unsupported OME version: ", ome_version)
  )
  scales[[1]]
}

#' @keywords internal
.get_scales <- function(metadata, ome_version) {
  multiscales <- .get_multiscales(metadata, ome_version)
  axes <- vapply(multiscales$axes, \(.) .$name, character(1))
  scales <- lapply(multiscales$datasets, 
                   \(.){
                     setNames(
                       unlist(.$coordinateTransformations[[1]]$scale), axes
                     )
                   })
  scales
}