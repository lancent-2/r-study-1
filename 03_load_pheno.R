# 03_load_pheno.R --------------------------------------------------------
library(readxl)
library(stringr)

load_pheno_data <- function(station_name, plant_name) {
  # 查找物候文件
  pheno_file <- list.files(
    PATH_PHENOLOGY,
    pattern = paste0(station_name, ".*\\.xlsx"),
    full.names = TRUE
  )
  if (length(pheno_file) == 0) stop("未找到物候数据文件")
  
  # 读取数据
  raw_data <- read_excel(pheno_file[1], .name_repair = "universal")
  
  # 清洗数据
  raw_data %>%
    filter(植物名 == plant_name) %>%
    mutate(
      日期 = case_when(
        str_detect(开始展叶期, "-") ~ ymd(开始展叶期),
        str_detect(开始展叶期, "月") ~ ymd(paste0(年份, "-", str_replace_all(开始展叶期, c("月" = "-", "日" = "")))),
        TRUE ~ NA_Date_
      ),
      Leafing_Day = yday(日期)
    ) %>%
    select(Year = 年份, Leafing_Day) %>%
    na.omit()
}