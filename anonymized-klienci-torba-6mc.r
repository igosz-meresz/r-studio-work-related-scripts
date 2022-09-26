# last update: 22.09.2022

setwd("C:\\Users\\(...)\\****.csv")
getwd()

# the goal is to subset a list of email addresses of clients' who in the last 
# 3 months have ordered product 'torba' in order to create a segment for 
# email marketing purpose

# loading neccesary packages
library(dplyr)
library(data.table)
library(lubridate)

# importing data with fread
dt <- fread("****.csv")
class(dt$date)

# dropping all rows with orders placed earlier than 2 months ago
# saving current date as an object
today <- as.Date(Sys.Date())

# saving date 6 months prior as an object
date.calc <- today %m-% months(6)
date.calc # "2022-06-21"

# filtering out orders placed before `date` object
dt.filtered <- dt %>% filter(date >= date.calc)
View(dt.filtered)

# filtering orders with status 'anulowane'
dt.filtered.status <- filter(dt.filtered, status != 'Anulowane')

# fixing whitespaces in column names
library(janitor)
dt.filtered.status <- clean_names(dt.filtered.status)

### filtering orders containing 'Torba' in product_name_1
# I also filter out products like 'Mini' or 'XSMALL' beacuse the product
# we're trying to upsell does not fit in these 'Torba' products.
dt.filtered.product <- filter(dt.filtered.status, product_name_1 %like% 'Torba')
dt.filtered.product <- dt.filtered.product[!grepl('Mini', dt.filtered.product$product_name_1)]
dt.filtered.product <- dt.filtered.product[!grepl('XSMALL', dt.filtered.product$product_name_1)]

# now, I only need the email column to compare with email marketing list
dt.email <- dt.filtered.product[, "email", with = TRUE]

### now I need to compare both lists - dt.email and mailing list
# importing email data
gr.email <- fread("****.csv", select = 'email')

# mergning data tables (semi join)
email.join <- semi_join(x = gr.email, y = dt.email, by = 'email')

# exporting dt `email.join` to csv
fwrite(email.join, "C:\\Users\\(...)\\****.csv", row.names = FALSE)
