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
PATH_GINKGO <- here("data", "北京.xlsx")
# 创建输出目录（如果不存在）
if (!dir.exists(PATH_OUTPUT)) dir.create(PATH_OUTPUT, recursive = TRUE)
# 北京经纬度范围
BEIJING_LAT <- c(39.4, 41.6)
BEIJING_LON <- c(115.7, 117.4)
# 关键月份定义（2-4月）
CRITICAL_MONTHS <- 2:4

# 统一配色
COLOR_RAIN <- "#1f77b4"   # 降水颜色
COLOR_GINKGO <- "#ff7f0e"  # 银杏颜色

# 自定义主题
THEME_CUSTOM <- theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )