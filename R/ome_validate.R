#' Validate a multiscale OME-Zarr file
#'
#' @inheritParams ome_read
#'
#' @returns
#' This function is used for its side-effect and will return the type of the 
#' OME-Zarr schema (image, label), otherwise will invoke an error when
#' passed an invalid OME-Zarr file
#'
#' @export
#'
#' @examples
#' \dontrun{
#' ome_validate(
#'   "https://uk1s3.embassy.ebi.ac.uk/idr/zarr/v0.4/idr0076A/10501752.zarr"
#' )
#' }
ome_validate <- function(path, s3_client = NULL) {
  group_attributes <- Rarr::read_zarr_attributes(path, s3_client = s3_client)
  ome_version <- .get_version(group_attributes)

  # We cannot download the schemas on the fly because we patch them to use local references
  # as jsonvalidate doesn't support remote references
  # (https://github.com/ropensci/jsonvalidate/issues/70)
  
  type <- 
    if(
    "image-label" %in% 
    names(
      if(is.null(ome <- group_attributes$ome)) group_attributes else ome 
    )
  ){
    "label"
    } else {
    "image"
  }
  
  # validate multiscale image/label
  schema <- system.file(
    "extdata",
    "schemas",
    ome_version,
    paste0(type, ".schema"),
    package = "rome"
  )
  jsonvalidate::json_validate(
    jsonlite::toJSON(group_attributes, auto_unbox = TRUE),
    schema,
    engine = "ajv",
    error = TRUE
  )
  
  type
}
