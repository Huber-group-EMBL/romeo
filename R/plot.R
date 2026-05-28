#' Plot an `ome_zarr` object.
#'
#' @param x An `ome_zarr` object.
#' @param level Integer. The scale level to plot. Defaults to `1`
#' (the highest resolution).
#' @param ... Additional arguments passed to `plot()`.
#'
#' @returns None
#'
#' @examples
#' omezarrzip <- system.file("extdata",
#'                           "test_ngff_image_v04.ome.zarr.zip",
#'                           package = "romeo")
#' dir.create(td <- tempfile())
#' unzip(omezarrzip, exdir = td)
#' x <- ome_read(td)
#' plot(x)
#' plot(x, 2)
#' plot(x, all = TRUE)
#'
#' @export
plot.ome_zarr <- function(x, level = 1, ...) {
  plot_dim <- c("x", "y")
  dimx <- dimnames(x)
  plot_dim <- c(plot_dim, setdiff(dimx, plot_dim))
  x <- x[[level]] |>
    aperm(match(dimnames(x), plot_dim))
  x <- x / max(x)
  x |>
    EBImage::Image(dim = dim(x)) |>
    plot(...)
}
