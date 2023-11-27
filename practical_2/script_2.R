##########################################################################
# PRACTICAL 2:                                                           #
#                                                                        #
# Objective: Compare the effect of two interventions                     #
#                                                                        #
# Authors: thiery.masserey@swisstp.ch, lars.kamber@swisstph.ch           #
#                                                                        #
# Date: 24.11.2023                                                       #
##########################################################################

###############################
#                             #
# Install important packages  #
#                             #
###############################


# load the package
library(dplyr)
library(ggplot2)


################################
#                              #
# Define the working directory #
#                              #
################################

# Set the Working directory to location of this script. Either through the GUI or by command:
setwd("C:\\Users\\massth\\Desktop\\Workshop\\mumbai-workshop\\Practical_2")


#######################
#                     #
# Section 1           #
#                     #
# Run the control arm #
#                     #
#######################


# Run OpenMalaria
#################

# Define the command line command to run the simulation. On Linux, add a "./" before the "openMalaria" command.
command <- paste(
  "cd ../../openMalaria-windows",
  paste0(
    "openMalaria --scenario ",
    getwd(),
    "/example_scenario.xml --output ",
    getwd(),
    "/out.txt"
  ),
  # PROVIDE AN OTHER SCENARIO
  sep = " && "
)

# Run the simulation
shell(command)


# Post process
###############

# Load the output produced by OpenMalaria
output_data <- read.table("out.txt")

# Name the columns
colnames(output_data)[1:4] <- c("survey", "group", "measure", "value")


# Replace the measure ID by the name (https://github.com/SwissTPH/openmalaria/wiki/MonitoringOutput)
output_data <- output_data %>% mutate (
  measure = recode (
    measure,
    "0" = "nHost",
    "1" = "nInfect",
    "3" = "nPatent",
    "14" = "nUncomp",
    "35" = "inputEIR",
    "36" = "simulatedEIR"
  )
)


# Create survey time column indicating time in years
output_data <- output_data %>% mutate(survey_time = (survey - 1) / 12)

# Discard the first survey
output_data <- output_data %>% filter(survey != 1)

# Visualize the data
####################

# Define a general theme to use for all plots
ggplot_theme <- theme(
  axis.text.x = element_text(size = 16),
  axis.text.y = element_text(size = 16),
  axis.title.x = element_text(size = 18, face = "bold"),
  axis.title.y = element_text(size = 18, face = "bold"),
  plot.title = element_text(size = 18, face = "bold"),
  legend.title = element_text(size = 16, face = "bold"),
  legend.text = element_text(size = 16)
)

# Visualize the number of uncomplicated cases
ggplot(data = output_data %>% filter(measure == "nUncomp")) +
  geom_line(aes(x = survey_time, y = value), size = 1) +
  theme_bw() +
  xlab("Time (year)") +
  ylab("Number of uncomplicated cases") +
  guides(color = guide_legend(title = "Age group")) +
  ylim(0, NA)+
  ggplot_theme

# Create normalized values: transform monthly absolute values to yearly value per person
output_data <- output_data %>% mutate(value_normalised = value / 2000 * 12)

# Visualize the Number of uncomplicated cases p.p./year
ggplot(data = output_data %>% filter(measure == "nUncomp")) +
  geom_line(aes(x = survey_time, y = value_normalised), size = 1) +
  theme_bw() +
  xlab("Time (year)") +
  ylab("Uncomplicated cases p.p./year") +
  ylim(0, NA) +
  guides(color = guide_legend(title = "Age group")) +
  ggplot_theme



#############################################################
#                                                           #
# Section 2                                                 #
#                                                           #
# Run the simulation with an insecticide treated net (ITN)  #
#                                                           #
#############################################################

#-----------------------------------------------------------------------------------------------------------#
# TO DO:                                                                                                    #
# 1. Copy the control XML used in Section 1                                                                 #
# 2. Define an ITN in the new XML using a generic vector intervention (GVI). For details see:               #
#    https://github.com/SwissTPH/openmalaria/wiki/ModelInterventions#generic-vector-intervention-gvi        #
#    Parameterize your ITN such that for individuals that have an ITN:                                      #
#    a. The probability of being targeted for biting by a mosquito is reduced by 44%                        #
#    b. The probability of a mosquito successfully biting a targeted host without dying is reduced by 27%   #
#    c. The probability of a mosquito successfully escaping after biting without dying is reduced by 27%    #
#    d. The decay of the net effectiveness follows a weibull function with half-life of 3 years and k=1     #
#       https://github.com/SwissTPH/openmalaria/wiki/ModelDecayFunctions                                    #
#    e. Make sure that the net takes effect for all mosquito species defined in the XML                     #  
#    f. Deploy the ITNs once at 10 years at a 60% coverage. See here for deployment schemes                 #
#      https://github.com/SwissTPH/openmalaria/wiki/ModelInterventions#deployment-programmes                #
# 3. Run OpenMalaria using the new XML file (you can copy past much of the code above)                      #
#    a. Make sure you not to overwrite the results from the control XML, as we will use them later          #
# 4. Visualize the incidence of uncomplicated malaria cases per person per year over time                   #
#-----------------------------------------------------------------------------------------------------------#


##############################################################
#                                                            #
# Section 3                                                  #
#                                                            #
# Run the simulation with a Pre-erythrocytic vaccine (PEV)   #
#                                                            #
##############################################################

#-------------------------------------------------------------------------------------------------------------#
# TO DO:                                                                                                      #
# 1. Copy the control XML used in Section 1                                                                   #
# 2. Define the PEV using a <PEV> element. For details see:                                                   #
#    https://github.com/SwissTPH/openmalaria/wiki/ModelInterventions#description-in-xml-from-version-32       #
#    Parameterize the PEV to have the following effect:                                                       #
#    a. The PEV has an initial efficacy of 100%                                                               #
#    b. The decay of the PEV effect follows a Weibull function with a shape parameter k=0.69 and              #
#        a half-life of 0.73 years                                                                            #
#    c. The parameter of the beta distribution controlling the variation of efficacy between individuals      #
#        is equal to 10                                                                                       #
#    d. Deploy the PEV once at 10 years at a 60% coverage (1 dose only). See here for deployment schemes:     #
#    https://github.com/SwissTPH/openmalaria/wiki/ModelInterventions#deployment-programmes                    #
# 3. Run OpenMalaria using the new XML file (you can copy past much of the code above)                        #
#    a. Make sure you not to overwrite the results from the control and ITN XMLs, as we will use them later   #
# 4. Visualize the incidence of uncomplicated malaria cases per person per year over time                     #
#-------------------------------------------------------------------------------------------------------------#


#############################
#                           #
# Section 4                 #
#                           #
# Compare the interventions #
#                           #
#############################

#--------------------------------------------------------------------------------------------------------------#
#                                                                                                              #
# TO-DO:                                                                                                       #
# 1. Combine the uncomplicated cases p.p./year time series from the control, ITN and PEV scenarios in one plot #                            #
# 2. Quantify the effect of each intervention (for example, the relative reductions of cases over              #
#    the period of your choice following the implementation of the intervention)                               #
#                                                                                                              #
#--------------------------------------------------------------------------------------------------------------#
