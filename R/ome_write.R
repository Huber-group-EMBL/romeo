
#' ome_write
#' 
#' Writes an ome image to the zarr path according to ome-zarr specification
#'
#' @param image an n-dimensional (1<n<6) array representing the image data 
#' @param path the zarr path to write the image to
#' @param axes a character vector specifying the axes of the image 
#' (e.g. c("t", "c", "z", "y", "x"))
#' @param scalefactors Scale factors to apply to construct a multiscale image. 
#' Importantly, each scale factor is relative to the previous scale factor. 
#' For example, if the scale factors are c(2, 2, 2), the returned multiscale 
#' image will have 4 scales.
#' @param version OME-ZARR format (0.4 or 0.5), lower versions are not supported
#' for writing.
#' @param storage_options a list of storage options for the zarr array 
#' (e.g. chunks)
#'
#' @rdname ome_write
#' 
#' @importFrom stats setNames
#' 
#' @export
ome_write <- function(image, 
                      path="/", 
                      axes = NULL,  
                      scalefactors = c(2,2,2,2),
                      version = c("0.4", "0.5"),
                      storage_options = NULL){
  
  # Generate a downsampled pyramid of images.
  image_pyramid <- .create_mip(image, version, scalefactors, axes)
  
  # write image
  .write_multiscale_image(image_pyramid = image_pyramid, 
                          path = path, 
                          axes = axes, 
                          format = version, 
                          storage_options = storage_options)
  
  # write ome metadata 
  .write_ome_metadata(path = path, 
                     image = image,
                     scalefactors = scalefactors,
                     version = version, 
                     axes = axes)
  
  # return
  ome_read(path = path)
}

#' .create_mip
#' 
#' Generate a downsampled pyramid of images.
#'
#' @importFrom EBImage resize
#' 
#' @inheritParams ome_write
#' 
#' @noRd
.create_mip <- function(image,
                        format,
                        scalefactors,
                        axes = NULL){
  
  # check dim
  ndim <- length(dim(image))
  if (ndim > 5) {
    stop("Only images of 5D or less are supported")
  }
  
  # check format
  # v0.1 and v0.2 are strictly 5D
  if (format %in% c("0.1", "0.2")) {
    shape_5d <- c(rep(1, 5 - ndim), dim(image))
    dim(image) <- shape_5d
  }
  
  # validate axes
  axes <- .get_valid_axes(x = image, 
                          axes = axes, 
                          format = format)
  
  # get x y dimensions for EBImage
  dim_image <- stats::setNames(dim(image), axes)
  dim_image <- dim_image[c("x", "y")]
  
  # downscale image
  image_list <- list(image)
  cur_image <- aperm(image, 
                     perm = rev(seq_along(axes)))
  for (i in seq_along(scalefactors)) {
    dim_image <- ceiling(dim_image / scalefactors[i])
    img <- aperm(EBImage::resize(cur_image,
                                 w = dim_image[1],
                                 h = dim_image[2]), 
                 perm = rev(seq_along(axes)))
    dimnames(img) <- axes
    image_list[[i+1]] <- img
  }
  
  image_list
}

#' .write_multiscale_image
#' 
#' Write a pyramid with multiscale metadata to disk.
#'
#' @inheritParams ome_write
#' 
#' @noRd
.write_multiscale_image <- function(image_pyramid,
                                    path,
                                    axes,
                                    format,
                                    storage_options){
  
  # version
  zarr_version <- if(format == "0.4") 2 else "3"
  
  # create zarr
  if(!zarr_path_exists(path, target_path = "/"))
    create_zarr(store = path, version = zarr_version)
  
  # check storage options
  if(!"chunk_dim" %in% names(storage_options))
    stop("'chunk_dim' must be provided in storage_options")
  
  # write multiscale image
  # TODO: how can we do this optimal for each scale/layer
  for(i in seq_len(length(image_pyramid))){
    image <- image_pyramid[[i]]
    Rarr::write_zarr_array(
      x = image_pyramid[[i]],
      zarr_array_path = paste(path, paste0(i-1), sep = "/"),
      chunk_dim = .get_scale_chunk_dim(
        chunk_dim = storage_options$chunk_dim,
        dim = dim(image)
      ), zarr_version = zarr_version
    )
  }
}

.get_scale_chunk_dim <- function(chunk_dim, dim){
  mapply(function(x, y) min(x, y), dim, chunk_dim)
}
