#' Extract specific levels from a multiscale `ome-zarr` object
#'
#' @param x An `ome-zarr` object.
#' @param levels Integer vector specifying the levels to extract.
#'
#' @returns
#' - If `levels` is of length 1, an array
#' - If `levels` is of length more than 1, an `ome-zarr` object
#'
#' @export
#'
#' @examples
#' \dontrun{
#' x <- ome_read(
#'   "https://uk1s3.embassy.ebi.ac.uk/idr/zarr/v0.4/idr0076A/10501752.zarr"
#' )
#' extract_levels(x, c(1, 3))
#' extract_levels(x, 2)
#' }
extract_levels <- function(x, levels) {
  stopifnot(
    inherits(x, "ome_zarr")
  )
  if (any(levels < 1) || any(levels > length(x))) {
    stop("Level must be between 1 and ", length(x))
  }
  x <- lapply(levels, function(level) x[[level]])

  if (length(x) == 1) {
    return(x[[1]])
  }

  class(x) <- "ome_zarr"
  x
}
