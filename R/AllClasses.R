#' @importFrom S4Vectors SimpleList
setClass(
  Class = "ome_zarr",
  contains = "SimpleList",
  prototype = prototype(elementType = "array")
)

#' @importFrom utils head
#' @export
setMethod("print", "ome_zarr", function(x, level = 1, ...) {
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
})
