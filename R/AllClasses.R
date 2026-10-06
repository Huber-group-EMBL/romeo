#' @importClassesFrom ImageArray ImageArray
setClass(
  Class = "ome_zarr",
  contains = "ImageArray",
  slots = c(
    metadata = "list"
  )
)
