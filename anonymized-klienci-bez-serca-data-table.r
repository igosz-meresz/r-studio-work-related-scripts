# last update: 23.09.2022

# The object of this analysis is segmentation of clients
# who have purchased 'Torba' or 'Plecak' product in sizes M or L
# but haven't purchased a 'Serce Torby' product. 

# My focus is on clients who placed their orders in 2016 or later.

# This segment will be used by marketing team to target clients
# more accurately and attempt to upsell products via email marketing campaigns.


# Setting working directory
setwd("C:\\(...)\\")
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

# filtering clients who have ordered desired products
dt.filtered <- filter(dt.processed, product_name_1 %like% 'Torba' | product_name_1 %like% 'bag')
View(dt.filtered) # 4,555 entries

# filtering out products that are too small for the product we're trying to upsell
dt.filtered <- dt.filtered[!grepl('Mini', dt.filtered$product_name_1)]
dt.filtered <- dt.filtered[!grepl('XSMALL', dt.filtered$product_name_1)]
dt.filtered <- dt.filtered[!grepl('SMALL', dt.filtered$product_name_1)]
View(dt.filtered) # 3,375 entries

# filtering out clients who already have a 'Serce Torby'
dt.filtered <- dt.filtered[!grepl('SERCE', dt.filtered$product_name_1)]
dt.filtered <- dt.filtered[!grepl('SERCE', dt.filtered$product_name_2)]
View(dt.filtered) # 3,365 entries

# I need just the email address list now
dt.email <- dt.filtered[, "email", with = TRUE]
View(dt.email) # 3,365 entries

### now I need to compare both lists - dt.email and mailing list
# importing email data
gr.email <- fread("****.csv", select = 'email')

# mergning data tables (semi join)
email.join <- semi_join(x = gr.email, y = dt.email, by = 'email')
View(email.join) # 1,394 entries

# removing any possible duplicates
email.join.distinct <- distinct(email.join)
View(email.join.distinct) # there are no duplicates

sample_n(email.join.distinct, 10)

# exporting email marketing list
fwrite(email.join, "C:\\Users\\(...)\\****.csv", row.names = FALSE)
