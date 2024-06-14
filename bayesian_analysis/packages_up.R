# Read the environment variable
wdir <- Sys.getenv("WDIR")

# Define the library path using the environment variable
lib_path <- file.path(wdir, "packages_extracted")

# Function to install packages from tar.gz files
install_from_tar <- function(package_tar) {
  install.packages(package_tar, lib = lib_path, repos = NULL, type = "source")
}

# List of package tar.gz files
package_tars <- c(
  file.path(wdir, "packages/loo_2.7.0.tar.gz"),
  file.path(wdir, "packages/Matrix_1.6-5.tar.gz"),
  file.path(wdir, "packages/inline_0.3.19.tar.gz"),
  file.path(wdir, "packages/jsonlite_1.8.8.tar.gz"),
  file.path(wdir, "packages/R6_2.5.1.tar.gz"),
  file.path(wdir, "packages/Rcpp_1.0.12.tar.gz"),
  file.path(wdir, "packages/QuickJSR_1.1.3.tar.gz"),
  file.path(wdir, "packages/RcppEigen_0.3.4.0.0.tar.gz"),
  file.path(wdir, "packages/RcppParallel_5.1.7.tar.gz"),
  file.path(wdir, "packages/BH_1.84.0-0.tar.gz"),
  file.path(wdir, "packages/StanHeaders_2.32.6.tar.gz"),
  file.path(wdir, "packages/xfun_0.43.tar.gz"),
  file.path(wdir, "packages/knitr_1.46.tar.gz"),
  file.path(wdir, "packages/rmarkdown_2.26.tar.gz"),
  file.path(wdir, "packages/htmltools_0.5.8.1.tar.gz"),
  file.path(wdir, "packages/htmlwidgets_1.6.4.tar.gz"),
  file.path(wdir, "packages/colourpicker_1.3.0.tar.gz"),
  file.path(wdir, "packages/threejs_0.3.3.tar.gz"),
  file.path(wdir, "packages/dygraphs_1.1.1.6.tar.gz"),
  file.path(wdir, "packages/shinythemes_1.2.0.tar.gz"),
  file.path(wdir, "packages/Brobdingnag_1.2-9.tar.gz"),
  file.path(wdir, "packages/rlang_1.1.3.tar.gz"),
  file.path(wdir, "packages/scales_1.3.0.tar.gz"),
  file.path(wdir, "packages/vctrs_0.6.5.tar.gz"),
  file.path(wdir, "packages/lifecycle_1.0.4.tar.gz"),
  file.path(wdir, "packages/ggplot2_3.5.0.tar.gz"),
  file.path(wdir, "packages/rstan_2.32.5.tar.gz"),
  file.path(wdir, "packages/rstantools_2.4.0.tar.gz"),
  file.path(wdir, "packages/cmdstanr_0.7.1.tar.gz"),
  file.path(wdir, "packages/bayesplot_1.11.1.tar.gz"),
  file.path(wdir, "packages/DT_0.33.tar.gz"),
  file.path(wdir, "packages/shinystan_2.6.0.tar.gz"),
  file.path(wdir, "packages/bridgesampling_1.1-2.tar.gz"),
  file.path(wdir, "packages/nleqslv_3.3.5.tar.gz"),
  file.path(wdir, "packages/brms_2.20.4.tar.gz")
)

# Install packages from tar.gz files
lapply(package_tars, install_from_tar)

# Load the libraries
library("loo", lib.loc = lib_path)
library("Matrix", lib.loc = lib_path)
library("inline", lib.loc = lib_path)
library("jsonlite", lib.loc = lib_path)
library("R6", lib.loc = lib_path)
library("Rcpp", lib.loc = lib_path)
library("QuickJSR", lib.loc = lib_path)
library("RcppEigen", lib.loc = lib_path)
library("RcppParallel", lib.loc = lib_path)
library("BH", lib.loc = lib_path)
library("StanHeaders", lib.loc = lib_path)
library("xfun", lib.loc = lib_path)
library("knitr", lib.loc = lib_path)
library("rmarkdown", lib.loc = lib_path)
library("htmltools", lib.loc = lib_path)
library("htmlwidgets", lib.loc = lib_path)
library("colourpicker", lib.loc = lib_path)
library("threejs", lib.loc = lib_path)
library("dygraphs", lib.loc = lib_path)
library("shinythemes", lib.loc = lib_path)
library("Brobdingnag", lib.loc = lib_path)
library("rlang", lib.loc = lib_path)
library("scales", lib.loc = lib_path)
library("vctrs", lib.loc = lib_path)
library("lifecycle", lib.loc = lib_path)
library("ggplot2", lib.loc = lib_path)
library("rstan", lib.loc = lib_path)
library("rstantools", lib.loc = lib_path)
library("cmdstanr", lib.loc = lib_path)
library("bayesplot", lib.loc = lib_path)
library("DT", lib.loc = lib_path)
library("shinystan", lib.loc = lib_path)
library("bridgesampling", lib.loc = lib_path)
library("nleqslv", lib.loc = lib_path)
library("brms", lib.loc = lib_path)
