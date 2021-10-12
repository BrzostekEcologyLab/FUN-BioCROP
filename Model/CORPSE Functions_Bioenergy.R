###Sulman's CORPSE-N code adapted from CORPSE_deriv.py

##Data frame with definitions of expected parameters 
params_definitions <- data.frame( 
  "Vmaxref" = as.character ('Relative maximum enzymatic decom rates (Fast, Slow, Necro)'), 
  "Ea" = as.character ('Activation engery (Fast, Slow, Necro)'),
  "kC" = as.character ('Michealis-Menton parameter (Fast, Slow, Necro)'),
  "gas_diffusion_exp" = as.character ('Determines suppression of decomp at high soil moisture'), 
  "minMicrobeC" = as.character ('Minimum microbial biomass (fraction of total C)'), 
  "Tmic"= as.character ('Microbial lifetime at 20C (years)'),
  "et" = as.character ('Fraction of turnover not converted to CO2'),
  "eup" = as.character ('Carbon uptake efficiency (Fast, Slow, Necro)'),
  "nup" = as.character ('Nitrogen uptake efficiency (Fast, Slow, Necro)'),
  "tProtected" = as.character ('Protected C turnover time (years)'), 
  "frac_N_turnover_min" = as.character ('Fraction of microbial biomass N turnover that is mineralized'), 
  "protection_rate" = as.character ('Protected carbon formation rate (year-1)'), 
  "CN_Microbe" = as.character ('C:N ratio of microbial biomass'), 
  "max_immobilization_rate" = as.character ('Maximum N immobilization rate (fraction per day)'),
  "substrate_diffusion_exp" = as.character ('Determines suppression of decomp at low soil moisture'),
  "frac_turnover_slow" = as.character('Fraction of microbial biomass N turnover that goes to slow pool'),
  "new_resp_units" = as.character ('If TRUE, Vmaxref has units of 1/years and assumes optimal soil moisture has a relative rate of 1.0'),
  "iN_loss_rate" = as.character ('Loss rate of inorganic N pool (year-1) > 1 because it takes much less than a year for it to be removed')
)



##3 pools
chem_types<-c('Fast','Slow','Necro')

##Protection rate parameter based on percent clay content from Mayes et al (2012) Table 1
prot_clay<- function (claypercent, slope=0.4833, intercept=2.3282, BD=1.15, porosity=0.4) {
  prot<-1.0*(10**(slope*log10(claypercent)+intercept)*BD*1e-6)
  return (prot)
}

##Calculate rates of change for ALL CORPSE pools 
##T = Temperature (Kelvin)
##Theta = soil water content (fraction of saturation)

##Next 3 functions are needed to run model code
##Functions are ordered to allow code to run

##Function to calculate Vmax of microbial decomposition 
##Vmax function, normalized to Tref=293.15 (T is in Kelvin)
Vmax<-function (T,params,Tref=293.15,Rugas=8.314472) {
  # Fast<-params$Vmaxref_Fast*exp(-params$Ea_Fast*(1.0/(Rugas*T)-1.0/(Rugas*Tref)))
  # Slow<-params$Vmaxref_Slow*exp(-params$Ea_Slow*(1.0/(Rugas*T)-1.0/(Rugas*Tref)))
  # Necro<-params$Vmaxref_Necro*exp(-params$Ea_Necro*(1.0/(Rugas*T)-1.0/(Rugas*Tref)))
  # Vmax<-data.frame(Fast,Slow,Necro)
  Vmax<-data.frame(params[paste('Vmaxref_',chem_types,sep='')]*exp(-params[paste('Ea_',chem_types,sep='')]*(1.0/(Rugas*T)-1.0/(Rugas*Tref))))
  names(Vmax)<-chem_types
  return(Vmax)
}

##Function to sum carbon types  
# sumCtypes<-function(SOM,prefix,suffix='C') {
#   out<-SOM[[paste(prefix,chem_types[1],suffix,sep='')]]
#   if (length(chem_types)>1){
#     for (i in 2:length(chem_types)) {
#       out<-out+SOM[[paste(prefix,chem_types[i],suffix,sep='')]]
#       
#     }
#   }
#   return(out)
# }
sumCtypes<-function(SOM,prefix,suffix='C') {
  return(rowSums(SOM[paste(prefix,chem_types,suffix,sep='')]))
}

##Function to calculate Decomposition rate 
decompRate<- function(SOM,T,theta,params){
  nsites<-length(SOM[,1])
  theta[theta<0]<-0.0
  theta[theta>1.0]<-1.0
  if (params$new_resp_units==TRUE) {
    theta_resp_max<-params$substrate_diffusion_exp/(params$gas_diffusion_exp*(1.0+params$substrate_diffusion_exp/params$gas_diffusion_exp))
    aerobic_max<-theta_resp_max**params$substrate_diffusion_exp*(1.0-theta_resp_max)**params$gas_diffusion_exp
  } else {
    aerobic_max<-1.0
  }
  vmax<-Vmax(T,params)
  eq_1<- theta**params$substrate_diffusion_exp
  eq_2 <- (1.0-theta)**params$gas_diffusion_exp/aerobic_max
  decompRate<-data.frame(matrix(,nrow=nsites,ncol=0))
  for (ctypes in chem_types) {
    drate<-vmax[[ctypes]]*eq_1*eq_2*(SOM[[paste('u',ctypes,'C',sep='')]]*SOM$livingMicrobeC/((sumCtypes(SOM,'u'))*params[[paste('kC',ctypes,sep='_')]]+SOM$livingMicrobeC))
    zeroMB=SOM$livingMicrobeC==0.0
    drate[zeroMB]<-0.0
    decompRate[paste(ctypes,'C',sep='')]<-drate
    NC_ratio<-SOM[[paste('u',ctypes,'N',sep='')]]/SOM[[paste('u',ctypes,'C', sep='')]]
    NC_ratio[SOM[[paste('u',ctypes,'C', sep='')]]==0.0]<-0.0
    decompRate[paste(ctypes,'N',sep='')]<- drate*NC_ratio
  }
  return (decompRate)
}


###This runs the functions for the bulk soil and rhizosphere which have the same parameters.  
CORPSE <- function(SOM,T,theta,params,claymod=1.0,Litter=FALSE) {
  nsites<-length(SOM[,1])
  CN_Microbe<-params$CN_Microbe
  ##Calculate maximum potential C decomposition rate
  decomp<-decompRate(SOM,T,theta,params)
  
  ##Microbial Turnover
  microbeTurnover<-(SOM$livingMicrobeC-params$minMicrobeC*sumCtypes(SOM,'u','C'))/params$Tmic ##kg/m2/yr
  microbeTurnover[microbeTurnover<0.0]<-0.0

  ##Calculating maintenance respiration and creating zeros matrix for overflow_resp
  maintenance_resp<-microbeTurnover*(1.0-params$et)
  overflow_resp<-maintenance_resp*0
  
  ##Calculating fraction dead microbes in C and N
  deadmic_C_production<-microbeTurnover*params$et ##actual fraction of microbial turnover
  deadmic_N_production<-(microbeTurnover*params$et)/(CN_Microbe)
  
  ##C and N available for microbial growth
  carbon_supply<-vector(mode='numeric', length=nsites)
  nitrogen_supply<-vector(mode='numeric', length=nsites)
  for (ctypes in chem_types) {
    carbon_supply<-carbon_supply+decomp[[paste(ctypes,'C',sep='')]]*params[[paste('eup',ctypes,sep='_')]]
    nitrogen_supply<-nitrogen_supply+decomp[[paste(ctypes,'N',sep='')]]*params[[paste('nup',ctypes,sep='_')]]
  }
  
  IMM_N_max<-params$max_immobilization_rate*365*SOM$inorganicN/(SOM$inorganicN+params$max_immobilization_rate)
  
  dmicrobeC<-vector(mode='numeric', length=nsites)
  dmicrobeN<-vector(mode='numeric', length=nsites)
  CN_imbalance_term<-vector(mode='numeric', length=nsites)
  
  ##Growth is nitrogen limited, with not enough mineral N to support it with max immobilization
  loc_Nlim<-(carbon_supply - maintenance_resp)>((nitrogen_supply+IMM_N_max)*CN_Microbe)
  CN_imbalance_term[loc_Nlim]<-(-IMM_N_max[loc_Nlim])
  dmicrobeC[loc_Nlim]<-((nitrogen_supply[loc_Nlim]+IMM_N_max[loc_Nlim])*CN_Microbe - microbeTurnover[loc_Nlim]*params$et)
  dmicrobeN[loc_Nlim]<-(nitrogen_supply[loc_Nlim]+IMM_N_max[loc_Nlim] - microbeTurnover[loc_Nlim]*params$et/CN_Microbe)
  overflow_resp[loc_Nlim]<-carbon_supply[loc_Nlim]-maintenance_resp[loc_Nlim] - (nitrogen_supply[loc_Nlim]+IMM_N_max[loc_Nlim])*CN_Microbe
  
  ##Growth must be supported by immobilization of some mineral nitrogen, but is ultimately carbon limited
  loc_immob<-(carbon_supply - maintenance_resp >= nitrogen_supply*CN_Microbe) & (carbon_supply - maintenance_resp < (nitrogen_supply+IMM_N_max)*CN_Microbe)
  CN_imbalance_term[loc_immob]<-(-((carbon_supply[loc_immob]-maintenance_resp[loc_immob])/CN_Microbe - nitrogen_supply[loc_immob]))
  dmicrobeC[loc_immob]<-(carbon_supply[loc_immob] - microbeTurnover[loc_immob])
  dmicrobeN[loc_immob]<-((carbon_supply[loc_immob]-maintenance_resp[loc_immob])/CN_Microbe - microbeTurnover[loc_immob]*params$et/CN_Microbe)
  
  ##Growth is carbon limited and extra N is mineralized
  loc_Clim<-!(loc_Nlim | loc_immob)
  dmicrobeC[loc_Clim]<-(carbon_supply[loc_Clim] - microbeTurnover[loc_Clim]) 
  dmicrobeN[loc_Clim]<-((carbon_supply[loc_Clim]-maintenance_resp[loc_Clim])/CN_Microbe - microbeTurnover[loc_Clim]*params$et/CN_Microbe)
  CN_imbalance_term[loc_Clim]<-nitrogen_supply[loc_Clim] - (carbon_supply[loc_Clim]-maintenance_resp[loc_Clim])/CN_Microbe
  
  ##CO2 production and cumulative CO2 produced by cohort
  CO2prod<-maintenance_resp+overflow_resp
  for (ctypes in chem_types) {
    CO2prod<-CO2prod+decomp[[paste(ctypes,'C',sep='')]]*(1.0-params[[paste('eup',ctypes,sep='_')]])
  }

  ##Update protected carbon 
  protectedturnover<-data.frame(matrix(,nrow=nsites,ncol=0))
  protectedprod<-data.frame(matrix(,nrow=nsites,ncol=0))
  
  for (ctypes in chem_types) {
    ## change protection rate to 0 if leaf litter
    if(Litter){
      params[[paste('protection_rate',ctypes,sep='_')]]<-0
    }
    protectedturnover[paste(ctypes,'C',sep='')]<-SOM[paste('p',ctypes,'C',sep='')]/params$tProtected
    protectedprod[paste(ctypes,'C',sep='')]<-SOM[paste('u',ctypes,'C',sep='')]*params[[paste('protection_rate',ctypes,sep='_')]]*claymod
    protectedturnover[paste(ctypes,'N',sep='')]<-SOM[paste('p',ctypes,'N',sep='')]/params$tProtected
    protectedprod[paste(ctypes,'N',sep='')]<-SOM[paste('u',ctypes,'N',sep='')]*params[[paste('protection_rate',ctypes,sep='_')]]*claymod
  }
  
  derivs<-SOM
  
  derivs$livingMicrobeC<-dmicrobeC
  derivs$livingMicrobeN<-dmicrobeN
  derivs$CO2<-CO2prod
  derivs$inorganicN<-CN_imbalance_term

  for (ctypes in chem_types) {
    derivs[[paste('u',ctypes,'C',sep='')]]<-(-decomp[[paste(ctypes,'C', sep='')]])+protectedturnover[[paste(ctypes,'C', sep='')]]-protectedprod[[paste(ctypes,'C', sep='')]]
    derivs[[paste('p',ctypes,'C',sep='')]]<-protectedprod[[paste(ctypes,'C', sep='')]]-protectedturnover[[paste(ctypes,'C', sep='')]]
    derivs[[paste('u',ctypes,'N',sep='')]]<-(-decomp[[paste(ctypes,'N',sep='')]])+protectedturnover[[paste(ctypes,'N', sep='')]]-protectedprod[[paste(ctypes,'N', sep='')]]
    derivs[[paste('p',ctypes,'N',sep='')]]<-protectedprod[[paste(ctypes,'N', sep='')]]-protectedturnover[[paste(ctypes,'N', sep='')]]
  }

  derivs['uNecroC']<-derivs['uNecroC']+deadmic_C_production*(1.0-params$frac_turnover_slow)
  derivs['uSlowC']<-derivs['uSlowC']+deadmic_C_production*params$frac_turnover_slow
  turnover_N_min<-deadmic_N_production*params$frac_N_turnover_min
  turnover_N_slow<-deadmic_N_production*params$frac_turnover_slow
  derivs['uNecroN']<-derivs['uNecroN']+deadmic_N_production-turnover_N_min-turnover_N_slow
  derivs['uSlowN']<-derivs['uSlowN']+turnover_N_slow
  derivs['inorganicN']<-derivs['inorganicN']+turnover_N_min

  return(derivs)
}

# ############################################################################################
# 
