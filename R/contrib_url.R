contrib_url <- function(repo, type, r_version = getRversion()) {
  type <- rlang::arg_match0(type, PACKAGE_TYPES, "type", rlang::caller_env())
  minor_r_version <- numeric_version(r_version)[, 1:2]
  dir <- switch(type,
    source = fs::path("src", "contrib"),
    win.binary = fs::path("bin", "windows", "contrib", minor_r_version),
    mac.binary = fs::path("bin", "macosx", "contrib", minor_r_version)
  )
  structure(fs::path(repo, dir), type = type)
}

PACKAGE_TYPES <- c("source", "win.binary", "mac.binary")

contrib_url_create <- function(dir) {
  fs::dir_create(dir)
  package_index_create(dir)
  fs::path(dir)
}

contrib_url_insert <- function(dir, file) {
  fs::dir_create(dir)
  fs::file_copy(file, dir, overwrite = TRUE) -> dst
  package_index_insert(dir, fs::path_file(dst))
  fs::path(dst)
}

contrib_url_contains <- function(dir, file) {
  fs::path_file(file) %in% package_index_list(dir)
}

contrib_url_remove <- function(dir, package, version) {
  files <- package_index_find(dir, package, version)
  package_index_remove(dir, files)
  fs::path(dir, files)
}

contrib_url_find <- function(dir, package, version) {
  files <- package_index_find(dir, package, version)
  fs::path(dir, files)
}

contrib_url_update <- function(dir) {
  package_index_update(dir, attr(dir, "type"))
  invisible(NULL)
}
