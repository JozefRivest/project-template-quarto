# Models and tables shared by the paper, presentation, and poster.
library(modelsummary)

mod <- lm(mpg ~ factor(cyl) + hp, data = mtcars)

coef_labels <- c(
  "(Intercept)"  = "Constant",
  "factor(cyl)6" = "6 cylinders",
  "factor(cyl)8" = "8 cylinders",
  "hp"           = "Horsepower"
)
gof_rows <- c("nobs", "r.squared")
