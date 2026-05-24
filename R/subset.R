#' Subset an `ome-zarr` object
#'
#' Subset operation is applied on all levels of the multiscale `ome-zarr`
#' object. The result is an `ome-zarr` object with the same number of levels,
#' but each level is subsetted according to the provided indices.
#'
#' The first image is subsetted using the provided indices, and the
#' resulting dimensions are used to subset the remaining levels, while
#' conserving the same scaling factor across levels
#'
#' @param x An `ome-zarr` object.
#' @param ... Indices to subset the `ome-zarr` object.
#'
#' @returns A subset of an object of `ome_zarr` (OME-Zarr) class representing
#'  an image or label pyramid.
#'
#' @examples
#' omezarrzip <- system.file("extdata",
#'                           "test_ngff_image_v04.ome.zarr.zip",
#'                           package = "rome")
#' dir.create(td <- tempfile())
#' unzip(omezarrzip, exdir = td)
#' x <- ome_read(td)
#' y <- x[1:2, 1:5,1:5]
#' plot(y, level = 2)
#'
#' @export
`[.ome_zarr` <- function(x, ...) {
  x <- lapply(x, function(layer) {
    scale <- attr(layer, "scale")
    indices <- list(...)
    indices <- mapply(
      function(idx, scaling_factor) {
        if (is.null(idx)) {
          return(NULL)
        }
        # FIXME: is this the most sensible way to round here?
        scaled_idx <- unique(ceiling((idx / scaling_factor)))
        scaled_idx
      },
      indices,
      scale,
      SIMPLIFY = FALSE
    )
    do.call(`[`, c(list(layer), indices))
  })
  class(x) <- "ome_zarr"
  x
}
