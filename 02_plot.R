# 02_plot.R --------------------------------------------------------------
library(ggplot2)
library(patchwork)
library(ggpmisc)
library(ggpubr)

plot_trend <- function(data, var_name, color, title) {
  if (!var_name %in% names(data)) {
    stop("列名 '", var_name, "' 在数据中不存在")
  }
  
  ggplot(data, aes(x = Year, y = .data[[var_name]])) +
    geom_line(color = color, linewidth = 1, alpha = 0.8) +
    geom_point(color = color, size = 3, shape = 21, fill = "white", stroke = 1.5) +
    labs(title = title, x = "年份", y = "降水量 (mm)") +
    scale_x_continuous(breaks = scales::breaks_pretty(n = 8)) +
    geom_smooth(method = "lm", se = FALSE, color = "gray40", linetype = "dashed") +
    ggpmisc::stat_poly_eq(use_label(c("eq", "R2")), label.x = 0.1, label.y = 0.95) +
    THEME_CUSTOM
}

plot_correlation <- function(data, color_point, color_line) {
  ggplot(data, aes(x = Critical, y = Leafing_Day)) +
    geom_point(color = color_point, size = 4, alpha = 0.7, shape = 17) +
    geom_smooth(
      method = "lm",
      formula = y ~ x,
      color = color_line,
      se = TRUE,
      fill = "gray80"
    ) +
    labs(
      x = "2-4月降水量 (mm)",
      y = "展叶日（年序日）",
      title = "关键期降水量与展叶日相关性"
    ) +
    ggpubr::stat_cor(
      method = "pearson",
      label.x.npc = 0.05,
      label.y.npc = 0.95,
      size = 4.5,
      color = "black"
    ) +
    THEME_CUSTOM
}