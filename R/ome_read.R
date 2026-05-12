#' Read a multiscale OME-Zarr file
#'
#' @param path Path to the OME-Zarr file.
#' @inheritParams Rarr::read_zarr_array
#' @param lazy Logical. If `TRUE` (the default), use \pkg{ZarrArray}
#'   to read data lazily. If `FALSE`, read data into memory using
#'   \pkg{Rarr}. If the data can fit into memory, setting `lazy = FALSE`
#'   may result in better performance.
#' @param validate Logical.If `TRUE` (the default), validate the OME-Zarr file.
#'
#' @importFrom stats setNames
#' @export
#'
#' @examples
#' \dontrun{
#' x <- ome_read(
#'   "https://uk1s3.embassy.ebi.ac.uk/idr/zarr/v0.4/idr0076A/10501752.zarr"
#' )
#' }
ome_read <- function(path, s3_client = NULL, lazy = TRUE, validate = TRUE) {
  # FIXME: check we're in a group
  type <- if (validate) {
    ome_validate(path, s3_client = s3_client)
  } else {
    "Unknown"
  }

  group_attributes <- Rarr::read_zarr_attributes(path, s3_client = s3_client)
  ome_version <- .get_version(group_attributes)
  scales <- .get_scales(group_attributes, ome_version)
  dim_names <- .get_dim_names(group_attributes, ome_version)

  .read_zarr <- function(path, s3_client = NULL, lazy = TRUE) {
    if (lazy) {
      ZarrArray::ZarrArray(path, s3_client = s3_client)
    } else {
      Rarr::read_zarr_array(path, s3_client = s3_client)
    }
  }

  x <- lapply(scales$datasets, function(scale) {
    img <- .read_zarr(file.path(path, scale$path), 
                      lazy = TRUE, 
                      s3_client = s3_client)
    if (!is.null(dim_names)) {
      dimnames(img) <- setNames(
        vector("list", length = length(dim(img))),
        dim_names
      )
    }
    return(img)
  })

  x <- mapply(
    function(img, scale) {
      attr(img, "scale") <- scale
      return(img)
    },
    x,
    lapply(scales$datasets, function(x) {
      unlist(x$coordinateTransformations[[1]]$scale)
    }),
    SIMPLIFY = FALSE
  )
  class(x) <- "ome_zarr"
  attr(x, "type") <- type
  attr(x, "version") <- ome_version

  return(x)
}
