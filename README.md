# Quick Data Visualization

## Introduction
Welcome to a bunch of scripts to help analysis your 2D data. The set of scripts here are designed to help you understand your 2D data from a purely data driven stand-point. It will let you slice, svd, and global fit a data set.

There are two main scripts to run
1. quick_dataVisulisation
2. quick_explore_GF

The MATLAB command window will have important details, please read.

## Overview of the data analysis types

A brief description of the functions is below, please read the individual sections for more details on each, they are located after the 'Running the scripts' section

### plot_slices 

This will take simple kinetic and spectra of the dataset, it will intergrade between the regions entered. The slices are defined in the `%% Plotting` section of the code.

### plot_slices _LSQ  

Will use the same spectra and kinetics defined above but tread them as the known components and do LSQ to determine the other axis. i.e the user defined spectra will give kinetics

### do_SVD  

Runs SVD (singular value decomposition) on the data and plots the results in a manner to try and identify the number of components/

### do_global_fit  

Fits the data to a number of exponential decay components. Presents a summary of the various fits attempted.

### quick_explore_GF 

A **separate script** to explore and plot the results from the global fitting

## Running the scripts

Run the script called "quick_dataVisulisation", the majority of lines in this code are inputs into the various analysis types mentioned above. 

```matlab
quick_dataVisulisation
```

## plot_slices 

![](README_Images/plot_slices-output.png)