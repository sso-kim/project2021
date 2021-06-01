library(readxl)
library(ggmap)
library(tidyverse)
library(ggplot2)
library(raster)
library(rgeos)
library(maptools)

p <- get_googlemap("seoul",zoom=11)%>%ggmap() 

air <- read_excel("seoul_2020.xlsx")

airseoul <- air %>%
  mutate(date_time = as.numeric(date_time))%>%
  separate(date_time,c("year","date"),4)%>%
  separate(date,c("month","dates"),2)%>%
  separate(dates,c("day",NA),2)%>%
  group_by(location, year, month)%>%
  summarise( PM10 = mean(PM10, na.rm=TRUE))

district_latlon <- mutate_geocode(airseoul,location)

korea <- getData("GADM", country = "kor", level = 2)
korea <- shapefile('TL_SCCO_SIG.shp') %>%
  spTransform(CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))
korea$SIG_KOR_NM <- iconv(korea$SIG_KOR_NM, from = "CP949", to = "UTF-8", sub = NA, mark = TRUE, toRaw = FALSE) # change encoding
korea <- fortify(korea, region='SIG_CD')
korea$id <- as.numeric(korea$id)
seoul_map <- korea[korea$id <= 11740, ]

save.image(file="district_latlon.RData")
