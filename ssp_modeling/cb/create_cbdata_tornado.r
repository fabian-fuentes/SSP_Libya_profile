
#read all folders 
 dir.data <- "/Users/edmun/Library/CloudStorage/OneDrive-Personal/Edmundo-ITESM/3.Proyectos/59. Lousiana Project/LA_CaseStudy/simulations raw/lousiana_cb_strategias/"
 files_table <- data.frame(file_name=list.dirs(path = dir.data, full.names = FALSE, recursive = FALSE))
 split_names <- do.call(rbind, strsplit(as.character(files_table$file_name), "_"))
 files_table$primary_id <- as.numeric(split_names[,2])


#now lets read inside each folder 
target_cb_file <- "cost_benefit_results_"

#we need to read the time_series one., or not maybe 


cb_data_all <- list()
for (i in 1:nrow(files_table))
{ 
#read cb data 
# i <- 60
 cb_data <-read.csv(paste0(dir.data,"cb_",files_table$primary_id[i],"/", target_cb_file,files_table$primary_id[i],".csv"))
 cb_data$primary_id <- files_table$primary_id[i]
 #merge both  
 cb_data_all <- append(cb_data_all,list(cb_data))
}
cb_data_all <- do.call("rbind",cb_data_all)
cb_chars <- data.frame(do.call(rbind, strsplit(as.character(cb_data_all$variable), ":")))
colnames(cb_chars) <- c("name","sector","cb_type","item_1","item_2")

cb_chars$cb_type_new <- cb_chars$cb_type
cb_chars$cb_type_new <- ifelse(grepl("technical_cost",cb_chars$cb_type)==TRUE & grepl("capex",cb_chars$item_2)==TRUE, "technical_cost_capex",cb_chars$cb_type_new)
cb_chars$cb_type_new <- ifelse(grepl("technical_cost",cb_chars$cb_type)==TRUE & grepl("opex",cb_chars$item_2)==TRUE, "technical_cost_opex",cb_chars$cb_type_new)
cb_chars$cb_type <- cb_chars$cb_type_new
cb_chars$cb_type_new <- NULL 
cb_chars$cb_type <- ifelse(cb_chars$cb_type=="technical_cost","technical_cost_capex",cb_chars$cb_type)
dim(cb_data_all)
dim(cb_chars)
cb_data_all <- cbind(cb_data_all,cb_chars)

#aggregate results 
#by sector
 cb_data1 <- aggregate(list(value=cb_data_all$value),list(primary_id=cb_data_all$primary_id,sector=cb_data_all$sector,time_period=cb_data_all$time_period),sum)
 cb_data1$value <- cb_data1$value/1e6
 cb_data1 <- reshape2::dcast(cb_data1, formula = primary_id + time_period ~ sector , value.var = "value")
 colnames(cb_data1) <- c(c("primary_id","time_period"),paste0(subset(colnames(cb_data1),!(colnames(cb_data1)%in%c("primary_id","time_period"))),"_cb"))
 cb_data1[is.na(cb_data1)] <- 0

#by item 
 cb_data2 <- aggregate(list(value=cb_data_all$value),list(primary_id=cb_data_all$primary_id,cb_type=cb_data_all$cb_type,time_period=cb_data_all$time_period),sum)
 cb_data2$value <- cb_data2$value/1e6
 cb_data2 <- reshape2::dcast(cb_data2, formula = primary_id + time_period ~ cb_type, value.var = "value")
 cb_data2[is.na(cb_data2)] <- 0
#merge both  
 dim(cb_data1)
 dim(cb_data2)
 cb_data_all <- merge(cb_data1,cb_data2)
 dim(cb_data_all)

cb_data_all$Direct_Benefit <- rowSums(cb_data_all[,c("technical_savings","fuel_cost" ,"crop_value","lvst_value","ippu_value")]) 
cb_data_all$Indirect_Benefit <- rowSums(cb_data_all[,c( "air_pollution","congestion","ecosystem_services","env_pollution","land_pollution","road_safety","water_pollution","consumer_savings")]) 

  #write this file 
dir.out  <- "/Users/edmun/Library/CloudStorage/OneDrive-Personal/Edmundo-ITESM/3.Proyectos/59. Lousiana Project/LA_CaseStudy/Tableau/2025_07_09/"
write.csv(cb_data_all,paste0(dir.out,"cb_data.csv"),row.names=FALSE)

