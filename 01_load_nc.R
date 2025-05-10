# 01_load_nc.R -----------------------------------------------------------
library(ncdf4)
library(dplyr)
library(purrr)

parse_year <- function(file_path) {
  as.numeric(sub(".*_(\\d{4})\\d{2}-.*", "\\1", basename(file_path)))
}

load_nc_data <- function(nc_file, target_lon, target_lat) {
  nc <- nc_open(nc_file)
  
  # 获取维度
  lon <- ncvar_get(nc, "lon")
  lat <- ncvar_get(nc, "lat")
  
  # 找到最近格点
  find_nearest <- function(arr, val) which.min(abs(arr - val))
  lon_idx <- find_nearest(lon, target_lon)
  lat_idx <- find_nearest(lat, target_lat)
  
  # 读取数据
  prec <- ncvar_get(nc, "prec")
  fill_value <- ncatt_get(nc, "prec", "_FillValue")$value
  prec[prec == fill_value] <- NA
  
  nc_close(nc)
  
  return(list(
    lon = lon[lon_idx],
    lat = lat[lat_idx],
    prec = prec[lon_idx, lat_idx, ]
  ))
}

process_yearly_data <- function(nc_files, target_lon, target_lat) {
  map_dfr(nc_files, ~{
    data <- load_nc_data(.x, target_lon, target_lat)
    year <- parse_year(.x)
    
    data.frame(
      Year = year,
      Annual = sum(data$prec, na.rm = TRUE),
      Critical = sum(data$prec[2:4], na.rm = TRUE) # 2-4月
    )
  })
}

process_winter_precip <- function(nc_files, target_lon, target_lat) {
  map_dfr(seq_along(nc_files), function(i) {
    if (i == 1) return(data.frame())
    
    prev_data <- load_nc_data(nc_files[i-1], target_lon, target_lat)
    curr_data <- load_nc_data(nc_files[i], target_lon, target_lat)
    
    winter_precip <- sum(
      prev_data$prec[12],    # 前一年12月
      curr_data$prec[1:2],   # 当年1-2月
      na.rm = TRUE
    )
    
    data.frame(Year = parse_year(nc_files[i]), Winter_Precip = winter_precip)
  })
}