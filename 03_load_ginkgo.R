library(readxl)
library(lubridate)
library(stringr)
library(dplyr)

# 加载并清洗银杏展叶期数据
load_ginkgo_data <- function() {
  raw_data <- read_excel(PATH_GINKGO, .name_repair = "universal")
  
  # 验证列名
  required_cols <- c("植物名", "开始展叶期", "年份")
  if (!all(required_cols %in% colnames(raw_data))) {
    stop("Excel文件中缺少必要列：'植物名', '开始展叶期', '年份'")
  }
  
  cleaned_data <- raw_data %>%
    filter(植物名 == "银杏", !is.na(开始展叶期)) %>%
    mutate(
      # 提取有效日期（兼容更多格式）
      日期字符串 = str_extract(开始展叶期, "\\d{4}-\\d{1,2}-\\d{1,2}|\\d{1,2}月\\d{1,2}日|\\d{1,2}-\\d{1,2}"),
      
      # 分情况处理日期格式
      开始展叶期 = case_when(
        str_detect(日期字符串, "^\\d{4}-") ~ ymd(日期字符串),  # "YYYY-MM-DD"
        str_detect(日期字符串, "月") ~ {                        # "X月X日"
          clean_date <- str_replace_all(日期字符串, c("月" = "-", "日" = ""))
          ymd(paste0(年份, "-", clean_date))  # 使用实际年份
        },
        str_detect(日期字符串, "^\\d{1,2}-\\d{1,2}$") ~ {       # "MM-DD"
          ymd(paste0(年份, "-", 日期字符串))  # 使用实际年份
        },
        TRUE ~ NA_Date_
      ),
      
      # 转换为数值格式（月份 + 日/31）
      展叶期数值 = month(开始展叶期) + day(开始展叶期)/31
    ) %>%
    filter(!is.na(开始展叶期)) %>%
    select(Year = 年份, Leafing_Day = 展叶期数值)
  return(cleaned_data)
}