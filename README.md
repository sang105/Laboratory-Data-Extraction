# Laboratory-Data-Extraction
Laboratory-Data-Extraction is a repository that contains R scripts made to connect to two different databases for laboratory data extraction. The resulting data is used to assess the quality of data being produced from the lab daily. The R script is programmed to run as a cron job to ensure that data being processed contains the most recent data added by the laboratory staff.

The above code however, will not give the desired results as illustrated in the script when cloned. This is because I am complying to the data protection law of MRCG@LSHTM and the general data protection regulation (GDPR). For these reason, database connection credentials were not disclosed. 
The database credentials for the script are invoked from a config.yml file which has all the necessary credentials (server name,username, password, and database name) for a successful database connection to be established.
