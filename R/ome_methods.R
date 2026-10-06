#' ome_zarr methods
#'
#' Methods for ome_zarr objects.
#'
#' @param x An `ome_zarr` object.
#' @param level Integer. The scale level to plot. Defaults to `1`
#' (the highest resolution).
#' @param ... Additional arguments passed to `plot()` or `print()`.
#'
#' @name omezarr-methods
#' @aliases
#' plot
#' plot,ome_zarr-method
#' print
#' negate,ome_zarr-method
#' dimnames,
#' dimnames,ome_zarr_method
#' metadata,
#' metadata,ome_zarr_method
#' version
#' version,ome_zarr-method
#'
#' @returns None
#'
#' @keywords internal
#'
#' @examples
#' omezarrzip <- system.file("extdata",
#'                           "test_ngff_image_v04.ome.zarr.zip",
#'                           package = "romeo")
#' dir.create(td <- tempfile())
#' unzip(omezarrzip, exdir = td)
#' x <- ome_read(td)
#'
#' # metadata
#' metadata(x)
#'
#' # dimnames
#' dimnames(x)
#'
#' # ngff version
#' version(x)
#'
#' # plot
#' plot(x)
#' plot(x, 2)
#' plot(x, all = TRUE)
#'
#' # print
#' print(x)
#' print(x, 2)
NULL

#' @describeIn omezarr-methods Plot an `ome_zarr` object
#' @export
setMethod("plot", "ome_zarr", function(x, level = 1, ...) {
  plot_dim <- c("x", "y")
  dimx <- dimnames(x)
  plot_dim <- c(plot_dim, setdiff(dimx, plot_dim))
  x <- x[[level]] |>
    aperm(match(dimnames(x), plot_dim))
  x <- x / max(x)
  x |>
    EBImage::Image(dim = dim(x)) |>
    plot(...)
})

#' @describeIn omezarr-methods Print an `ome_zarr` object
#' @importFrom utils head
#' @export
setMethod("print", "ome_zarr", function(x, level = 1, ...) {
  cat(
    "Multiscale OME-Zarr ",
    metadata(x)$type,
    " (v",
    version(x),
    ") object.\n",
    sep = ""
  )
  cat(sprintf("Scale: %d/%d", level, length(x)), "\n")
  print(head(x[[level]], rep_len(5, length(dim(x[[level]]))), ...))
})

#' @describeIn omezarr-methods get metadata of `ome_zarr` object
#' @importFrom S4Vectors metadata
#' @export
setMethod("metadata", "ome_zarr", function(x, ...) {
  x@metadata
})

#' @describeIn omezarr-methods get metadata of `ome_zarr` object
#' @export
setMethod("dimnames", "ome_zarr", function(x) {
  metadata(x)$dim_names
})


#' @describeIn omezarr-methods get ngff version of the `ome_zarr` object
#' @export
setMethod("version", "ome_zarr", function(x, ...) {
  metadata(x)$version
})
