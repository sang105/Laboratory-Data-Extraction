# Laboratory-Data-Extraction
Laboratory-Data-Extraction is a repository that contains R scripts made to connect to two different databases for laboratory data extraction. The resulting data is used to assess the quality of data being produced from the lab daily. The R script is programmed to run as a cron job to ensure that data being processed contains the most recent data added by the laboratory staff.

The above code however will not give the desired results as illustrated in the script when cloned. This is due to the fact that data confidentiality is being maintained and database credentials cannot be shared. The database credentials for the script are generated from a config.yml file which has all the necessary credentials for a successful database connection to be established.
