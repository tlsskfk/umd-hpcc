library(tidyverse)
library(brms)
library(pracma)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


## functions 

W.str_selectbetweenpattern <- function(str, s1, s2, n1, n2){
  require(stringr)
  if (is.null(s1)){
    i1 = c(0,0)
  }else {
    i1 = str_locate_all(str, fixed(s1))
    if (n1 < 0){
      n1 = dim(i1[[1]])[1] + 1 + n1
    }
    if (dim(i1[[1]])[1] == 0){
      return(str)
    }
    i1 = i1[[1]][n1,]
  }
  if (is.null(s2)){
    i2 = c(str_length(str)+1, str_length(str)+1)
  } else{
    i2 = str_locate_all(str, fixed(s2))
    if (n2 < 0){
      n2 = dim(i2[[1]])[1] + 1 + n2
    }
    if (dim(i2[[1]])[1] == 0){
      return(str)
    }
    i2 = i2[[1]][n2,]
  }
  out = substr(str, i1[2]+1, i2[1]-1)
  return(out)
}


W.strs_selectbetweenpattern <- function(strs, s1, s2, n1, n2){
  require(pracma)
  out = arrayfun(function(x)W.str_selectbetweenpattern(x,s1,s2,n1,n2), strs)
  return(out)
}


# ## load raw data
dataraw = read.csv("./Master_CSV_aging_neural.csv")


## extract data and change data names
# brain volume
data_vol = dataraw %>%
  select("ID", "Left.Thalamus.Proper", "Left.Caudate", "Left.Putamen", "Left.Pallidum","Left.Hippocampus",
         "Left.Amygdala","Left.Accumbens.area","Left.VentralDC",
         "Right.Thalamus.Proper", "Right.Caudate","Right.Putamen","Right.Pallidum",
         "Right.Hippocampus","Right.Amygdala","Right.Accumbens.area","Right.VentralDC")
cnames = names(data_vol)
cnames = paste(gsub("Left.", "lh_", cnames), "subcortical", sep = '_')
cnames = gsub("Right.", "rh_", cnames)
cnames[1] = "ID"
colnames(data_vol) = cnames

# thickness
data_thick = dataraw[,c(2,5,6,7,16,22,23,46,112,113:183)]
data_thick = data_thick %>%
  select(-"Subjects", -"rh_MeanThickness_thickness", -"lh_MeanThickness_thickness")

data_thick = data_thick %>% 
  mutate(log_trail_b = log10(trail_b_thresh_180)) %>%
  select(1:7, log_trail_b, everything())

## remove "_thickness"
names = gsub("_thickness", "", names(data_thick))

# add level2

# Frontal
# Superior Frontal
# Rostral and Caudal Middle Frontal
# Pars Opercularis, Pars Triangularis, and Pars Orbitalis
# Lateral and Medial Orbitofrontal
# Precentral
# Paracentral
# Frontal Pole
# Rostral Anterior (Frontal)
# Caudal Anterior (Frontal)

subnames_frontal <- c('frontal','pars','precentral', 'paracentral',
                      'rostralanteriorcingulate','caudalanteriorcingulate','insula')
sub_ind_fontal <- grep(paste(subnames_frontal, collapse ='|'), names, ignore.case = TRUE)
names[sub_ind_fontal] = paste(names[sub_ind_fontal], "frontal", sep = '_')


# Parietal
# Superior Parietal
# Inferior Parietal
# Supramarginal
# Postcentral
# Precuneus
# Posterior (Parietal)
# Isthmus (Parieta

subnames_parietal <- c('superiorparietal','inferiorparietal','supramarginal', 'postcentral','precuneus',
                       'posteriorcingulate','isthmuscingulate')
sub_ind_parietal <- grep(paste(subnames_parietal, collapse ='|'), names, ignore.case = TRUE)
names[sub_ind_parietal] = paste(names[sub_ind_parietal], "parietal", sep = '_')


# Temporal
# Superior, Middle, and Inferior Temporal
# Banks of the Superior Temporal Sulcus
# Fusiform
# Transverse Temporal
# Entorhinal
# Temporal Pole
# Parahippocampal
subnames_temporal <- c('temporal', 'bankssts','fusiform','entorhinal','parahippocampal')
sub_ind_temporal <- grep(paste(subnames_temporal, collapse ='|'), names, ignore.case = TRUE)
names[sub_ind_temporal] = paste(names[sub_ind_temporal], "temporal", sep = '_')


# Occipital
# Lateral Occipital
# Lingual
# Cuneus
# Pericalcarine
subnames_occipital <- c('occipital','lingual','cuneus','pericalcarine')
sub_ind_occipital <- grep(paste(subnames_occipital, collapse ='|'), names, ignore.case = TRUE)
names[sub_ind_occipital] = paste(names[sub_ind_occipital], "occipital", sep = '_')



colnames(data_thick) = names


# merge two dataset
data_wide = merge(data_thick,data_vol, by = "ID")

# remove NAs in 2-min
idx = !is.na(data_wide$log_trail_b) & !is.na(data_wide$X2_min) & !is.na(data_wide$walk_pace) & !is.infinite(data_wide$log_trail_b)
data_wide = data_wide[idx,]


# normalize cols
data_wide[,c(2,4:dim(data_wide)[2])] =  scale(data_wide[,c(2,4:dim(data_wide)[2])])
write.csv(data_wide,"./data_wide_log_trail_b.csv") 

# transfer from wide to long
data_long = data_wide %>%
  pivot_longer(cols = lh_bankssts_temporal:rh_VentralDC_subcortical,
               names_to = "regions", values_to = "zgraymatter")

data_long$hemisphere = W.strs_selectbetweenpattern(data_long$regions, NULL, '_',1,1)
data_long$regionlvl1 = W.strs_selectbetweenpattern(data_long$regions, '_', '_',1,-1)
data_long$regionlvl2 = W.strs_selectbetweenpattern(data_long$regions, '_', NULL,-1,1)

write.csv(data_long, "./data_long_log_trail_b.csv")


###########################################################################
## load data
# data_200 = data_wide
# ## half participantes
# idx = sample(1:dim(data_200)[1],200,replace = F)
# 
# data_200 = data_wide[idx,]
# 
# data_200l = data_200 %>%
#   pivot_longer(cols = lh_bankssts_temporal:rh_VentralDC_subcortical,
#                names_to = "regions", values_to = "zgraymatter")
# 
# data_200l$hemisphere = W.strs_selectbetweenpattern(data_200l$regions, NULL, '_',1,1)
# data_200l$regionlvl1 = W.strs_selectbetweenpattern(data_200l$regions, '_', '_',1,-1)
# data_200l$regionlvl2 = W.strs_selectbetweenpattern(data_200l$regions, '_', NULL,-1,1)


data = data_long


# factorize variables 
{
  data$regionlvl1 <- as.factor(data$regionlvl1)
  contrasts(data$regionlvl1) <- "contr.sum"
  
  data$regionlvl2 <- as.factor(data$regionlvl2)
  contrasts(data$regionlvl2) <- "contr.sum"
  
  data$hemisphere <- as.factor( data$hemisphere)
  contrasts( data$hemisphere) <- "contr.sum"
  
  data$Gender <- as.factor( data$Gender)
  contrasts( data$Gender) <- "contr.sum"
}


## Bayesian Model
library(brms)

tomodpriors <- brm(zgraymatter~ X2_min * Age_yrs * log_trail_b + EstimatedTotalIntraCranialVol + Gender + BMI + walk_pace + Education_yrs +
                     (1 + X2_min * Age_yrs* log_trail_b + EstimatedTotalIntraCranialVol + Gender + BMI + walk_pace + Education_yrs | regionlvl2/regionlvl1 ) +
                     (1 | ID),
                   data=data,chains=4,iter=100,warmup=10,cores=4,seed=1213)

#extract list of default priors to then modify as desired
mypriors <- prior_summary(tomodpriors)
mypriors


#setting priors:
mypriors[dim(mypriors)[1],1] <- "cauchy(0,.051)" #set residual prior to half cauchy with scale matching sd of hreg, per Chen et al. 2019: .077 for 20th, .051 for mean
mypriors[mypriors$class=="sd",1] <- "normal(0,1)" #weakly informative variance/covariance as per Chen et al. 2019

# run model wirh prior
x2min_log_trail_b_level2in1_full <-brm(zgraymatter~ X2_min * Age_yrs * log_trail_b + EstimatedTotalIntraCranialVol + Gender + BMI + walk_pace + Education_yrs +
                                   (1 + X2_min * Age_yrs * log_trail_b + EstimatedTotalIntraCranialVol + Gender + BMI + walk_pace + Education_yrs | regionlvl2/regionlvl1 ) +
                                   (1 | ID),
                                 control = list(adapt_delta = 0.99),
                                 prior = mypriors,
                                 data=data,chains=4,iter=4000,warmup= 1000,cores=4,seed=1213, file = "./x2min_log_trail_b_lvl2in1_full.rds")



#########################################  FIGURE  ###########################################

library(tidybayes)
library(dplyr)
library(tidyverse)
library(ggplot2)


############################## interaction effect #############################################
x2min_log_trail_b_level2in1_full <-x2min_RAVLT_level2in1_full
m1 = x2min_RAVLT_level2in1_full
######## level 2 region#######

result1 <-  m1 %>%
  spread_draws(`b_X2_min:Age_yrs:log_trail_b`, `r_regionlvl2`[ROI,term]) %>%
  mutate(condition_mean = `b_X2_min:Age_yrs:log_trail_b` + `r_regionlvl2`)

result1[result1$term=="X2_min:Age_yrs:log_trail_b",]  %>%
  ggplot(aes(y = ROI, x = condition_mean)) +
  stat_halfeye() + geom_vline(xintercept = c(0), linetype = "dashed")


#and results to print for Excel, e.g, "effect size", credible intervals...:
hold <- result1[result1$term=="X2_min:Age_yrs:log_trail_b",]  %>%
  median_qi(condition_mean,.width=c(.9,.95))

##SAME AS ABOVE BUT SORT BY EVIDENCE INSTEAD OF ALPHABETICALLY
hold <- result1[result1$term=="X2_min:Age_yrs:log_trail_b",] 
my_pvalues <- as.data.frame(matrix(NA, nrow = length(unique(hold$ROI)), ncol = 2))
my_signs <- aggregate(data=hold, FUN=median, condition_mean ~ ROI)
my_signs$sign <- sign(my_signs$condition_mean)
my_signs$condition_mean <- NULL
hold <- merge(hold, my_signs, by="ROI")
hold$signed <- hold$condition_mean*hold$sign

colnames(my_pvalues) <- c("ROI","pvalue")
for (i in 1:length(unique(hold$ROI))){
  my_pvalues[i,1] <- as.character(unique(hold$ROI)[i])
  my_pvalues[i,2] <- length(subset(hold, ROI == unique(hold$ROI)[i] & condition_mean > 0)$condition_mean)/length(subset(hold, ROI == unique(hold$ROI)[i])$condition_mean)
}
my_pvalues  <- my_pvalues[order(my_pvalues$pvalue,decreasing=FALSE),]
# my_pvalues[my_pvalues$pvalue > .15 & my_pvalues$pvalue < .85,]$pvalue <- "NA" #this will be used to make anything with evidence less than 15% gray
my_pvalues$pvalue <- as.numeric(my_pvalues$pvalue)
hold$ROI <- factor(hold$ROI,levels=my_pvalues$ROI)
hold <- merge(hold,my_pvalues,by="ROI")

myplot <- hold  %>%
  arrange(condition_mean) %>%
  ggplot(aes(y = ROI, x = condition_mean, fill = pvalue)) +
  stat_halfeye(.width=c(.9,.95)) +
  geom_vline(xintercept = c(0), linetype = "dashed") +
  scale_fill_viridis_c(option="H", direction = -1, limits=c(0,1), breaks=c(1,.85,.15,0), values=c(1,.85,.15,0), na.value="lightgrey",
                       guide = guide_colorbar(reverse=FALSE, barheight = unit(8,"cm"))) +
  labs(title = "X2_min:Age_yrs:log_trail_b(level2)") +
  # coord_cartesian(xlim = c(-0.01, 0.01)) +
  theme(axis.title = element_text(size=16), 
        plot.title = element_text(size=16),
        axis.text = element_text(size = 12, colour = "black"))
ggsave("../figure/X2_min_Age_yrs_log_trail_b_level2.png",dpi = "retina", width = 2337, height = 1653*1.5, units = "px",bg = "white")
# write.csv(my_pvalues,"../pvalue/pvalues_top_20_age_differences_between_rest_ex.csv")
myplot 


######## level 1 #######

result1_1 <- m1%>%
  spread_draws(`b_X2_min:Age_yrs:log_trail_b`, `r_regionlvl2`[ROI2,term],`r_regionlvl2:regionlvl1`[ROI1,term]) 

result1_1 <- result1_1 %>%
  mutate(condition_mean = `b_X2_min:Age_yrs:log_trail_b` + `r_regionlvl2` + `r_regionlvl2:regionlvl1`)


#now a bunch of work to get only the rows where the higher-level parcel is the same as the lower-level:
result1_1$labellength <- nchar(result1_1$ROI2)
result1_1$doesitmatch <- substr(result1_1$ROI1,1,result1_1$labellength)
result1_1$match <- 0
result1_1[result1_1$ROI2==result1_1$doesitmatch,]$match <- 1
result1_1 <- subset(result1_1, match == 1)

result1_1[result1_1$term=="X2_min:Age_yrs:log_trail_b",]  %>%
  ggplot(aes(y = ROI1, x = condition_mean)) +
  stat_halfeye(.width=c(.9,.95)) + geom_vline(xintercept = c(0), linetype = "dashed")

#and results to print for Excel, etc.:
result1_1[result1_1$term=="X2_min:Age_yrs:log_trail_b",]  %>%
  median_qi(condition_mean,.width=c(.9,.95)) -> hold

##SAME AS ABOVE BUT SORT BY EVIDENCE INSTEAD OF ALPHABETICALLY
hold <- result1_1[result1_1$term=="X2_min:Age_yrs:log_trail_b",] 
my_pvalues <- as.data.frame(matrix(NA, nrow = length(unique(hold$ROI1)), ncol = 2))

colnames(my_pvalues) <- c("ROI1","pvalue")
for (i in 1:length(unique(hold$ROI1))){
  my_pvalues[i,1] <- as.character(unique(hold$ROI1)[i])
  my_pvalues[i,2] <- length(subset(hold, ROI1 == unique(hold$ROI1)[i] & condition_mean > 0)$condition_mean)/length(subset(hold, ROI1 == unique(hold$ROI1)[i])$condition_mean)
}
my_pvalues  <- my_pvalues[order(my_pvalues$pvalue,decreasing=FALSE),]
# my_pvalues[my_pvalues$pvalue > .15 & my_pvalues$pvalue < .85,]$pvalue <- "NA" #this will be used to make anything with evidence less than 15% gray
my_pvalues$pvalue <- as.numeric(my_pvalues$pvalue)
hold$ROI1 <- factor(hold$ROI1,levels=my_pvalues$ROI1)
hold <- merge(hold,my_pvalues,by="ROI1")

myplot <- hold  %>%
  arrange(condition_mean) %>%
  ggplot(aes(y = ROI1, x = condition_mean, fill = pvalue)) +
  stat_halfeye(.width=c(.9,.95)) +
  geom_vline(xintercept = c(0), linetype = "dashed") +
  scale_fill_viridis_c(option="H", direction = -1, limits=c(0,1), breaks=c(1,.85,.15,0), values=c(1,.85,.15,0), na.value = "lightgrey",
                       guide = guide_colorbar(reverse=FALSE, barheight = unit(8,"cm"), draw.ulim = F,draw.llim = F)) +
  labs(title = "X2_min:Age_yrs:log_trail_b (level1)")+
  # coord_cartesian(xlim = c(-0.01, 0.01)) +
  theme(axis.title = element_text(size=12), 
        plot.title = element_text(size=12),
        axis.text = element_text(size = 12, colour = "black"))
# write.csv(my_pvalues,"../pvalue/top_age_differences_between_rest_ex_2.csv")
ggsave("../figure/X2_min_Age_yrs_log_trail_b_level1.png", dpi = "retina", width = 2337*1.2, height = 1653*4, units = "px",bg = "white")
myplot 
################----------------------___########################
library(ggplot2)
library(ggpubr)
library(ggdist)
library(cowplot)
## set theme
theme_set(theme_tidybayes() + panel_border())

mydata = dat_long
dt_mdl = m1


plot_3way_interaction_RAVLT <- function(region_level2, region_level1){
  conditions <- make_conditions(dt_mdl,"X2_min")
  conditions$regionlvl2 = region_level2
  conditions$regionlvl1 = region_level1
  plot(conditional_effects(x = dt_mdl, effects = "Age_yrs:RAVLT_tot", conditions = conditions, re_formula = NULL, prob = 0.7), line_args = list(se = F))[[1]] +
    labs(x= "zAge_yrs", y = "zgraymatter", title = sprintf("%s_%s",region_level2, region_level1)) + 
    geom_rug(sides = "b", inherit.aes = FALSE, data = aggregate(data = mydata, FUN=mean, zgraymatter ~ ID * Age_yrs),
             aes(x = Age_yrs, y = zgraymatter), alpha = 0.5, position = position_jitter(width=0.3,height=0)) +
    theme(axis.title = element_text(size=10), 
          plot.title = element_text(size=10, hjust = 0.5),
          strip.text.x = element_text(size = 10),
          axis.text = element_text(size = 10, colour = "black"))
  fpath = sprintf("../figure/3way_interaction/%s_%s.png", region_level2, region_level1) 
  ggsave(fpath, dpi = "retina", width = 8, height = 4, units = "in")
  
}





plot_3way_interaction_RAVLT("parietal", "superiorparietal")
plot_3way_interaction_RAVLT("parietal", "inferiorparietal")
plot_3way_interaction_RAVLT("parietal", "posteriorcingulate")
plot_3way_interaction_RAVLT("parietal", "postcentral")





conditions <- make_conditions(dt_mdl,"X2_min")
conditions$regionlvl2 = "parietal"

plot(conditional_effects(x = dt_mdl, effects = "Age_yrs:RAVLT_tot", conditions = conditions, re_formula = NULL, prob = 0.7), line_args = list(se = F))[[1]] +
  labs(x= "zAge_yrs", y = "zgraymatter", title = sprintf("%s","parietal")) + 
  geom_rug(sides = "b", inherit.aes = FALSE, data = aggregate(data = mydata, FUN=mean, zgraymatter ~ ID * Age_yrs),
           aes(x = Age_yrs, y = zgraymatter), alpha = 0.5, position = position_jitter(width=0.3,height=0)) +
  theme(axis.title = element_text(size=10), 
        plot.title = element_text(size=10, hjust = 0.5),
        strip.text.x = element_text(size = 10),
        axis.text = element_text(size = 10, colour = "black"))
fpath = sprintf("../figure/3way_interaction/%s.png", "parietal") 
ggsave(fpath, dpi = "retina", width = 8, height = 4, units = "in")


