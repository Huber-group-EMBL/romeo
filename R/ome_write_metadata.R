#' @noRd
.write_ome_metadata <- function(path, 
                               image,
                               scalefactors,
                               version = c("0.4", "0.5"),
                               axes = NULL, 
                               type = c("image", "label"), 
                               label_metadata = NULL) {

  # for now we only do version 0.4 due to Rarr only supporting v2
  # see https://ngff.openmicroscopy.org/0.4/index.html#multiscale-md
  
  meta <- list()
  ax <- "axes"
  ct <- "coordinateTransformations"
  ds <- "datasets"
  mt <- "metadata"
  v <- "version"
  n <- "name"

  # check version
  if(!version %in% c("0.4", "0.5"))
    stop("Writing support is only available for OME versions 0.4 and 0.5!")
  
  # version
  if(version == "0.4"){
    meta[[v]] <-  version 
  }
  
  # axis
  meta[[ax]] <- .make_axes_meta(axes)
  
  # coordinate transformations
  meta[[ct]] <- .make_empty_ct(axes)
  
  # datasets 
  meta[[ds]] <- .make_datasets(scalefactors, axes)
  
  # multiscales
  meta <- list(multiscales = list(meta)) 
  
  # image-label
  if(type == "label")
    meta <- append(meta,
                   .make_label_metadata(
                     label_metadata = label_metadata, 
                     version = version))
  
  # version meta
  if(version == "0.5"){
    meta <- list(
      ome = c(meta, 
              list(version = version))
    )
  }
  
  # update json list
  Rarr::write_zarr_attributes(zarr_path = path, 
                              new.zattrs = meta, 
                              overwrite = TRUE)
}

#' @noRd
.make_label_metadata <- function(label_metadata, version){
  
  # add image-label
  meta <- list(`image-label` = list(version = version))
  
  # check label metadata if provided
  if(!is.null(label_metadata)){
    
    # check names
    lm_names <- c("properties", "colors", "source")
    if(!all(names(label_metadata) %in% lm_names))
      stop("Label metadata should only include: ", 
           paste(lm_names, collapse = ", "))
    
    # check source
    if(!"source" %in% names(label_metadata))
      label_metadata <- append(label_metadata, 
                               list(source = "../../"))
    
    # check colors
    lapply(label_metadata["colors"], function(lm){
      .check_label_value(lm[[1]])
      if(!is.null(lmrgb <- lm[["rgba"]])){
        msg <- "rgba should be a list of four uint8 [0,255] entries"
        if(!is.list(lmrgb)) stop(msg)
        if(!is.rgba(unlist(lmrgb))) stop(msg)
      }
        
    })
    
    # check properties
    lapply(label_metadata["properties"], function(lm){
      .check_label_value(lm[[1]])
    })
  }
  
  append(meta, label_metadata)
}

.check_label_value <- function(lmv){
  if(!is.null(lmv <- lmv[["label-value"]])){
    lmv <- suppressWarnings(as.numeric(lmv))
    if(lmv %% 1 != 0)
      stop("label-value should be a non-zero integer")
  } else {
    stop("colors and properties in label metadata should include 'label-value'")
  }
}

#' @noRd
is.rgba <- function(x){
  all(
    vapply(x, \(.) {
      (. >= 0 & .<=255) & (. %% 1 == 0)
    }, logical(1))
  )
}

#' .get_valid_axes
#' 
#' Get validated axes
#'
#' @inheritParams ome_write
#' 
#' @noRd
.get_valid_axes <- function(
    image,
    axes = NULL, 
    version = "0.4"
) {
  
  # We can guess axes for images, labels if 2D (with/without channels)
  ndim <- length(dim(image))
  if (is.null(axes)) {
    if (ndim %in% c(2,3)) {
      axes <- c("x", "y", if(ndim==3) "c" else NULL)
    } else {
      stop("axes must be provided. Can't be guessed beyond 2D images ", 
           "with or without channels!", 
           call. = FALSE)
    } 
  } else {
    if (is.character(axes) && length(axes) == 1L)
      axes <- strsplit(axes, "", fixed = TRUE)[[1]]
    if (length(axes) != ndim) {
      stop(
        sprintf("axes length (%d) must match number of dimensions (%d)", 
                length(axes), ndim),
        call. = FALSE
      )
    }
  }
  
  # axes length should match # of dim
  if (!is.null(ndim) && length(axes) != ndim) {
    stop(
      sprintf("axes length (%d) must match number of dimensions (%d)", 
              length(axes), ndim),
      call. = FALSE
    )
  }
  
  # invalid axes
  diff_axes <- setdiff(axes, .DEFAULT_AXES)
  if(length(diff_axes))
    stop("Some axes are invalid: ", paste(diff_axes, collapse = ","))
  
  # duplicated axes
  ind_dup <- which(table(axes) > 1)
  if(length(ind_dup))
    stop("Duplicated axes are detected: ", 
         paste(names(ind_dup), collapse = ","))
  
  axes
}

#' @noRd
.make_axes_meta <- function(axes){
  lapply(axes, 
         \(.) {
           if(. == "t") list(name = ., type = "time", unit = "millisecond")
           else if(. == "c") list(name = ., type = "channel")
           else list(name = ., type = "space")
         })
}

#' @noRd
.make_datasets <- function(scalefactors, axes){
  paths <- as.character(seq(0, length(scalefactors)))
  scalefactors <- c(1,cumprod(scalefactors))
  mapply(\(p, s) {
    list(
      coordinateTransformations = list(
        list(
          scale = vapply(axes, \(.){
            if(. %in% c("c", "t")) 1 else as.numeric(s)
          }, numeric(1)),
          type = "scale" 
        )
      ), 
      path = p
    )
  }, paths, scalefactors, USE.NAMES = FALSE, SIMPLIFY = FALSE)
}

#' @noRd
.make_empty_ct <- function(axes){
  list(
    list(
      scale = vapply(axes, \(.){
        if(. == "c"){
          1
        } else if(. =="t") {
          0.1 
        } else 1
      }, numeric(1)),
      type = "scale" 
    )
  )
}

.check_scalefactors <- function(sf){
  msg <- "scale factors should be non-NA values higher than 1."
  if(anyNA(sf))
    stop(msg)
  if(length(sf) < 1)
    stop(msg)
  if(any(!is.numeric(sf)))
    stop(msg)
  if(any(sf < 1))
    stop(msg)
}
