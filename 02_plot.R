library(ggplot2)
library(patchwork)
library(tidyr)

# 绘制降水趋势图
plot_trend <- function(data, var_name, color, title) {
  y_range <- range(data[[var_name]], na.rm = TRUE)
  y_breaks <- pretty(y_range, n = 5)
  
  ggplot(data, aes(x = Year, y = .data[[var_name]])) +
    geom_line(color = color, linewidth = 1) +
    geom_point(color = color, size = 3) +
    labs(title = title, x = "年份", y = "降水量 (mm)") +
    scale_x_continuous(breaks = seq(1980, 2008, by = 5)) +
    scale_y_continuous(
      breaks = y_breaks,
      limits = c(min(y_breaks), max(y_breaks))  # 动态限制纵轴范围
    ) +
    THEME_CUSTOM
}

# 绘制降水-展叶期关系图
plot_correlation <- function(rain_data, ginkgo_data) {
  merged <- merge(rain_data, ginkgo_data, by = "Year")
  
  # 动态设置坐标轴范围
  x_range <- range(merged$Critical)
  y_range <- range(merged$Leafing_Day)
  
  ggplot(merged, aes(x = Critical, y = Leafing_Day)) +
    geom_point(
      color = COLOR_GINKGO, 
      size = 4, 
      alpha = 0.6,          # 增加透明度
      position = position_jitter(width = 0.02, height = 0.5)  # 添加轻微抖动
    ) +
    geom_smooth(method = "lm", color = COLOR_RAIN, se = TRUE) +
    labs(
      title = "北京2-4月降水量与银杏展叶期关系",
      x = "2-4月累计降水量 (mm)", 
      y = "展叶日（年序日）"
    ) +
    scale_x_continuous(
      breaks = scales::breaks_extended(n = 5),  # 自动生成5个合理刻度
      labels = scales::label_number(accuracy = 1),
      limits = c(x_range[1] * 0.98, x_range[2] * 1.02)  # 扩展2%范围
    ) +
    scale_y_continuous(
      breaks = scales::breaks_extended(n = 5),
      limits = c(y_range[1] - 2, y_range[2] + 2)  # 扩展2天范围
    ) +
    annotate("text", 
             x = x_range[2] * 0.85, 
             y = y_range[1] + 3,  # 调整标注位置
             label = paste0("R² = ", round(cor(merged$Critical, merged$Leafing_Day)^2, 2)),
             color = "black", size = 5) +
    THEME_CUSTOM
}