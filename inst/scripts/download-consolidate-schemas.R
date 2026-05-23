download_consolidate_schemas <- function(ome_version, type, path) {
  # Download root schema
  schema_file <- paste0(type, ".schema")
  url <- sprintf(
    paste0(
      "https://ngff.openmicroscopy.org/%s/schemas/",
      schema_file
    ),
    ome_version
  )
  dest <- file.path(path, ome_version, schema_file)
  if (!dir.exists(dirname(dest))) {
    dir.create(dirname(dest), recursive = TRUE)
  }
  download.file(url, dest)

  # Fetch references and transform them to local references as jsonvalidate
  # doesn't support remote references (https://github.com/ropensci/jsonvalidate/issues/70)
  schema <- jsonlite::read_json(dest)
  purrr::modify_tree(
    schema,
    leaf = function(x) {
      if (
        is.character(x) &&
          grepl("^https://ngff.openmicroscopy.org/.+/schemas/.+\\.schema$", x)
      ) {
        download.file(x, file.path(path, ome_version, basename(x)))
        basename(x)
      } else {
        x
      }
    }
  ) |>
    jsonlite::write_json(dest, auto_unbox = TRUE, pretty = TRUE)
}

# schema configs
config <- list(
  c(version = "0.4", type = "image"),
  c(version = "0.4", type = "label"),
  c(version = "0.5", type = "image"),
  c(version = "0.5", type = "label")
)

invisible(
  lapply(config, function(cg) {
    download_consolidate_schemas(
      ome_version = cg["version"],
      type = cg["type"],
      "inst/extdata/schemas"
    )
  })
)
