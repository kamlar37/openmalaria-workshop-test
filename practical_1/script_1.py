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
# Set up                      #
#                             #
###############################

import matplotlib.pyplot as plt
import os
import pandas as pd
import seaborn as sns
import subprocess

# Set working directory. Should be the same as directory of this script.
wd = os.getcwd()
print(wd)

# Change working directory using os.chdir if required. Adapt to you path
# wd =  "C:/Users/kambla/Documents/workshop/scripts/practical/"
# os.chdir(wd)

# Define helper function to execute shell commands
def exec(command):
    p = subprocess.Popen(command, shell = True, stderr=subprocess.PIPE, stdout=subprocess.PIPE, universal_newlines=True, text=True)
    out, err = p.communicate()
    if p.returncode:
        print(f"Error running command: {err}")



#######################
#                     #
# Section 1           #
#                     #
# Running an example  #
#                     #
#######################


# Run OpenMalaria
#################

# Define the command line command to run the simulation. On Linux, add a "./" before the "openMalaria" command.
command = f"cd ../../openMalaria-windows && openMalaria --scenario {wd}/example_scenario.xml --output {wd}/out1.txt"

print(command)

# Run the simulation
exec(command)

# Post process
###############

# Load the output produced by OpenMalaria
output_data = pd.read_csv("out1.txt", sep="\t", header=None, names=['survey', 'group', 'measure', 'value'])

# Inspect the output
print(output_data)

# Replace the measure ID by the measure name 
# All available output measures described here: https://github.com/SwissTPH/openmalaria/wiki/MonitoringOutput
output_data['measure'] = output_data['measure'].map({
    0: "nHost",
    1: "nInfect",
    3: "nPatent",
    14: "nUncomp",
    15: "nSevere",
    35: "inputEIR",
    36: "simulatedEIR"})

# Define the range of the different age groups. 
# The ranges of the age groups depend on our definitions in the the XML.
output_data['group'] = output_data['group'].map({
    0: "All",
    1: "0-1 years",
    2: "1-2 years",
    3: "2-5 years",
    4: "5-10 years",
    5: "10-15 years",
    6: "15-20 years",
    7: "20-100 years"
}) 

# Add a column specifying survey time in years based on survey number

## Define the number of days  between surveys
time_step = 5

## Estimate the number of surveys per year
surveys_per_year = 365 / time_step

## Estimate the time in years
output_data['survey_time']  = output_data['survey'] / surveys_per_year

# Remove the first survey
output_data = output_data[output_data.survey != 1]


# Visualize the data
####################

# Visualize the number of hosts
df_plot = output_data[output_data.measure=='nHost']
ax = sns.lineplot(data=df_plot, x='survey_time', y='value', hue='group')
ax.set(xlabel="Time (years)", ylabel="Number of hosts")
plt.legend(title="Age group", bbox_to_anchor=(1,1))

# Visualize the number of uncomplicated malaria cases
df_plot = output_data[output_data.measure=='nUncomp']
ax = sns.lineplot(data=df_plot, x='survey_time', y='value', hue='group')
ax.set(xlabel="Time (years)", ylabel="Number of hosts")
plt.legend(title="Age group", bbox_to_anchor=(1,1))


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