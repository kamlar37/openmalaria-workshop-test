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
# wd =  "C:/Users/kambla/Documents/workshop/scripts/practical1/"
# os.chdir(wd)

# Define helper function to execute shell commands
def exec(command):
    p = subprocess.Popen(command, shell = True, stderr=subprocess.PIPE, stdout=subprocess.PIPE, universal_newlines=True, text=True)
    out, err = p.communicate()
    if p.returncode:
        print(f"Error running command {command}\n{err}")

# Define dict for names of measures used
measures_map = {
    0: "nHost",
    1: "nInfect",
    3: "nPatent",
    14: "nUncomp",
    15: "nSevere",
    35: "inputEIR",
    36: "simulatedEIR"
}


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
command = f"cd ../../openMalaria-windows && openMalaria --scenario {wd}/example_scenario.xml --output {wd}/out.txt"

# Run the simulation
exec(command)


# Post process
###############

# Load the output produced by OpenMalaria
output_data = pd.read_csv("out.txt", sep="\t", header=None, names=['survey', 'group', 'measure', 'value'])

# Inspect the output
print(output_data)

# Replace the measure ID by the measure name
output_data['measure'] = output_data['measure'].map(measures_map)

# Create survey_time column indicating time in years
output_data['survey_time'] = (output_data['survey'] - 1)/12

# Discard the first survey
output_data = output_data[output_data.survey != 1]

# Visualize the data
####################

# Visualize the number of uncomplicated cases
df_plot = output_data[output_data.measure=='nUncomp']
ax = sns.lineplot(data=df_plot, x='survey_time', y='value')
ax.set(xlabel="Time (years)", ylabel="Number of uncomplicated cases", ylim=(0,None))

# Create normalized values: transform monthly absolute values to yearly value per person
output_data['value_normalised'] = output_data['value'] / 2000 * 12

# Visualize the Number of uncomplicated cases p.p./year
df_plot = output_data[output_data.measure=='nUncomp']
ax = sns.lineplot(data=df_plot, x='survey_time', y='value_normalised')
ax.set(xlabel="Time (years)", ylabel="Uncomplicated cases p.p./year", ylim=(0,None))


############################################################
#                                                          #
# Section 2                                                #
#                                                          #
# Run the simulation with an insecticide treated net (ITN) #
#                                                          #
############################################################

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
# Run the simulation with a pre-erythrocytic vaccine (PEV)   #
#                                                            #
##############################################################

#-------------------------------------------------------------------------------------------------------------#
# TO-DO:                                                                                                      #
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

