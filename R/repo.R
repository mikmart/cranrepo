#' Create a CRAN-like package repository
#'
#' @param dir Path to the directory to use as the repository root. Will be
#'   created if it does not exist.
#' @param r_version The version of R to create binary distributions for.
#'
#' @return The path to the repository root directory, invisibly.
#' @export
repo_create <- function(dir = ".", r_version = getRversion()) {
  for (type in PACKAGE_TYPES) {
    package_index_create(repo_packages_path(dir, type, r_version))
  }
  invisible(fs::path(dir))
}

repo_packages_path <- function(dir, type, r_version = getRversion()) {
  type <- rlang::arg_match0(type, PACKAGE_TYPES)
  if (type != "source") {
    os <- switch(type, win.binary = "windows", mac.binary = "macosx")
    fs::path(dir, "bin", os, "contrib", numeric_version(r_version)[, 1:2])
  } else {
    fs::path(dir, "src", "contrib")
  }
}

PACKAGE_TYPES <- c("source", "win.binary", "mac.binary")

#' Insert a package into a repository
#'
#' @param repo Path to the root directory of the package repository.
#' @param file Path to the source or binary package bundle to be added.
#' @param type The type of package to be added. Will be inferred from the file
#'   name if left `NULL`.
#' @param r_version When inserting a binary package, the version of R that the
#'   package was built for.
#'
#' @return The path to the inserted package file, invisibly.
#' @export
repo_insert <- function(repo, file, type = NULL, r_version = getRversion()) {
  if (is.null(type)) {
    type <- infer_package_type(file)
  }

  dir <- repo_packages_path(repo, type, r_version)
  res <- fs::file_copy(file, fs::dir_create(dir), overwrite = TRUE)
  package_index_insert(dir, fs::path_file(res))

  invisible(fs::path(res))
}

infer_package_type <- function(file) {
  switch(
    fs::path_ext(file),
    gz = ,
    xz = ,
    bz2 = "source",
    zip = "win.binary",
    tgz = "mac.binary",
    rlang::abort("Failed to infer package type. Please specify it explicitly.")
  )
}

#' Remove a package from a repository
#'
#' @param repo Path to the root directory of the package repository.
#' @param package The name of the package to remove.
#' @param version The version of the package to remove. Use `NULL` to remove all
#'   versions.
#' @param type The type of the package to remove.
#' @param r_version If removing a binary package, the version of R that the
#'   package was built for.
#'
#' @return The path(s) to the removed package file(s), invisibly.
#' @export
repo_remove <- function(repo, package, version, type, r_version = getRversion()) {
  dir <- repo_packages_path(repo, type, r_version)
  files <- package_index_find(dir, package, version)
  package_index_remove(dir, files)
  invisible(fs::path(files))
}

#' Update a package index of a repository
#'
#' Do a full update of a package index in a repository. Functions in this
#' package update the index as they operate, so calling this should only be
#' necessary if your index has gone out of sync due to external changes.
#'
#' @param repo Path to the root directory of the package repository.
#' @param type The type of packages to update the index for.
#' @param r_version If updating a binary package index, the R version to update
#'   the index for.
#'
#' @export
repo_update <- function(repo, type, r_version = getRversion()) {
  type <- rlang::arg_match0(type, PACKAGE_TYPES)
  dir <- repo_packages_path(repo, type, r_version)
  package_index_update(dir, type)
  invisible(NULL)
}

#' Serve a repository over HTTP
#'
#' @param repo Path to the root directory of the package repository.
#' @param ... Additional arguments passed on to [servr::httd()].
#'
#' @export
repo_serve <- function(repo, ...) {
  if (requireNamespace("servr", quietly = TRUE)) {
    servr::httd(dir = repo, ...)
  } else {
    rlang::abort("This function requires the {servr} package to be installed.")
  }
}
