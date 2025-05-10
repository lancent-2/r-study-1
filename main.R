# main.R -----------------------------------------------------------------
library(dplyr)
library(ggplot2)
library(readxl)
library(ncdf4)
library(lubridate)
library(here)

source("00_config.R")
source("01_load_nc.R")
source("02_plot.R")
source("03_load_pheno.R")

# 用户输入
STATION_NAME <- "洛阳"
PLANT_NAME <- "枣"

# 加载站点信息
station_info <- read_excel(PATH_STATION_INFO) %>%
  filter(站点 == STATION_NAME)

# 加载数据
nc_files <- list.files(PATH_DATA, pattern = "\\.nc$", full.names = TRUE)
rain_data <- process_yearly_data(nc_files, station_info$经度, station_info$纬度)
winter_data <- process_winter_precip(nc_files, station_info$经度, station_info$纬度)
pheno_data <- load_pheno_data(STATION_NAME, PLANT_NAME)

# 统一列名和数据类型
colnames(rain_data)[1] <- "Year"
colnames(winter_data)[1] <- "Year"
colnames(pheno_data)[1] <- "Year"

rain_data$Year <- as.numeric(rain_data$Year)
winter_data$Year <- as.numeric(winter_data$Year)
pheno_data$Year <- as.numeric(pheno_data$Year)

# 数据清洗
clean_data <- function(df) {
  df %>%
    distinct(Year, .keep_all = TRUE) %>%
    filter(!is.na(Year))
}

rain_data <- clean_data(rain_data)
winter_data <- clean_data(winter_data)
pheno_data <- clean_data(pheno_data)

# 动态获取共同年份范围
valid_years <- intersect(
  intersect(rain_data$Year, winter_data$Year),
  pheno_data$Year
)

# 筛选数据
rain_data <- rain_data %>% filter(Year %in% valid_years)
winter_data <- winter_data %>% filter(Year %in% valid_years)
pheno_data <- pheno_data %>% filter(Year %in% valid_years)

# 合并数据
full_data <- rain_data %>%
  left_join(winter_data, by = "Year") %>%
  left_join(pheno_data, by = "Year") %>%
  na.omit()

# 生成图表
p_annual <- plot_trend(
  rain_data, 
  "Annual", 
  COLOR_RAIN, 
  paste0(STATION_NAME, "年降水量趋势 (", min(valid_years), "-", max(valid_years), ")")
)

p_winter <- plot_trend(
  full_data, 
  "Winter_Precip", 
  "#4DAF4A", 
  paste0(STATION_NAME, "冬季降水量趋势 (", min(valid_years), "-", max(valid_years), ")")
)

p_cor <- plot_correlation(full_data, COLOR_GINKGO, COLOR_RAIN)

# 保存高分辨率结果
ggsave(
  file.path(PATH_OUTPUT, paste0(STATION_NAME, "_", PLANT_NAME, "_趋势.png")),
  p_annual + p_winter,
  width = 14, 
  height = 6,
  dpi = 300
)

ggsave(
  file.path(PATH_OUTPUT, paste0(STATION_NAME, "_", PLANT_NAME, "_相关.png")),
  p_cor,
  width = 8, 
  height = 6,
  dpi = 300
)