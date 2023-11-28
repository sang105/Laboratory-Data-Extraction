###### R script to query and merge data and save as RDS file for Shiny to read from file ######
library(DBI)
library(data.table)
library(RSQLite)
library(dplyr)

# Get MS SQL Database credentials from config.yml file 
dw = config::get("datawarehouse")

# Connect to MS SQL Database
con_sql <- DBI::dbConnect(
  odbc::odbc(),
  Driver="ODBC Driver 17 for SQL Server",
  Server = dw$server,
  UID    = dw$usr,
  PWD    = dw$pwd,
  Database = dw$database,
)

# Query from MS SQL Database table for all laboratory data
data_sql <- dbGetQuery(con_sql, "SELECT [PlateID]
          ,[ReducedValue]
          ,[WellName]
          ,[Row_Number]
          ,[Column_Number]
          ,[ReadMode]
          ,[FileName] FROM LabData")
dbDisconnect(con_sql)

# Convert the columns from the extracted dataset to integer
data_sql <- data_sql %>%
  mutate_at(c("Row_Number", "Column_Number"), as.integer)

# Connect to SQLite Database
con <- dbConnect(RSQLite::SQLite(),"www/SpectraxMaxDB.sqlite")

# Get all tables from SQLite Database with Experiments table being the exception
table_names <- dbGetQuery(con, "SELECT name FROM sqlite_master WHERE type='table' AND name != 'Experiments'")

# Close the database connection
dbDisconnect(con)

# Create an empty dataframe to store the combined results
combined_data <- data.frame()

# Connect to the database
con <- dbConnect(RSQLite::SQLite(),"www/SpectraxMaxDB.sqlite")

# Loop through the table names and query data
for (table_name in table_names$name) {

  # Query data from the current table
  query <- paste0("SELECT * FROM ", "'",table_name,"'")
  
  # Save result to the data varibale
  data <- dbGetQuery(con, query)
  
  # Combine the data with the existing results
  combined_data <- bind_rows(combined_data, data)
}

# Close the database connection
dbDisconnect(con)

######## DATA MANAGEMENT #######
# Merge MS SQL with SQLite data to use by shiny for data visualization
df1 <- merge(x = combined_data, y = data_sql, by = c("PlateID", "Row_Number", "Column_Number", "FileName"))

# Trim all white space on the column named drugs and convert values to uppercase
df1$Drugs = toupper(trimws(df1$Drugs, which = "both"))

# Rename any value in the bacteria column with W/OBACTERIA 
df1$Bacteria[df1$Bacteria == "W/OBACTERIA"] = "W/O BACTERIA"

# Create FileBacteria using FileName to extract only bacteria name
df1$FileBacteria = gsub("^([^-]*-[^-]*)-.*$", "\\1", df1$FileName)

# Convert all reduced values to numeric to be used as raw values on y-axis of plots
df1$ReducedValue = as.numeric(df1$ReducedValue)

# Remove DAY from Runday column and replace all with an empty string
df1$RunDay = gsub("DAY", "", toupper(df1$RunDay))

# Convert RunDay values to numeric and to an ordered factor
df1$RunDay = factor(as.numeric(df1$RunDay), ordered = T)

# Drop anything after the last underscore of the string from the FileRunDate
splitDate <- strsplit(gsub('(.*)-\\w+', '\\1', df1$FileRunDate), "-", fixed = TRUE)

# Save all the dates from the splitDate variable to the new Date column using tail function to select only date
df1$Date = lapply(splitDate,FUN=function(x){tail(x,1)})

# Convert all DrugConcentration represented by whitespace, empty string or NA to a No Concentration to be used on the user interphase 
df1$DrugConcentration[df1$DrugConcentration == "" | df1$DrugConcentration == " " | df1$DrugConcentration == "NA" | is.na(df1$DrugConcentration) | is.null(df1$DrugConcentration)] = "No Conc"

# Save cleaned data as RDS file to be used on the shiny UI by users
saveRDS(df1,"merged_data.RDS")