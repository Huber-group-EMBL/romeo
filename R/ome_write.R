
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
#' @param version OME-ZARR version (0.4 or 0.5), lower versions are not supported
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
  
  # validate axes
  axes <- .get_valid_axes(image = image, 
                          axes = axes, 
                          version = version)
  
  # Generate a downsampled pyramid of images.
  image_pyramid <- .create_mip(image, version, scalefactors, axes)
  
  # write image
  .write_multiscale_image(image_pyramid = image_pyramid, 
                          path = path, 
                          axes = axes, 
                          version = version, 
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
#' @importFrom EBImage resize imageData
#' 
#' @inheritParams ome_write
#' 
#' @noRd
.create_mip <- function(image,
                        version,
                        scalefactors,
                        axes = NULL){
  
  # get x y dimensions for EBImage
  dim_image <- dim(image)
  
  # downscale image
  image_list <- list(image)
  for (i in seq_along(scalefactors)) {
    dim_image <- ceiling(dim_image / scalefactors[i])
    img <- EBImage::resize(image,
                           w = dim_image[1],
                           h = dim_image[2])
    image_list[[i+1]] <- EBImage::imageData(img)
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
                                    version,
                                    storage_options){
  
  # version
  zarr_version <- if(version == "0.4") 2 else "3"
  
  # create zarr
  if(!zarr_exists(path))
    create_zarr(store = path, version = zarr_version)
  
  # check storage options
  if(!"chunk_dim" %in% names(storage_options))
    stop("'chunk_dim' must be provided in storage_options")
  
  # write multiscale image
  # TODO: how can we do this optimal for each scale/layer
  for(i in seq_len(length(image_pyramid))){
    image <- image_pyramid[[i]]
    if(version == "0.5")
      dimnames(image) <- setNames(
        vector("list", length(axes)),
        axes
      )
    Rarr::write_zarr_array(
      x = image,
      zarr_array_path = paste(path, paste0(i-1), sep = "/"),
      chunk_dim = .get_scale_chunk_dim(
        chunk_dim = storage_options$chunk_dim,
        dim = dim(image)
      ), zarr_version = zarr_version
    )
  }
}

.get_scale_chunk_dim <- function(chunk_dim, dim){
  if(length(chunk_dim) != length(dim))
    stop("chunk and array dimensions do not match!")
  mapply(function(x, y) min(x, y), dim, chunk_dim)
}
