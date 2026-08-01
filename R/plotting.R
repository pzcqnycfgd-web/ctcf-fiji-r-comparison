library(dplyr)
library(ggplot2)
library(readr)

plot_ctcf_summary <- function(input_csv, output_png = NULL) {
  data <- readr::read_csv(input_csv, show_col_types = FALSE)

  plot_data <- data %>%
    filter(
      roi_type == "Cell",
      valid_ctcf,
      !is.na(CTCF)
    )

  p <- ggplot(
    plot_data,
    aes(x = roi_file, y = CTCF)
  ) +
    geom_col() +
    labs(
      title = "Corrected Total Cell Fluorescence",
      x = "Cell ROI",
      y = "CTCF"
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(
        angle = 90,
        hjust = 1
      )
    )

  if (!is.null(output_png)) {
    ggsave(
      output_png,
      plot = p,
      width = 10,
      height = 6,
      dpi = 300
    )
  }

  p
}
