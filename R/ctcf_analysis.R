# CTCF analysis using Fiji-exported polygon ROI files
#
# Formula:
# CTCF = Integrated Density - (ROI Area * Mean Background Intensity)

required_packages <- c(
  "EBImage",
  "RImageJROI",
  "sp",
  "dplyr",
  "readr"
)

check_packages <- function(packages) {
  missing_packages <- packages[
    !vapply(packages, requireNamespace, logical(1), quietly = TRUE)
  ]

  if (length(missing_packages) > 0) {
    stop(
      "Missing packages: ",
      paste(missing_packages, collapse = ", "),
      "\nInstall Bioconductor packages separately where required."
    )
  }
}

check_packages(required_packages)

library(EBImage)
library(RImageJROI)
library(sp)
library(dplyr)
library(readr)

create_polygon_mask <- function(roi_obj, ref_img) {
  if (is.null(roi_obj$coords)) {
    stop("ROI does not contain coordinate data.")
  }

  if (is.list(roi_obj$coords)) {
    x_coords <- roi_obj$coords$x
    y_coords <- roi_obj$coords$y
  } else {
    coords_vec <- roi_obj$coords

    if (length(coords_vec) %% 2 != 0) {
      stop("ROI coordinate vector has an invalid length.")
    }

    x_coords <- coords_vec[seq(1, length(coords_vec), by = 2)]
    y_coords <- coords_vec[seq(2, length(coords_vec), by = 2)]
  }

  width <- dim(ref_img)[1]
  height <- dim(ref_img)[2]

  grid <- expand.grid(
    x = 0:(width - 1),
    y = 0:(height - 1)
  )

  inside <- sp::point.in.polygon(
    grid$x,
    grid$y,
    x_coords,
    y_coords
  )

  mask <- EBImage::Image(0, dim = c(width, height))

  selected_points <- grid[inside != 0, , drop = FALSE]

  if (nrow(selected_points) > 0) {
    mask[
      cbind(
        selected_points$x + 1,
        selected_points$y + 1
      )
    ] <- 1
  }

  mask
}

compute_roi_stats <- function(roi_path, ref_img) {
  roi_obj <- RImageJROI::read.ijroi(roi_path)

  shape <- tolower(roi_obj$strType)

  if (shape != "polygon") {
    warning(
      "Skipping non-polygon ROI: ",
      basename(roi_path),
      " (type = ",
      roi_obj$strType,
      ")"
    )
    return(NULL)
  }

  mask <- create_polygon_mask(roi_obj, ref_img)
  roi_pixels <- ref_img[mask == 1]

  if (length(roi_pixels) == 0) {
    warning("ROI contains no selected pixels: ", basename(roi_path))
    return(NULL)
  }

  tibble(
    roi_file = basename(roi_path),
    roi_type = if_else(
      grepl("bg", basename(roi_path), ignore.case = TRUE),
      "Background",
      "Cell"
    ),
    area = length(roi_pixels),
    mean_intensity = mean(roi_pixels, na.rm = TRUE),
    min_intensity = min(roi_pixels, na.rm = TRUE),
    max_intensity = max(roi_pixels, na.rm = TRUE),
    integrated_density = sum(roi_pixels, na.rm = TRUE)
  )
}

analyse_ctcf <- function(image_path, roi_dir, output_csv) {
  if (!file.exists(image_path)) {
    stop("Image file not found: ", image_path)
  }

  if (!dir.exists(roi_dir)) {
    stop("ROI directory not found: ", roi_dir)
  }

  colour_image <- EBImage::readImage(image_path)

  if (max(colour_image, na.rm = TRUE) <= 1) {
    colour_image <- colour_image * 255
  }

  green_image <- EBImage::channel(colour_image, "green")

  roi_files <- list.files(
    roi_dir,
    pattern = "\\.roi$",
    full.names = TRUE
  )

  if (length(roi_files) == 0) {
    stop("No .roi files found in: ", roi_dir)
  }

  measurements <- lapply(
    roi_files,
    compute_roi_stats,
    ref_img = green_image
  )

  measurements <- measurements[!vapply(measurements, is.null, logical(1))]

  if (length(measurements) == 0) {
    stop("No valid polygon ROIs were measured.")
  }

  measurement_df <- bind_rows(measurements)

  background_mean <- measurement_df %>%
    filter(roi_type == "Background") %>%
    summarise(
      value = mean(mean_intensity, na.rm = TRUE)
    ) %>%
    pull(value)

  if (length(background_mean) == 0 || is.na(background_mean)) {
    stop("No valid background ROI was found.")
  }

  final_df <- measurement_df %>%
    mutate(
      background_mean = background_mean,
      CTCF = if_else(
        roi_type == "Cell",
        integrated_density - area * background_mean,
        NA_real_
      ),
      valid_ctcf = is.na(CTCF) | CTCF >= 0
    )

  readr::write_csv(final_df, output_csv)

  final_df
}

# Example usage:
#
# results <- analyse_ctcf(
#   image_path = "data/example_image.tif",
#   roi_dir = "data/example_rois",
#   output_csv = "outputs/ctcf_results.csv"
# )
#
# print(results)
