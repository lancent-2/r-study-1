source("00_config.R")
source("01_load_nc.R")
source("02_plot.R")
source("03_load_ginkgo.R")

# 加载数据
nc_files <- list.files(PATH_DATA, pattern = "\\.nc$", full.names = TRUE)
rain_data <- process_yearly_data(nc_files)
ginkgo_data <- load_ginkgo_data()

# 生成单个图像
p_annual <- plot_trend(rain_data, "Annual", COLOR_RAIN, "北京年降水量趋势（1979-2008）")
p_critical <- plot_trend(rain_data, "Critical", COLOR_RAIN, "北京2-4月降水量趋势")
p_relation <- plot_correlation(rain_data, ginkgo_data)

# 在R中直接显示图像
print(p_annual)
print(p_critical)
print(p_relation)

# 保存独立图像
ggsave(here("output", "annual_precip.png"), p_annual, width = 8, height = 6, dpi = 300)
ggsave(here("output", "critical_precip.png"), p_critical, width = 8, height = 6, dpi = 300)
ggsave(here("output", "precip_ginkgo_correlation.png"), p_relation, width = 8, height = 6, dpi = 300)

# 组合图像并保存
combined_plot <- (p_annual | p_critical) / p_relation + 
  plot_annotation(tag_levels = "A") &
  theme(plot.tag = element_text(size = 14, face = "bold"))

ggsave(here("output", "combined_results.png"), combined_plot, width = 12, height = 10, dpi = 300)


# 加载冬季降水数据
winter_data <- process_winter_precip(nc_files)
merged_winter <- merge(ginkgo_data, winter_data, by = "Year")

# 生成冬季降水与展叶期关系图
p_winter <- ggplot(merged_winter, aes(x = Winter_Precip, y = Leafing_Day)) +
  geom_point(color = "#4DAF4A", size = 4, alpha = 0.7) +
  geom_smooth(method = "lm", color = "#984EA3", se = TRUE) +
  labs(
    title = "前一年冬季降水量与展叶期关系",
    x = "冬季降水量 (mm)",
    y = "展叶日（年序日）"
  ) +
  scale_x_continuous(breaks = scales::breaks_extended(n = 5)) +
  scale_y_continuous(breaks = scales::breaks_extended(n = 5)) +
  THEME_CUSTOM

# 保存结果
ggsave(here("output", "winter_effect.png"), p_winter, width = 8, height = 6, dpi = 300)     