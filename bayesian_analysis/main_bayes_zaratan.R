# library(brms)
library(pracma)

## Bayesian Model
data = readRDS('./data_brms.RDS')

run_model_prior <- function(md, data, seed = 1, iter_prior = 100, warmup_prior = 10, chains = 4, cores = 16){
  command_prior = sprintf('tomodpriors = brm(%s, data = data,chains = chains, iter = iter_prior, warmup = warmup_prior, seed = seed, cores = cores)', md)   
  print(command_prior)
  eval(parse(text = command_prior))
  
  
  #extract list of default priors to then modify as desired
  mypriors <- prior_summary(tomodpriors)
  mypriors
  
  #setting priors:
  mypriors[dim(mypriors)[1],1] <- sprintf("cauchy(0,%.2f)", std(data$graymatter)) #set residual prior to half cauchy with scale matching sd of zgretmatter
  mypriors[mypriors$class=="sd",1] <- "" #weakly informative variance/covariance as per Chen et al. 2019
  
  output = list()
  output$model = md
  output$mypriors = mypriors
  output$data = data
  output$chains = chains
  return(output)
}
run_model = function(temp,iter=4000,warmup= 1000, ...){
  tic()
  command <- sprintf('result = brm(%s, control = list(adapt_delta = 0.99), prior = temp$mypriors, data = temp$data, chains = temp$chains, iter = iter, warmup = warmup, ...)', temp$model)
  eval(parse(text = command))
  result$elapsetime = toc()
  return(result)
}




# subID = unique(data$ID)
# idx = sample(1:length(subID),50,replace = F)
# subID_50 = subID[idx]
# data_50 = data[data$ID %in% subID_50,]


md = "graymatter~ scale(RAVLT_tot) + scale(Age_yrs)  + Gender + BMI + scale(walk_pace) + scale(Education_yrs) +  scale(EstimatedTotalIntraCranialVol) + \
                          (1 + scale(RAVLT_tot) + scale(Age_yrs)  + Gender + BMI + scale(walk_pace) + scale(Education_yrs) +  scale(EstimatedTotalIntraCranialVol) | regionlvl2b/regionlvl1b) + \
                          (1 | ID)"
temp = run_model_prior(md, data = data)
result = run_model(temp, cores = 16, threads = threading(1), file = './result_RAVLT_R10.rds')


