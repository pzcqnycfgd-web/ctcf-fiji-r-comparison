# CTCF Quantification: Fiji vs R

A reproducible fluorescence microscopy workflow comparing Fiji and R for ROI-based Corrected Total Cell Fluorescence analysis.

## Project Goal

This project evaluates whether an automated R workflow can reproduce CTCF measurements obtained using Fiji/ImageJ.

## CTCF Formula

CTCF = Integrated Density - (ROI Area × Mean Background Intensity)

## Experimental Design

- Three treatment times: 1 h, 2 h and 4 h
- Two images per time point
- 26 cell ROIs per image set
- 3 background ROIs
- Same ROI files used in Fiji and R

## Main Findings

Both Fiji and R showed:

- Moderate fluorescence at 1 h
- Similar or slightly reduced fluorescence at 2 h
- Strongly increased fluorescence at 4 h

The two methods showed broadly comparable trends.

## Repository Structure

```text
R/
├── ctcf_analysis.R
├── compare_methods.R
└── plotting.R

data/
└── fiji_r_ctcf_comparison.csv

docs/
├── final-report.pdf
└── methodology.md
