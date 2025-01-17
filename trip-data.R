

# install and load the required packages
library(tidyverse)
library(lubridate)
library(ggplot2)
install.packages("janitor")
library(janitor)

getwd()
# set the working directory to simplify calls to data
setwd("C:/Users/csi-694/Desktop/Data_ Analytics/Capstone_Projects/Cyclistic-Bike-Share/datasets")

# Step 1: Collect Data
# import data (divvy-tripdata csv files)
jan22 <- read_csv("202201-divvy-tripdata.csv")
feb22 <- read_csv("202202-divvy-tripdata.csv")
mar22 <- read_csv("202203-divvy-tripdata.csv")
apr22 <- read_csv("202204-divvy-tripdata.csv")
may22 <- read_csv("202205-divvy-tripdata.csv")
jun22 <- read_csv("202206-divvy-tripdata.csv")
jul22 <- read_csv("202207-divvy-tripdata.csv")
aug22 <- read_csv("202208-divvy-tripdata.csv")
sep22 <- read_csv("202209-divvy-tripdata.csv")
oct22 <- read_csv("202210-divvy-tripdata.csv")
nov22 <- read_csv("202211-divvy-tripdata.csv")
dec22 <- read_csv("202212-divvy-tripdata.csv")

# Step 2: Wrangle Data and Combine into a Single File
# Compare column names each of the files (checking datasets for consistency)
colnames(jan22)
colnames(feb22)
colnames(mar22)
colnames(apr22)
colnames(may22)
colnames(jun22)
colnames(jul22)
colnames(aug22)
colnames(sep22)
colnames(oct22)
colnames(nov22)
colnames(dec22)

#To check the data structure
str(jan22)
str(feb22)
str(mar22)
str(apr22)
str(may22)
str(jun22)
str(jul22)
str(aug22)
str(sep22)
str(oct22)
str(nov22)
str(dec22)

# merge or stack individual monthly data frames into one big data frame
trip_data <- bind_rows(jan22, feb22, mar22, apr22, may22, jun22, jul22, aug22, sep22, oct22, nov22, dec22)

#Step 3: Clean Up and Add Data to Prepare for Analysis 
#Inspect the new dataframe that has been created
#List of all column names
colnames(trip_data)

# How many rows are there in the dataframe?
nrow(trip_data)

# Dimensions of the dataframe
dim(trip_data)

# See the first 6 rows of the dataframe
head(trip_data)

# See list of columns and data types (numeric, character, etc)
str(trip_data)

# Statistical summary of data. Mainly for numerics
summary(trip_data)

# Add columns that list the date, month, day, and year of each ride
trip_data <- trip_data %>% 
  mutate(year = format(as.Date(started_at), "%Y")) %>% 
  mutate(month = format(as.Date(started_at), "%m")) %>% 
  mutate(date = format(as.Date(started_at), "%d")) %>% 
  mutate(day_of_week = format(as.Date(started_at), "%A"))

# Add a ride_length calculation to all trips (in seconds)
trip_data$ride_length <- difftime(trip_data$ended_at, trip_data$started_at)

# Convert ride_length to numeric so we can run calculations on the data
trip_data <- trip_data %>% 
  mutate(ride_length = as.numeric(ride_length))

# To check if ride_length is in right format
is.numeric(trip_data$ride_length)

# Inspect the structure of the columns
str(trip_data)

# Remove "bad" data
# The dataframe includes a few hundred entries when bikes were taken out of docks 
# and checked for quality by Divvy or ride_length was negative 
# We will create a new version of the dataframe (v2) since data is being removed

trip_data_v2 <- trip_data[!(trip_data$start_station_name=="HQ QR" | trip_data$ride_length<0),]

# First, check the cleaned dataframe
str(trip_data_v2)

# Check the summary of the cleaned dataset
summary(trip_data_v2)

# Step 4: Conduct Descriptive Analysis
# Descriptive analysis on ride_length(all figures in seconds)
# mean: straight average(total ride length/no. of rides)
# median: midpoint number in the ascending array of ride lengths
# max: longest ride
# min: shortest ride

summary(trip_data_v2$ride_length)

# Compare members and casual users
aggregate(trip_data_v2$ride_length ~ trip_data_v2$member_casual, FUN = mean)

aggregate(trip_data_v2$ride_length ~ trip_data_v2$member_casual, FUN = median)

aggregate(trip_data_v2$ride_length ~ trip_data_v2$member_casual, FUN = max)

aggregate(trip_data_v2$ride_length ~ trip_data_v2$member_casual, FUN = min)

# See the average ride time by each day for members vs casual users
aggregate(trip_data_v2$ride_length ~ trip_data_v2$member_casual + trip_data_v2$day_of_week, FUN = mean)


# In the above code, the days of the week are out of order. So, let's fix the days of the week order
trip_data_v2$day_of_week <- ordered(trip_data_v2$day_of_week, 
                                    levels = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

# Now, let's run the average ride time by each day for members vs casual users
aggregate(trip_data_v2$ride_length ~ trip_data_v2$member_casual + trip_data_v2$day_of_week, FUN = mean)

# Analyze ridership data by type and weekday
trip_data_v2 %>% 
  mutate(weekday = wday(started_at, label=TRUE)) %>% 
  group_by(member_casual,weekday) %>% 
  summarise(number_of_rides = n(), average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)

trip_data_v2 %>% 
  mutate(weekday = wday(started_at, label=TRUE)) %>% 
  filter(!is.na(member_casual) & !is.na(weekday)) %>%  # Remove rows with NA in member_casual or weekday
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n(), average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)

# Let's visualize the number of rides by rider type
trip_data_v2 %>% 
  mutate(weekday = wday(started_at, label=TRUE)) %>% 
  filter(!is.na(member_casual) & !is.na(weekday)) %>%
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n(), average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday) %>% 
  ggplot(aes(x=weekday, y=number_of_rides, fill=member_casual)) + 
  geom_col(position = "dodge")

na.omit(trip_data_v2)
trip_data_v2[complete.cases(trip_data_v2), ]

# Let's create a visualization for average duration
trip_data_v2 %>% 
  mutate(weekday = wday(started_at, label=TRUE)) %>% 
  filter(!is.na(member_casual) & !is.na(weekday)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n(), average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday) %>% 
  ggplot(aes(x=weekday, y=average_duration, fill=member_casual))+
  geom_col(position = "dodge")

# Step 5: Export summary file for further analysis
# paste the file location to export the data.
counts <- aggregate(trip_data_v2$ride_length ~ trip_data_v2$member_casual + trip_data_v2$day_of_week, FUN=mean)
write.csv(counts, file = "C:/Users/csi-694/Desktop/Data_ Analytics/Capstone_Projects/Cyclistic-Bike-Share.csv")
