# Methodology

## CTCF Formula

Corrected Total Cell Fluorescence was calculated as:

CTCF = Integrated Density - (ROI Area × Mean Background Intensity)

## Fiji Workflow

1. Open the fluorescence microscopy image in Fiji.
2. Use polygon selections to define cell ROIs.
3. Select several cell-free background ROIs.
4. Save all ROI files using ROI Manager.
5. Measure Area, Mean Intensity and Integrated Density.
6. Calculate mean background intensity.
7. Calculate CTCF for each cell ROI.

## R Workflow

1. Read the fluorescence image using EBImage.
2. Extract the green fluorescence channel.
3. Import Fiji polygon ROI files using RImageJROI.
4. Convert ROI coordinates into binary masks.
5. Extract pixel values from each mask.
6. Calculate Area, Mean Intensity and Integrated Density.
7. Calculate the mean intensity of background ROIs.
8. Calculate CTCF and export the results to CSV.

## Method Comparison

Fiji and R results were compared using:

- Mean and standard deviation
- Paired measurements
- Pearson correlation
- Spearman correlation
- Paired statistical tests
- Bland-Altman analysis
