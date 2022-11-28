#' Create a CRAN-like package repository
#'
#' Set up the directory structure and package indexes for
#' a CRAN-like package repository suitable to [install.packages()] from.
#'
#' Binary distribution trees are always created to avoid errors
#' when the repository is accessed via the `file://` protocol.
#'
#' @param root Path to the directory to use as the repository root.
#'   Will be created if it does not exist.
#' @param r_version The version of R to create binary distribution trees for.
#'
#' @return Path to the repository root directory, invisibly.
#' @seealso [repo_serve()] to serve packages from the repository over HTTP.
#' @family functions to manage repositories
#' @concept manage
#' @export
repo_create <- function(root = ".", r_version = getRversion()) {
  repo <- fs::dir_create(root)
  for (type in c("source", "win.binary", "mac.binary")) {
    contrib_url_create(contrib_url(repo, type, r_version))
  }
  invisible(repo)
}

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
repo_insert <- function(repo, file, type, r_version = getRversion(), replace = TRUE) {
  dir <- contrib_url(repo, type, r_version)
  if (!replace && any(contrib_url_contains(dir, file) -> exist)) {
    rlang::abort(
      "Package(s) already present in repository.",
      files = fs::path(dir, fs::path_file(file))[which(exist)],
      class = "cranrepo_error_packages_exist"
    )
  }
  invisible(contrib_url_insert(dir, file))
}

#' Remove a package from a repository
#'
#' For a dry run, specify `commit = FALSE` to just show a list of files
#' that _would be_ removed.
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
repo_remove <- function(repo, package, version, type, r_version = getRversion(), commit = TRUE) {
  dir <- contrib_url(repo, type, r_version)
  if (!commit) {
    return(contrib_url_find(dir, package, version))
  }
  invisible(contrib_url_remove(dir, package, version))
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
  contrib_url_update(contrib_url(repo, type, r_version))
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
    rlang::abort(c(
      "This function requires the {servr} package.",
      i = "Install it with `install.packages(\"servr\")`."
    ))
  }
}
