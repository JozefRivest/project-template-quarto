# Figures shared by the paper, presentation, and poster.
library(ggplot2)

cyl_colors <- c("4" = "#00274C", "6" = "#D86018", "8" = "#75988D")

plot_hp_mpg <- function(base_size = 12, point_size = 2.8) {
  ggplot(mtcars, aes(hp, mpg, color = factor(cyl), fill = factor(cyl))) +
    geom_smooth(method = "lm", formula = y ~ x, alpha = 0.15,
                linewidth = 1, show.legend = FALSE) +
    geom_point(size = point_size, shape = 21, stroke = 0.6,
               color = "white", alpha = 0.95) +
    scale_color_manual(values = cyl_colors) +
    scale_fill_manual(values = cyl_colors) +
    labs(x = "Horsepower", y = "Miles per gallon", fill = "Cylinders") +
    guides(fill = guide_legend(override.aes = list(size = point_size * 1.4))) +
    theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.4),
      axis.title = element_text(color = "grey25"),
      axis.text = element_text(color = "grey40"),
      axis.title.x = element_text(margin = margin(t = 8)),
      axis.title.y = element_text(margin = margin(r = 8)),
      legend.position = "top",
      legend.justification = "left",
      legend.title = element_text(face = "bold", color = "grey25")
    )
}
