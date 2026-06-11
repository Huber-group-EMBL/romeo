#' @name ome_write
#' @title ome_write
#'
#' @description
#' Writes an ome image to the zarr path according to ome-zarr specification
#'
#' @param image an n-dimensional (or a path to an) array representing the
#' image data (1<n<6)
#' @param path the path to writing ome.zarr
#' @param axes a character vector specifying the axes of the image
#' (e.g. c("t", "c", "z", "y", "x"))
#' @param scalefactors Scale factors to apply to construct a multiscale image.
#' Importantly, each scale factor is relative to the previous scale factor.
#' For example, if the scale factors are c(2, 2, 2), the returned multiscale
#' image will have 4 scales.
#' @param version OME-ZARR version (0.4 or 0.5), lower versions are not
#' supported for writing.
#' @param storage_options a list of storage options for the zarr array
#' (e.g. chunks)
#' @param type The type of OME pyramid written: 'image' (default) or 'label'.
#' @param label_name The name of the label data.
#' @param label_metadata label metadata added to attributes.
#'
#' @returns An object of `ome_zarr` (OME-Zarr) class representing an
#'  image or label pyramid.
#'
#' @examples
#' library(EBImage)
#' nuc <- readImage(system.file("images", "nuclei.tif", package="EBImage"))
#' nuc <- getFrames(nuc)[[1]]
#' td <- tempfile(fileext = ".ome.zarr")
#'
#' # write image pyramid
#' ome_nuc <- ome_write(nuc,
#'                      path = td,
#'                      version = "0.4",
#'                      storage_options = list(chunk_dim = c(64,64)))
#'
#' # nuclei segmentation using otsu's method
#' nuc_th = nuc > otsu(nuc)
#'
#' # write label pyramid
#' ome_nuc_th <- ome_write(nuc_th,
#'                         path = td,
#'                         version = "0.4",
#'                         scalefactors = c(2,2,3),
#'                         storage_options = list(chunk_dim = c(64,64)),
#'                         label_name = "nuclei_segmentation",
#'                         type = "label")
#'
#' @export
setGeneric(
  "ome_write",
  \(
    image,
    path = "/",
    axes = NULL,
    scalefactors = c(2, 2, 2, 2),
    version = c("0.4", "0.5"),
    storage_options = NULL,
    type = c("image", "label"),
    label_name = NULL,
    label_metadata = NULL
  ) {
    standardGeneric("ome_write")
  }
)

#' @rdname ome_write
#' @importFrom EBImage Image
#' @export
setMethod(
  "ome_write",
  "array",
  function(
    image,
    path,
    axes,
    scalefactors,
    version,
    storage_options,
    type,
    label_name,
    label_metadata
  ) {
    image <- Image(image)
    .ome_write(
      image,
      path,
      axes,
      scalefactors,
      version,
      storage_options,
      type,
      label_name,
      label_metadata
    )
  }
)

#' @rdname ome_write
#' @importFrom EBImage Image
#' @export
setMethod(
  "ome_write",
  "Image",
  function(
    image,
    path,
    axes,
    scalefactors,
    version,
    storage_options,
    type,
    label_name,
    label_metadata
  ) {
    .ome_write(
      image,
      path,
      axes,
      scalefactors,
      version,
      storage_options,
      type,
      label_name,
      label_metadata
    )
  }
)

.ome_write <- function(
  image,
  path = "/",
  axes = NULL,
  scalefactors = c(2, 2, 2, 2),
  version = c("0.4", "0.5"),
  storage_options = NULL,
  type = c("image", "label"),
  label_name = NULL,
  label_metadata = NULL
) {
  # version and type
  version <- match.arg(version)
  type <- match.arg(type)

  # validate axes
  axes <- .get_valid_axes(image = image, axes = axes, version = version)

  # scale factors
  .check_scalefactors(scalefactors)

  # Generate a downsampled pyramid of images.
  pyramid <- .create_mip(image, version, scalefactors, axes, type)

  # update path if writing labels
  path <- switch(
    type,
    "label" = {
      # first check if an image is written,
      # otherwise return path and write a regular label pyramid
      res <- tryCatch(
        {
          ome_validate(path)
        },
        error = function(e) {
          path
        }
      )

      if (res == "image") {
        .write_label_group(path, label_name, version)
      } else {
        res
      }
    },
    "image" = path,
    stop("Type should be either 'image' or 'label'")
  )

  # write image
  .write_multiscale(
    pyramid = pyramid,
    path = path,
    axes = axes,
    version = version,
    storage_options = storage_options,
    type = type
  )

  # write ome metadata
  .write_ome_metadata(
    path = path,
    image = image,
    scalefactors = scalefactors,
    version = version,
    axes = axes,
    type = type,
    label_metadata = label_metadata
  )

  # return
  ome_read(path = path)
}

.write_label_group <- function(path, name = NULL, version) {
  # check name
  if (!is_label_name(name)) {
    stop("label_name has to be a string!")
  }

  # message
  message(
    sprintf(
      "An image pyramid was found at '%s', writing labels to '%s'",
      path,
      file.path("labels", name)
    )
  )

  # create zarr group of labels/<name>
  create_zarr(path, version = if (version == "0.4") 2L else 3L)
  create_zarr_group(path, file.path("labels", name))

  # add labels group metadata
  .write_label_group_metadata(path, name, version = version)

  # update path
  file.path(path, "labels", name)
}

#' .create_mip
#'
#' Generate a downsampled pyramid of images.
#'
#' @importFrom EBImage resize imageData
#'
#' @inheritParams ome_write
#'
#' @noRd
.create_mip <- function(
  image,
  version,
  scalefactors,
  axes = NULL,
  type = "image"
) {
  # get x y dimensions for EBImage
  dim_image <- dim(image)

  # downscale image
  image_list <- list(image)
  for (i in seq_along(scalefactors)) {
    dim_image <- ceiling(dim_image / scalefactors[i])
    img <- EBImage::resize(
      image,
      w = dim_image[1],
      h = dim_image[2],
      filter = switch(type, image = "bilinear", label = "none")
    )
    image_list[[i + 1]] <- EBImage::imageData(img)
  }

  image_list
}

#' .write_multiscale
#'
#' Write a pyramid with multiscale metadata to disk.
#'
#' @inheritParams ome_write
#'
#' @noRd
.write_multiscale <- function(
  pyramid,
  path,
  axes,
  version,
  storage_options,
  type
) {
  # zarr version
  zarr_version <- if (version == "0.4") 2L else 3L

  # create zarr
  if (!zarr_exists(path)) {
    create_zarr(store = path, version = zarr_version)
  }

  # check storage options
  if (!"chunk_dim" %in% names(storage_options)) {
    stop("'chunk_dim' must be provided in storage_options")
  }

  # write multiscale image
  # TODO: how can we do this optimal for each scale/layer
  for (i in seq_along(pyramid)) {
    image <- pyramid[[i]]
    if (version == "0.5") {
      dimnames(image) <- setNames(
        vector("list", length(axes)),
        axes
      )
    }
    Rarr::write_zarr_array(
      x = image,
      zarr_array_path = file.path(path, i - 1),
      chunk_dim = .get_scale_chunk_dim(
        chunk_dim = storage_options$chunk_dim,
        dim = dim(image)
      ),
      zarr_version = zarr_version
    )
  }
}

.get_scale_chunk_dim <- function(chunk_dim, dim) {
  if (length(chunk_dim) != length(dim)) {
    stop("chunk and array dimensions do not match!")
  }
  pmin(chunk_dim, dim)
}
