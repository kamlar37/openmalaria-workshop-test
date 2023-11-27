##########################################################################
# PRACTICAL 1:                                                           #
#                                                                        #
# Objective: learn to run simulations in Open Malaria                    #
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


# Install packages
# install.packages("dplyr")
# install.packages("dplyr")


# load the package
library(dplyr)
library(ggplot2)



################################
#                              #
# Define the working directory #
#                              #
################################

# Set the Working directory to location of this script. Either through the GUI or by command:
setwd("C:\\Users\\massth\\Desktop\\Workshop\\mumbai-workshop\\Practical_1")



#######################
#                     #
# Section 1           #
#                     #
# Running an example  #
#                     #
#######################


# Run OpenMalaria
#################

# Define the command line command to run the simulation. On Linux, add a "./" before the "openMalaria" command. Adjust path if needed.
command <- paste(
  "cd ../../openMalaria-windows",
  paste0(
    "openMalaria --scenario ",
    getwd(),
    "/example_scenario.xml --output ",
    getwd(),
    "/out1.txt"
  ),
  # PROVIDE AN OTHER SCENARIO
  sep = " && "
)

command

# Run the simulation. Shell is Windows-specific. On Linux, use the command "system".
shell(command)



# Post process
###############

# Load the output produced by OpenMalaria
output_data <- read.table("out1.txt")

# Inspect output data
head(output_data, n=20)

# Name the column
colnames(output_data)[1:4] <-
  c("survey", "group", "measure", "value")

# Replace the measure ID by the measure name 
# All available output measures described here: https://github.com/SwissTPH/openmalaria/wiki/MonitoringOutput
output_data <- output_data %>% mutate (
  measure = recode (
    measure,
    "0" = "nHost",
    "1" = "nInfect",
    "3" = "nPatent",
    "14" = "nUncomp",
    "15" = "nSevere",
    "35" = "inputEIR",
    "36" = "simulatedEIR"
  )
)

# Define the range of the different age groups. 
# The ranges of the age groups depend on our definitions in the the XML.
output_data <-
  output_data %>% mutate (
    group = recode (
      group,
      "0" = "All",
      "1" = "0-1 years",
      "2" = "1-2 years",
      "3" = "2-5 years",
      "4" = "5-10 years",
      "5" = "10-15 years",
      "6" = "15-20 years",
      "7" = "20-100 years"
    )
  ) %>%
  mutate(group = factor(
    group,
    levels = c(
      "All",
      "0-1 years",
      "1-2 years",
      "2-5 years",
      "5-10 years",
      "10-15 years",
      "15-20 years",
      "20-100 years"
    )
  ))


# Add a column specifying survey time in years based on survey number

## Define the number of days  between surveys
time_step <- 5

## Estimate the number of surveys per year
surveys_per_year <- 365 / time_step

## Estimate the time in years
output_data <- output_data %>% mutate(survey_time = survey / surveys_per_year)

# Remove all the data measured at the first survey
output_data <- output_data %>% filter(survey != 1)


# Visualize the data
####################

# Visualize the number of hosts
ggplot(data = output_data %>% filter(measure == "nHost")) +
  geom_line(aes(x = survey_time, y = value, color = group), size = 1) +
  theme_bw() +
  xlab("Time (years)") +
  ylab("Number of hosts") +
  guides(color = guide_legend(title = "Age group")) +
  theme(
    axis.text.x = element_text(size = 16),
    axis.text.y = element_text(size = 16),
    axis.title.x = element_text(size = 18, face = "bold"),
    axis.title.y = element_text(size = 18, face = "bold"),
    plot.title = element_text(size = 18, face = "bold")
  ) +
  theme(legend.title = element_text(size = 16, face = "bold"),
        legend.text = element_text(size = 16))


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


# Visualize the number of uncomplicated malaria cases
ggplot(data = output_data %>% filter(measure == "nUncomp")) +
  geom_line(aes(x = survey_time, y = value, color = group), size = 1) +
  theme_bw() +
  xlab("Time (years)") +
  ylab("Number of uncomplicated malaria cases") +
  guides(color = guide_legend(title = "Age group")) +
  ggplot_theme


############################
#                          #
# Section 2                #
#                          #
# Change survey frequency  #
#                          #
############################


#--------------------------------------------------------------------------#
#                                                                          #
# TO DO:                                                                   #
# 1. Copy example_scenario.xml and change the survey interval to yearly    #
# 2. Write the code to run the simulation  and post-process the data.      #
#    (You can copy-paste and adapt the code from section 1)                #
# 3. Visualize the new number of uncomplicated malaria cases               #
# 4. What do you conclude from the plot? In which group do most malaria    #
#    cases occur. Does this plot also represent risk of infection by age   #
#    group?                                                                #
#                                                                          #
#--------------------------------------------------------------------------#


#############################################
#                                           #
# Section 3                                 #
#                                           #
# Account for population size in age groups #
#                                           #
#############################################



# -----------------------------------------------------------------------------------------------------------------#
#                                                                                                                  #
# TO-DO:                                                                                                           #
# 1. Adjust the number of total of uncomplicated cases in each each group by the number of hosts in that age group #
#    a. How can you interpret the resulting value?                                                                 #
# 2. Plot the resulting values against time analogous to the plot from the last section                            #
#    a. How are the relative positions of the curves different?                                                    #
# 3. For better comparison between age groups, create a new plot with age-groups on the X-axis and the mean of the #
#    adjusted value  over time on the y a-xis.                                                                     #
# 4. Repeat steps 2 and 3 for the mesaure "nPatent"                                                                #
#    What exactly does nPatent represent? How does the adjusted curve over age from that for nUncomp?              # 
#                                                                                                                  #
#------------------------------------------------------------------------------------------------------------------#
