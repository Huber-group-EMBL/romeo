#' Plot an `ome_zarr` object.
#'
#' @param x An `ome_zarr` object.
#' @param level Integer. The scale level to plot. Defaults to `1`
#' (the highest resolution).
#' @param ... Additional arguments passed to `plot()`.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' x <- ome_read(
#'   "https://uk1s3.embassy.ebi.ac.uk/idr/zarr/v0.4/idr0076A/10501752.zarr"
#' )
#' plot(x)
#' }
#'
plot.ome_zarr <- function(x, level = 1, ...) {
  x <- x[[level]] |>
    aperm(c(seq(2, length(dim(x[[level]]))), 1))
  x |>
    EBImage::Image(dim = dim(x)) |>
    plot(...)
}
