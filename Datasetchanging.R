#importing packages
library(dplyr)
library(stringr)
install.packages("lubridate")
library(lubridate)

#data importing
complete.dataset<-read.csv("911.csv")
str(complete.dataset)
nrow(complete.dataset)

#data cleaning
clean.dataset<-na.omit(complete.dataset)
nrow(clean.dataset)
clean.dataset<-clean.dataset[,-9]
index<-c(1:86637)
clean.dataset<-cbind(index,clean.dataset)

address.data<-select(clean.dataset,index,lat,lng,zip,addr,twp,timeStamp)
crime.data<-select(clean.dataset,index,title)

crime.data[c('Type','subcategory')]<-str_split_fixed(crime.data$title,': ', 2)
crime.data<-crime.data[c('index','Type','subcategory')]

address.data["date"]<-as.Date(address.data$timeStamp)
address.data["Time"]<-format(as.POSIXct(address.data$timeStamp), format = "%H:%M:%S")
address.data<-address.data[-7]

time.data<-select(address.data,index,date,Time)
address.data<-address.data[c(-7,-8)]

holidays<-as.Date(c("2015-12-25","2016-01-01","2016-01-18","2016-02-15","2016-05-30","2016-07-04"))
time.data<-time.data %>% mutate(Holiday = if_else(date %in% holidays, "Yes", "No"))
time.data$weekday<- wday(time.data$date, label=TRUE, abbr=FALSE)
time.data<-time.data %>% mutate(Noon = if_else(Time<"12:00:00", "Before Noon", "After Noon"))

#data export 
write.csv(address.data,"addressdata.csv",row.names = F)
write.csv(time.data,"timedata.csv",row.names = F)
write.csv(crime.data,"crimedata.csv",row.names = F)
