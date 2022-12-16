Rachel Holser (rholser@ucsc.edu)
Last Updated: 24-Mar-2022

run_change_format_DA.m is a script that allows to user to execute the needed functions within a loop, processing all files within a batch.
To start the process, only the .csv files from step 01 can be in this folder at the start of the process (raw TDR files that have been 
appropriately extracted or formatted - must include a field titled "Depth" and either "Time" (HH:MM:SS dd-mmm-yyyy) or separate "Date" 
and "Time" fields).

When the process is completed, there should be 7 files for each TOPP ID (2 .fig, 1 .txt, 4 .csv).  The .csv and .txt files need to be 
transfered forward to step 03.

The .fig files can be used for quality control - they illustrate the ZOC and dive identification for the TDR.