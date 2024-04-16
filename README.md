# FUN-BioCROP
Bioenergy model of plant C spent on N acquisition and SOM cycling.  

**NOTE:** This is a legacy version of the FUN-BioCROP model that was published in GCB Bioenergy in 2022 (citation below). The newest version of the model is in the FUN-BioCROP-LIDET repository. 

[![DOI](https://zenodo.org/badge/412558745.svg)](https://zenodo.org/badge/latestdoi/412558745)

**Model name:** “FUN-BioCROP.Rmd”

**Creators:** Stephanie Juice, Christopher Walter, Kara Allen, Danielle Berardi, Tara Hudiburg, Benjamin Sulman, Edward Brzostek

**Contact information:** stephanie.juice@mail.wvu.edu, erbrzostek@mix.wvu.edu 

**Related publication:**  
Juice, S. M., Walter, C. A., Allen, K. E., Berardi, D. M., Hudiburg, T. W., Sulman, B. N., & Brzostek, E. R. (2022). A new bioenergy model that simulates the impacts of plant-microbial interactions, soil carbon protection, and mechanistic tillage on soil carbon cycling. GCB Bioenergy, 14, 346–363. https://doi.org/10.1111/gcbb.12914

**Software**: R

**Accompanying files:**  

1.    CORPSE function code: **CORPSE Functions_Bioenergy.R**

2.    Data streams to load into the script: <br>
    a. **bulk.csv, bulk_till.csv, rhizo.csv, rhizo_till.csv, litter.csv**: initial C and N (kg C or N/m<sup>2</sup>) pool values for each soil compartment, final values from spin up. <br> 
    All five files have the same columns:

| **Column**     | **Description**                       | **Units**                  |
| -------------- | ------------------------------------- | -------------------------- |
| uFastC         | Unprotected fast decomposing carbon   | kg  carbon/m<sup>2</sup>   |
| uSlowC         | Unprotected slow decomposing carbon   | kg  carbon/m<sup>2</sup>   |
| uNecroC        | Unprotected necromass carbon          | kg  carbon/m<sup>2</sup>   |
| pFastC         | Protected fast decomposing carbon     | kg  carbon/m<sup>2</sup>   |
| pSlowC         | Protected slow decomposing carbon     | kg  carbon/m<sup>2</sup>   |
| pNecroC        | Protected necromass carbon            | kg  carbon/m<sup>2</sup>   |
| livingMicrobeC | Carbon in living microbial biomass    | kg  carbon/m<sup>2</sup>   |
| uFastN         | Unprotected fast decomposing nitrogen | kg  nitrogen/m<sup>2</sup> |
| uSlowN         | Unprotected slow decomposing nitrogen | kg  nitrogen/m<sup>2</sup> |
| uNecroN        | Unprotected necromass nitrogen        | kg  nitrogen/m<sup>2</sup> |
| pFastN         | Protected fast decomposing nitrogen   | kg nitrogen/m<sup>2</sup>  |
| pSlowN         | Protected slow decomposing nitrogen   | kg  nitrogen/m<sup>2</sup> |
| pNecroN        | Protected necromass nitrogen          | kg  nitrogen/m<sup>2</sup> |
| inorganicN     | Inorganic nitrogen                    | kg  nitrogen/m<sup>2</sup> |
| CO2            | Carbon in carbon dioxide              | kg  carbon/m<sup>2</sup>   |
| livingMicrobeN | Nitrogen in living microbial biomass  | kg  nitrogen/m<sup>2</sup> |

 

​	b.    **FluxTower_AvgSoilT.csv**: Average daily soil temperature (<sup>o</sup>C) at 10 cm depth at University of Illinois Urbana-Champaign (UIUC) Energy Farm flux tower from 7/2008-3/2016. (One year of averaged data)

​	c.    **FluxTower_AvgSoilVWC.csv**: Average daily soil volumetric water content (VWC) at 10 cm depth at UIUC Energy Farm flux tower from 7/2008-3/2016. (One year of averaged data)

​	d.   **Input.csv**: This file has daily data to run FUN-BioCROP: 

| **Column**           | **Description**                                              | **Units**              |
| -------------------- | ------------------------------------------------------------ | ---------------------- |
| yr                   | calendar year                                                | year                   |
| doy                  | day of year (1 to 365) (no leap year)                        | day                    |
| anpp                 | aboveground NPP (DayCent)                                    | kg C/m<sup>2</sup>/day |
| bnpp                 | belowground NPP (DayCent)                                    | kg C/m<sup>2</sup>/day |
| aglivc               | live aboveground biomass carbon (DayCent)                    | kg C/m<sup>2</sup>     |
| bglivcj              | live juvenile fine root biomass carbon (DayCent)             | kg C/m<sup>2</sup>     |
| bglivcm              | live mature fine root biomass carbon (DayCent)               | kg C/m<sup>2</sup>     |
| aglivn               | live aboveground biomass nitrogen (DayCent)                  | kg N/m<sup>2</sup>     |
| bglivnj              | live juvenile fine root biomass nitrogen (DayCent)           | kg N/m<sup>2</sup>     |
| bglivnm              | live mature fine root biomass nitrogen (DayCent)             | kg N/m<sup>2</sup>     |
| nyr                  | simulation year                                              | year                   |
| omad                 | indicates an organic matter addition event (0 or 1)          |                        |
| crop                 | indicates a new crop (0 or 1)                                |                        |
| cult                 | indicates a cultivation event (0 or 1)                       |                        |
| harv                 | indicates a harvest event (0 or 1)                           |                        |
| last                 | indicates the end of the growing season (0 or 1)             |                        |
| fert                 | indicates a fertilizer event (0 or 1)                        |                        |
| croptype             | crop type (0=none; 1=alfalfa; 2=corn; 3=grass clover pasture; 4=soybean; 5=wheat) |                        |
| cropsrl              | crop specific root length                                    | mm/g root              |
| cultrhizmix          | fraction of rhizosphere mixed with bulk soil during cultivation (0.0-1.0) | fraction               |
| cultlitmix           | fraction of litter mixed with bulk soil during cultivation (0.0-1.0) | fraction               |
| harvremov            | fraction of above ground biomass removed during harvest (0.0-1.0) | fraction               |
| omadcn               | C:N of organic matter addition                               |                        |
| omadc                | amount of carbon in organic matter addition                  | g C/m<sup>2</sup>      |
| omadlig              | organic matter addition lignin fraction                      | g lignin/g C           |
| fertamt              | fertilization amount                                         | g N/m<sup>2</sup>      |
| froot_turnover_c     | amount of C in fine root turnover                            | kg C/m<sup>2</sup>     |
| froot_turnover_n     | amount of N in fine root turnover                            | kg N/m<sup>2</sup>     |
| agrd_turnover_c      | amount of C in aboveground biomass turnover                  | kg C/m<sup>2</sup>     |
| agrd_turnover_n      | amount of N in aboveground biomass turnover                  | kg N/m<sup>2</sup>     |
| leaf_litter_fastfrac | Fast decomposing fraction of leaf litter (0.0-1.0)           | fraction               |
| root_litter_fastfrac | Fast decomposing fraction of root litter (0.0-1.0)           | fraction               |
| root_diameter        | root diameter                                                | mm                     |
| root_length          | root length                                                  | mm root/m<sup>2</sup>  |
| rhizo_frac           | fraction of total soil volume that is rhizosphere (0.0 - 1.0) | fraction               |

  

**Instructions:** 

1) Save the model code (“FUN-BioCROP.Rmd”) and accompanything files (data streams and CORPSE function code) in the same folder. 

2) In “Chunk 3: Load CORPSE Data Streams” set the working directory (setwd) to the folder with the files saved in step #1.

3) If changing any parameter values, edit them in “Chunk 5: Load parameters.” 

4) Run all chunks up to and including “Chunk 10: Prepare Data for Export.”

5) In “Chunk 11: Export results” edit data frames for export and filenames, as necessary. 

6) “Chunk 12: Graph Results” makes a figure of C remaining over the model run period.

**Description:** 

The FUN-BioCROP model (Fixation and Uptake of Nitrogen-Bioenergy Carbon, Rhizosphere, Organisms, and Protection) is a variation of FUN-CORPSE (Fixation and Uptake of Nitrogen-Carbon, Organisms, Rhizosphere, and Protection in the Soil Environment, Sulman et. al. 2017) that has been modified for bioenergy systems by including tillage, harvest, fertilization, organic matter addition, and feedstock-specific parameters. The model is driven by output from DayCent-CABBI (Berardi et al. 2020, Moore et al. 2020), including aboveground NPP, belowground NPP, aboveground C and N, and belowground C and N in juvenile and mature roots. It also uses the same schedule of agricultural events (planting, cultivation, harvest, last growing day, fertilization) as DayCent, except for fire and grazing. 

Tillage is achieved by assigning two new soil compartments to the model: a tilled rhizosphere and tilled bulk soil. In both cases, the percent of tilled soil is assigned with the parameter “pct _tilled” and the amount of protected C that becomes unprotected after tillage is controlled by the parameter “tillPtoUP." 

**Description of each chunk:** 

1. **Chunk 1: Remove all functions, clear memory.** Removes all functions from R environment, clears the memory. 

2. **Chunk 2: Load Packages.** Loads packages necessary to run the code. 

3. **Chunk 3: Load CORPSE Data Streams.** Sets the working directory and loads the data files necessary to run CORPSE.

4. **Chunk 4:** **Load CORPSE Functions.** Loads the R script with CORPSE functions from the working directory, “CORPSE Functions_Bioenergy.R”.

5. **Chunk 5: Load Parameters.** Loads all fixed parameters to run the model. Data frame with definitions of parameters is in the CORPSE function script “CORPSE Functions_Bioenergy.R”

6. **Chunk 6: Prepare Data Streams.** Takes data streams loaded in Chunk 3 and puts them in the format necessary to run the model. The model is coded to run at least two sites at a time, so if only one site is being run it must be run in duplicate. Individual data tables of daily values are created in this chunk from the input data file.

7. **Chunk 7: Set Initial Conditions.** Creates data tables of soil C and N pools for each soil compartment (rhizo_till, rhizo, bulk_till, bulk, litter) and loads initial values into the data tables. Creates lists for each soil compartment to hold model output. 

8. **Chunk 8: Load FUN Data and Set Up Matrices.** Uses DayCent data to calculate FUN input data: root and leaf N demand, total N demand, plant CN, leaf N available for retranslocation, and litter production. Creates matrices for FUN model outputs. 

9. **Chunk 9: Run Model.** Runs the model. 

10. **Chunk 10**: **Prepare Data for Export.** Combines data from each day saved as lists into data frames for each soil compartment. Adds values from all soil compartments together to calculate total soil values, creates separate data frames for each soil C and N pool (e.g., protected slow C) for the total soil value. Adds different C and N pools together to calculate total soil C and N for all layers. Creates data frame of ratio of protected to unprotected SOC. Organizes FUN data for export. 

11. **Chunk 11: Export Results.** Exports CSV files of model results to the working directory. 

12. **Chunk 12: Graph C Remaining.** Makes figure of C remaining over time. 

    

**References:**

Berardi, D., E. Brzostek, E. Blanc-Betes, B. Davison, E. H. DeLucia, M. D. Hartman, J. Kent, W. J. Parton, D. Saha, and T. W. Hudiburg. 2020. 21st-century biogeochemical modeling: Challenges for Century-based models and where do we go from here? GCB Bioenergy **12**:774-788.

Moore, C. E., D. M. Berardi, E. Blanc-Betes, E. C. Dracup, S. Egenriether, N. Gomez-Casanovas, M. D. Hartman, T. Hudiburg, I.Kantola, M. D. Masters, W. J. Parton, R. Van Allen, A. C. von Haden, W. H. Yang, E. H. DeLucia, and C. J. Bernacchi. 2020. The carbon and nitrogen cycle impacts of reverting perennial bioenergy switchgrass to an annual maize crop rotation. GCB Bioenergy **12**:941-954

Sulman, B. N., Brzostek, E. R., Medici, C., Shevliakova, E., Menge, D. N., & Phillips, R. P. (2017). Feedbacks between plant N demand and rhizosphere priming depend on type of mycorrhizal association. Ecology letters, 20(8), 1043-1053.
