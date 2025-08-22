
#read tornado plot data table 
root<- "/Users/edmun/Library/CloudStorage/OneDrive-Personal/Edmundo-ITESM/3.Proyectos/59. Lousiana Project/LA_CaseStudy/"
dir.data <- paste0(root,"simulations raw/")
file.name <-"louisiana.csv"
data <- read.csv(paste0(root,"scaled_results/",file.name)) 


#filter subsector totals
data <- subset(data,region=="louisiana")
ids<-c("primary_id", "region", "time_period") 
subsector_totals <- subset(colnames(data),grepl("co2e_subsector_total",colnames(data))==TRUE)

#create ch4 totals  
subsector_totals_ch4 <- c("emission_co2e_ch4_agrc",
                          "emission_co2e_ch4_ccsq",
                          "emission_co2e_ch4_entc",
                          "emission_co2e_ch4_fgtv",
                          "emission_co2e_ch4_frst",
                          "emission_co2e_ch4_inen",
                          "emission_co2e_ch4_ippu",
                          "emission_co2e_ch4_lsmm",
                          "emission_co2e_ch4_lvst",
                          "emission_co2e_ch4_scoe",
                          "emission_co2e_ch4_trns",
                          "emission_co2e_ch4_trww",
                          "emission_co2e_ch4_waso") 

for (i in 1:length(subsector_totals_ch4))
{
#i<-1
 vars <- subset(colnames(data),grepl(subsector_totals_ch4[i],colnames(data))==TRUE)   
 if (length(vars)>1)
 {
 data[,subsector_totals_ch4[i]] <- rowSums(data[,vars])
 } else 
 {
   data[,subsector_totals_ch4[i]] <- data[,vars]  
 }
}
data <- data[,c(ids,subsector_totals,subsector_totals_ch4)]
#estimate totals emissions
data$total_co2e <- rowSums(data[,subsector_totals])
data$total_co2e_ch4 <- rowSums(data[,subsector_totals_ch4])

#add att table 
atts <- read.csv(paste0(dir.data,"ATTRIBUTE_PRIMARY.csv")) 
dim(atts)
dim(data)
data <- merge(data,atts,by="primary_id")
dim(data)
#add strategy ID
sts <- read.csv(paste0(dir.data,"ATTRIBUTE_STRATEGY.csv")) 
dim(sts)
dim(data)
data <- merge(data,sts,by="strategy_id")
dim(data)
#add strategy name 
head(data)

#create sector column for action ID [
data$action_sector <- data.frame(do.call(rbind, strsplit(as.character(data$strategy), ":")))[,1]

#write tornado plot table 
dir.out <- paste0(root,"Tableau/2025_07_09/")
write.csv(data,paste0(dir.out,"tornado_plot_data.csv"),row.names=FALSE)

