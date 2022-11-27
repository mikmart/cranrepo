#' Create a CRAN-like package repository
#'
#' Set up the directory structure and package indexes for
#' a CRAN-like package repository suitable to [install.packages()] from.
#'
#' Binary distribution trees are always created to avoid errors
#' when the repository is accessed via the `file://` protocol.
#'
#' @param dir Path to the directory to use as the repository root.
#'   Will be created if it does not exist.
#' @param r_version The version of R to create binary distribution trees for.
#'
#' @return Path to the repository root directory, invisibly.
#' @seealso [repo_serve()] to serve packages from the repository over HTTP.
#' @family functions to manage repositories
#' @concept manage
#' @export
repo_create <- function(dir = ".", r_version = getRversion()) {
  repo <- fs::dir_create(dir)
  for (type in PACKAGE_TYPES) {
    dir <- repo_packages_path(repo, type, r_version)
    package_index_create(dir)
  }
  invisible(fs::path(repo))
}

repo_packages_path <- function(repo, type, r_version = getRversion()) {
  type <- rlang::arg_match0(type, PACKAGE_TYPES)
  if (type != "source") {
    os <- switch(type, win.binary = "windows", mac.binary = "macosx")
    fs::path(repo, "bin", os, "contrib", numeric_version(r_version)[, 1:2])
  } else {
    fs::path(repo, "src", "contrib")
  }
}

PACKAGE_TYPES <- c("source", "win.binary", "mac.binary")

#' Insert a package bundle into a repository
#'
#' You can insert multiple packages with one call, as long as they are of the
#' same type and for the same version of R.
#'
#' @param repo Path to the root directory of the package repository.
#' @param file Path to the source or binary package bundle to be added.
#' @param type Type of packages. One of: `"source"`, `"win.binary"`, `"mac.binary"`.
#' @param r_version For binary packages, the version of R they were built for.
#' @param replace Logical. Should the package be replaced if already present?
#'
#' @return Path(s) to the inserted package file(s), invisibly.
#' @family functions to manage repositories
#' @concept manage
#' @export
repo_insert <- function(repo, file, type, r_version = getRversion(), replace = FALSE) {
  dir <- repo_packages_path(repo, type, r_version)
  res <- fs::file_copy(file, fs::dir_create(dir), overwrite = replace)
  package_index_insert(dir, fs::path_file(res))
  invisible(fs::path(res))
}

#' Remove a package from a repository
#'
#' By default, shows a list of files that _would be_ removed.
#' Explicitly specify `commit = TRUE` to actually remove them.
#'
#' @inheritParams repo_insert
#' @param package The name of the package to remove.
#' @param version The version of the package to remove.
#'   Use `NULL` to remove all versions.
#' @param commit Logical. If `FALSE` return the list of files that _would be_
#'   removed, without actually removing them.
#'
#' @return Path(s) to the removed package file(s), invisibly.
#' @family functions to manage repositories
#' @concept manage
#' @export
repo_remove <- function(repo, package, version, type, r_version = getRversion(), commit = FALSE) {
  dir <- repo_packages_path(repo, type, r_version)
  files <- package_index_find(dir, package, version)
  if (commit) {
    package_index_remove(dir, files)
  } else {
    # Higher level packages can suppress these and make their own
    rlang::inform("[i] Would remove the following files:")
    rlang::inform(paste(" *", fs::path(dir, files), collapse = "\n"))
    rlang::inform("[i] Specify `commit = TRUE` to remove them.")
  }
  invisible(fs::path(dir, files))
}

#' Update the package index of a repository
#'
#' Do a full update of the package index in a repository. Functions in this
#' package update the index as they operate, so calling this should only be
#' necessary if your index has gone out of sync due to external changes.
#'
#' @inheritParams repo_insert
#'
#' @family functions to manage repositories
#' @concept manage
#' @export
repo_update <- function(repo, type, r_version = getRversion()) {
  type <- rlang::arg_match0(type, PACKAGE_TYPES)
  dir <- repo_packages_path(repo, type, r_version)
  package_index_update(dir, type)
  invisible(NULL)
}

#' Serve a repository over HTTP
#'
#' Serve packages from a repository over HTTP locally. For production use,
#' you would likely have a different file server, but when setting up your
#' repository it can be useful to test the behaviour over a web protocol.
#'
#' @inheritParams repo_insert
#' @param ... Additional arguments passed on to [servr::httd()].
#'
#' @concept develop
#' @export
repo_serve <- function(repo, ...) {
  if (requireNamespace("servr", quietly = TRUE)) {
    servr::httd(dir = repo, ...)
  } else {
    rlang::abort("This function requires the {servr} package to be installed.")
  }
}
