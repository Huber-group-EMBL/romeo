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
#' @importFrom Rarr read_zarr_array read_zarr_attributes
#' @importFrom ZarrArray ZarrArray
#'
#' @returns An object of `ome_zarr` (OME-Zarr) class representing an
#'  image or label pyramid.
#'
#' @examples
#' omezarrzip <- system.file("extdata",
#'                           "test_ngff_image_v04.ome.zarr.zip",
#'                           package = "romeo")
#' dir.create(td <- tempfile())
#' unzip(omezarrzip, exdir = td)
#' x <- ome_read(td)
#'
#' @export
ome_read <- function(path, s3_client = NULL, lazy = TRUE, validate = TRUE) {
  # FIXME: check we're in a group
  type <- if (validate) {
    ome_validate(path, s3_client = s3_client)
  } else {
    "unknown"
  }

  group_attributes <- Rarr::read_zarr_attributes(path, s3_client = s3_client)
  ome_version <- .get_version(group_attributes)
  multiscales <- .get_multiscales(group_attributes, ome_version)
  datasets <- multiscales$datasets
  scales <- .get_scales(group_attributes, ome_version)
  dim_names <- .get_dim_names(group_attributes, ome_version)

  .read_zarr <- function(path, s3_client = NULL, lazy = TRUE) {
    if (lazy) {
      ZarrArray::ZarrArray(path, s3_client = s3_client)
    } else {
      Rarr::read_zarr_array(path, s3_client = s3_client)
    }
  }

  x <- lapply(datasets, function(scale) {
    img <- .read_zarr(
      file.path(path, scale$path),
      lazy = lazy,
      s3_client = s3_client
    )
    img
  })

  levels <- mapply(
    function(img, scale) {
      attr(img, "scale") <- scale
      img
    },
    x,
    lapply(datasets, function(x) {
      unlist(x$coordinateTransformations[[1]]$scale)
    }),
    SIMPLIFY = FALSE
  )
  
  levels <- S4Vectors:::new_SimpleList_from_list("ImageList", levels)
  S4Vectors::new2(
    "ome_zarr",
    levels = levels,
    axes = names(scales[[1]]),
    scales = scales,
    metadata = list(version = ome_version, 
                    type = type, 
                    dim_names = dim_names)
  )
}
