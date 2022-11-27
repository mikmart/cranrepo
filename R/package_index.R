package_index_create <- function(dir) {
  cranlike::create_empty_PACKAGES(dir)
}

package_index_update <- function(dir, type) {
  cranlike::update_PACKAGES(dir, type = type)
}

package_index_insert <- function(dir, files) {
  cranlike::add_PACKAGES(files, dir)
}

package_index_remove <- function(dir, files) {
  cranlike::remove_PACKAGES(files, dir)
}

package_index_find <- function(dir, package, version = NULL) {
  indexed_packages <- cranlike::package_versions(dir, "File")
  packages <- compact(list(Package = package, Version = version))
  merge(indexed_packages, packages)$File
}

compact <- function(x) {
  Filter(Negate(is.null), x)
}
