# 00_config.R ------------------------------------------------------------
library(here)
library(ggplot2)
library(patchwork)
library(readxl)
library(ncdf4)
library(lubridate)
here::i_am("scripts/main.R")  # 声明根目录

# 定义路径
PATH_DATA <- here("data")
PATH_OUTPUT <- here("output")
PATH_STATION_INFO <- here("data", "站点信息.xlsx")
PATH_PHENOLOGY <- here("data", "phenology")

# 创建输出目录
if (!dir.exists(PATH_OUTPUT)) dir.create(PATH_OUTPUT, recursive = TRUE)

# 北京经纬度范围
BEIJING_LAT <- c(39.4, 41.6)
BEIJING_LON <- c(115.7, 117.4)

# 关键月份定义
CRITICAL_MONTHS <- 2:4

# 统一配色
COLOR_RAIN <- "#1f77b4"
COLOR_GINKGO <- "#ff7f0e"

# 增强版主题
THEME_CUSTOM <- theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14, margin = margin(b = 15)),
    axis.title = element_text(size = 12, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1, color = "gray30"),
    axis.text.y = element_text(color = "gray30"),
    panel.grid.major = element_line(color = "gray90", linewidth = 0.2),
    panel.grid.minor = element_blank(),
    plot.margin = margin(20, 20, 20, 20)
  )