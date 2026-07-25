.set_zarr_format <- function(ome_version) {
  if (ome_version %in% c("0.5", "0.6")) {
    return(3L)
  }
  if (ome_version == "0.4") {
    return(2L)
  }
  stop(
    "Invalid OME-Zarr version. Only '0.4', '0.5', and '0.6' are supported.",
    call. = FALSE
  )
}
