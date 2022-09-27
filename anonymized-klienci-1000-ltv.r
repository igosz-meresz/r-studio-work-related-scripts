# last update: 27.09.2022

# The object of this analysis is segmentation of clients
# who have spent over 1000PLN in total.

# My focus is on clients who placed their orders in 2016 or later.

# This segment will be used by marketing team to target clients
# more accurately and attempt to upsell products via email marketing campaigns.


# Setting working directory
setwd("C:\\(...)")
getwd()

# loading neccesary libraries
library(data.table)
library(tidyr)
library(dplyr)
library(janitor)

# I will work on data.table objects for its speed of execution.
# It's not neccessary a large dataset, however it's a good practice
# to always use tools with least transactions cost.

# Other advantage of data.table object is that it more accurately assigns
# class

# importing customer / orders data from Shoper admin panel
dt.originial <- fread("****.csv", encoding = 'UTF-8')
View(dt.originial) # 8,822 entries

# removing rows with blank email address
dt.processed <- dt.originial[!dt.originial$email == "",]
View(dt.processed) # 8,754 entries

# normalizing email addresses to lowercase
dt.processed$email <- tolower(dt.processed$email)
View(dt.processed)

# filtering out orders cancelled orders and orders placed before 2016-01-01
dt.processed <- filter(dt.processed, status == 'Wysłane') %>%
  filter(date >= '2016-01-01')
View(dt.processed) # 7,888 entries

# now I need to fix rownames so that they don't contain any white spaces
dt.processed <- clean_names(dt.processed)

# summing orders for individual clients
dt.sum <- dt.processed[, .(group_sum = sum(sum)), by = email]
dt.filtered.values <- dt.sum[group_sum > 1000, ]
View(dt.filtered.values) # 251 entries

# out of curiosity, I'm going to calculate the mean too
dt.mean <- dt.sum[, .(group_mean = mean(group_sum))]
View(dt.mean) # mean order value is 402 PLN 

# I only need the 'email' column
dt.email <- dt.filtered.values[, "email", with = TRUE]
View(dt.email)

### now I need to compare both lists - dt.email and mailing list
# importing email data
gr.email <- fread("****.csv", select = 'email')

# mergning data tables (semi join)
email.join <- semi_join(x = gr.email, y = dt.email, by = 'email')
View(email.join) # 154 entries

# removing any possible duplicates
email.join.distinct <- distinct(email.join)
View(email.join.distinct) # there are no duplicates

sample_n(email.join.distinct, 10)

# exporting email marketing list
fwrite(email.join, "C:\\(...)\\****.csv", row.names = FALSE)
