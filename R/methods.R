#' @importFrom utils head
#' @export
print.ome_zarr <- function(x, level = 1, ...) {
  cat(
    "Multiscale OME-Zarr ",
    x@metadata$type,
    " (v",
    x@metadata$version,
    ") object.\n",
    sep = ""
  )
  cat(sprintf("Scale: %d/%d", level, length(x)), "\n")
  print(head(x[[level]], rep_len(5, length(dim(x[[level]]))), ...))
  invisible(x)
}

#' @importFrom methods show
#' @export
setMethod("show", "ome_zarr", function(object) {
  print.ome_zarr(object, level = 1)
})
