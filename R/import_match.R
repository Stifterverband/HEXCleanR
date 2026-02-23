#' import_matching_data
#'
#' @export

#This function is used to add/import matching data to be added to data_UNI.rds
#in order to create db_UNI.rds


###
#import_matching_data----------------------------------------------------------

import_matching_data <- function(add_to_this_file,
                                 name_folder = NULL,
                                 collect_matching_data_from_sharepoint = TRUE,
                                 DEV_ONLY_adding_by_rds = FALSE){

  ###Setup path where matching data is found. Find matching info.
    if(collect_matching_data_from_sharepoint == TRUE){
      #Check sharepoint connection
      sharepoint_connection_checker()
      
      #Matching data found in:
      base_link <- "//stifterverband.sharepoint.com@SSL/DavWWWRoot/sites/Dateiablage/SVDaten/Abteilungen/PuF/HEX/Scraping/data/single_universities"
      folder_path <- paste(base_link, name_folder, "Matching", sep = "/")

      ###Find all matching files and their info (ranked by most recent; so most recent matching is in first row)
      df_matching_info <- check_matching_files(name_folder, return_all_matching_info = TRUE)

    }else{
      #Matching data found in:
      folder_path <- "Matching"
      
      ###Find all matching files and their info (ranked by most recent; so most recent matching is in first row)
      df_matching_info <- check_matching_files("Matching", return_all_matching_info = TRUE)
      
    }
  
  ###Allow adding to .rds in DEV-Mode. Default is adding to dataframe from data_prep.R script
    if(DEV_ONLY_adding_by_rds == TRUE){
      df_add <- readRDS(add_to_this_file)
    }else{
      df_add <- add_to_this_file
    }
  
  ###Collect most recent matching info (df ranked by most recent; so most recent matching is in first row)
     matching_info <- df_matching_info[1,]
    
  ###Store most recent matching file in environment
    if(nrow(df_matching_info) > 0){
      path_to_most_recent_matching_file <- paste(folder_path, matching_info$name_of_matching_file, sep = "/")
      df_most_recent_matching_file <- readRDS(path_to_most_recent_matching_file)
      
        #TEMPORARY STOP IF MATCHING FILE NOT YET LUF-OPTMISED
        if("gerit_luf" %in% names(df_most_recent_matching_file)){
      
          #Subset
          df_matched <- df_most_recent_matching_file[,c("match_type","organisation_names_for_matching_back",
                                          "gerit_luf","gerit_studienbereich","gerit_faechergruppe",
                                          "LUF_code","STUB_code","FG_code")]
          #change colnames
          colnames(df_matched) <- c("matchingart","organisation_names_for_matching_back",
                                   "lehr_und_forschungsbereich","studienbereich","faechergruppe",
                                   "luf_code","stub_code","fg_code")
        }else{
          return(df_add)
          stop("Matching-Daten sind noch nicht LUF-optimiert. 
                Es konnten keine Matching-Daten angespielt werden.
                Dataframe wird genauso ausgegeben wie er eingegeben wurde.")
        }
      
    }else{
      return(df_add)
      stop("Es konnten keine Matching Daten gefunden werden.
            Dataframe wird genauso ausgegeben wie er eingegeben wurde.")
    }
    
  ###Find most recent scraped year and semester in df_add
    df_to_find_semester <- df_add
    
    #convert all colnames of db_data_scraped to low cap as well as argument variable_name_for_semester_in_rds
    colnames(df_to_find_semester) <- tolower(colnames(df_to_find_semester))

    #Convert jahr to numeric
    df_to_find_semester$jahr_numeric <- as.numeric(df_to_find_semester$jahr)
    
    #Find most recent year
    most_recent_scraped_year <- max(df_to_find_semester$jahr_numeric)
    
    #Find most recent semester
    semester_in_most_recent_year <- 
      unique(df_to_find_semester$semester[df_to_find_semester$jahr_numeric == most_recent_scraped_year]) 

      semester_in_most_recent_year_cleaned <- c()
      for(i in 1:length(semester_in_most_recent_year)){
        semester_in_most_recent_year_cleaned <- c(semester_in_most_recent_year_cleaned, semestercleaner(semester_in_most_recent_year[i]))
      }
      
      if("w" %in% semester_in_most_recent_year_cleaned){
        most_recent_scraped_semester <- "w"
        }else{
        most_recent_scraped_semester <- "s"
      }
      
  ###Check and warnings
    #Message for user:
      message(paste("Die gescrapten Daten gehen bis",most_recent_scraped_semester,most_recent_scraped_year,".",
                    "Die gematcheden Daten geben bis",matching_info$semester_in_latest_year,matching_info$latest_year,"." ))

    #Check iteration of matching
      if(matching_info$matching_coding %in% c("erstkodierung","zweitkodierung")){
        warning("Die Daten wurden noch nicht zweitkodiert und zusammengeführt. Sicher,
                dass du das Matching anspielen willst?")
      }
    
  ###Add mehrere organisationen back to organisation column (only necessary for old cleaning standard) 
      if("organisation_mehrere" %in% colnames(df_add)){
        df_add$organisation <- ifelse(df_add$organisation == "MEHRERE ORGANISATIONEN", 
                                      df_add$organisation_mehrere, df_add$organisation)
      }
      
  ###Trim white spaces in organisation names in matching file as well as db_data file so matching
    #data can be added irrespective of the presence of (newly added) trailing or leading white
    #spaces
      df_matched$organisation_trimmed_white_spaces <- 
        as.character(sapply(df_matched$organisation_names_for_matching_back, function(x) {
        paste(trimws(unlist(strsplit(x, " ; "))), collapse = " ; ")
      }))
      
        #Remove rows with duplicated df_matched$organisation_trimmed_white_spaces
        df_matched_sans_duplicated <- df_matched[!duplicated(df_matched$organisation_trimmed_white_spaces),]
      
      df_add$organisation_trimmed_white_spaces <- 
        as.character(sapply(df_add$organisation, function(x) {
        paste(trimws(unlist(strsplit(x, " ; "))), collapse = " ; ")
      }))
      
      
  ###Add matching info to dataframe
    
    #Remove matching columns from df_add to add back in the step below
      cols_to_remove <- c("lehr_und_forschungsbereich","studienbereich","faechergruppe",
                            "luf_code","stub_code","fg_code","matchingart")
      
      df_add_cols_removed <- df_add[,!names(df_add) %in% cols_to_remove]
      
    #Remove rows with match_type "not_matchable" (for now)
      df_matched_sans_not_matchable <- df_matched_sans_duplicated[df_matched_sans_duplicated$matchingart != "not_matchable",] 

    #Merge matching file with scraped data
      df_merged <- merge(df_add_cols_removed, df_matched_sans_not_matchable, 
                         by.x = "organisation_trimmed_white_spaces", 
                         by.y = "organisation_trimmed_white_spaces",
                         all.x = TRUE)
      
    #Remove helper variables "organisation_trimmed_white_spaces" and "organisation_names_for_matching_back"
      df_merged <- subset(df_merged, select = -c(organisation_trimmed_white_spaces,
                                             organisation_names_for_matching_back))
      
    #Message
      message("Matching Daten erfolgreich angespielt.")
      
  ###Return merged dataframe
      return(df_merged)

}