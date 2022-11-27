repo_arm <- function(root, type, r_version) {
  type <- rlang::arg_match0(type, PACKAGE_TYPES, error_call = rlang::caller_env())
  if (type != "source") {
    os <- switch(type, win.binary = "windows", mac.binary = "macosx")
    dir <- fs::path("bin", os, "contrib", numeric_version(r_version)[, 1:2])
  } else {
    dir <- fs::path("src", "contrib")
  }
  structure(fs::path(root, dir), type = type)
}

PACKAGE_TYPES <- c("source", "win.binary", "mac.binary")

repo_arm_path <- function(arm, ...) {
  fs::path(arm, ...)
}

repo_arm_type <- function(arm) {
  attr(arm, "type")
}

repo_arm_create <- function(arm) {
  dir <- repo_arm_path(arm)
  fs::dir_create(dir)
  package_index_create(dir)
  fs::path(dir)
}

repo_arm_insert <- function(arm, file) {
  dir <- repo_arm_path(arm)
  fs::dir_create(dir)
  fs::file_copy(file, dir, overwrite = TRUE) -> dst
  package_index_insert(dir, fs::path_file(dst))
  fs::path(dst)
}

repo_arm_contains <- function(arm, file) {
  dir <- repo_arm_path(arm)
  fs::path_file(file) %in% package_index_list(dir)
}

repo_arm_remove <- function(arm, package, version) {
  dir <- repo_arm_path(arm)
  files <- package_index_find(dir, package, version)
  package_index_remove(dir, files)
  fs::path(dir, files)
}

repo_arm_find <- function(arm, package, version) {
  dir <- repo_arm_path(arm)
  files <- package_index_find(dir, package, version)
  fs::path(dir, files)
}

repo_arm_update <- function(arm) {
  dir <- repo_arm_path(arm)
  package_index_update(dir, repo_arm_type(arm))
  invisible(NULL)
}
