library(ncdf4)
library(dplyr)
library(purrr)

# 从文件名解析年份
parse_year <- function(file_path) {
  as.numeric(sub(".*_(\\d{4})\\d{2}-.*", "\\1", basename(file_path)))
}

# 核心数据加载函数
load_nc_data <- function(nc_file) {
  nc <- nc_open(nc_file)
  
  # 读取维度
  lat <- ncvar_get(nc, "lat")
  lon <- ncvar_get(nc, "lon")
  time <- ncvar_get(nc, "time")
  prec <- ncvar_get(nc, "prec")
  # 读取降水数据并转换
 
  fill_value <- ncatt_get(nc, "prec", "_FillValue")$value
  
  prec[prec == fill_value] <- NA
  
  # 北京区域索引
  lat_idx <- which(lat >= BEIJING_LAT[1] & lat <= BEIJING_LAT[2])
  lon_idx <- which(lon >= BEIJING_LON[1] & lon <= BEIJING_LON[2])
  
  nc_close(nc)
  list(lat = lat, lon = lon, prec = prec, lat_idx = lat_idx, lon_idx = lon_idx)
}

# 处理所有年份数据
process_yearly_data <- function(nc_files) {
  purrr::map_dfr(nc_files, ~{
    data <- load_nc_data(.x)
    year <- parse_year(.x)
    
    #
    annual <- sum(data$prec[data$lon_idx, data$lat_idx, ], na.rm = TRUE) * 1  # 确认单位转换系数
    critical <- sum(data$prec[data$lon_idx, data$lat_idx, CRITICAL_MONTHS], na.rm = TRUE)
    
    data.frame(Year = year, Annual = annual, Critical = critical)
  })
}
# 提取前一年冬季降水（12月-次年2月）
process_winter_precip <- function(nc_files) {
  map_dfr(seq_along(nc_files), function(i) {
    if (i == 1) return(data.frame())  # 第一年无前一年数据
    
    # 读取前一年文件
    prev_file <- nc_files[i-1]
    prev_data <- load_nc_data(prev_file)
    prev_year <- parse_year(prev_file)
    
    # 前一年12月 + 当前年1-2月
    winter_precip <- sum(
      prev_data$prec[prev_data$lon_idx, prev_data$lat_idx, 12],  # 前一年12月
      load_nc_data(nc_files[i])$prec[prev_data$lon_idx, prev_data$lat_idx, 1:2],  # 当前年1-2月
      na.rm = TRUE
    )
    
    data.frame(Year = prev_year + 1, Winter_Precip = winter_precip)  # 关联到次年
  })
}