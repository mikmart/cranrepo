# cranrepo

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/mikmart/cranrepo/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mikmart/cranrepo/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

cranrepo gives you the basic tools to set up your own CRAN-like R package repository. You can:

- Set up a repository directory structure and index with `repo_create()`.
- Add source and binary package bundles to a repository with `repo_insert()`.
- Remove versions of packages from a repository with `repo_remove()`.
- Serve repositories over HTTP for development purposes with `repo_serve()`.

Other key features include:

- Fast updates to the package index, thanks to [cranlike](https://cran.r-project.org/package=cranlike) under the hood.
- A concise yet sufficient interface to easily build other tools on top of.

## Installation

You can install the development version of cranrepo from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mikmart/cranrepo")
```

## Motivation

Other packages in the repository management space include:

- [miniCRAN](https://cran.r-project.org/package=miniCRAN), which focuses on
creating complete snapshots of sets of curated packages from CRAN-like repos,
but lacks support for packages from other sources, such as local bundles.
- [drat](https://cran.r-project.org/package=drat), which has a broad set of
tools to manage your own repository, but also has many high level features,
conveniences (especially around git and GitHub), and opinions that can cause
friction when trying to use it as a base for other tools.

The goal of cranrepo is to strike a balance between being high level enough to
be useful on its own for setting up a repository, yet low level enough to make
it easy to build other tools on top of. Essentially, it's the set of fundamental
repository management tools I wish drat exposed.
