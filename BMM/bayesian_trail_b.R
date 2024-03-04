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
                                 data=data,chains=16,iter=4000,warmup= 1000,cores=16,seed=1213, file = "./x2min_log_trail_b_lvl2in1_full.rds")
