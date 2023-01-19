Rachel Holser (rholser@ucsc.edu)
Last Updated 24-Mar-2022

Special notes and instructions on processing dive data for northern elephant seals.  
Note: additional ReadMe files may be present within individual steps of the process 
to provide specific help with that step.

This process is broken into 4 steps.  The user should copy all of the data files, 
both input and output, from one step to another upon completetion of that step.  
(Example... Wildlife computers Hex Decode will generate the .csv files needed 
for 02: fix CSV and run DA.  Those files need to be copied and moved to that folder 
in order for 02 to work.)

All raw data files need to start with the TOPPID - this is required to match data in future 
steps. The file name can include either the instrument serial number (recommended) or the 
type of tag (or both). It can also include the SealID, but that is not required. Length does 
not matter.

Examples:

2014005_0490159.wch (wildlife computers mk9)
2014019_12A1591.wch (wildlife computers mk10)
2016036_13267.txt (SMRU CTD)
2011016_T911_KamiDepth.txt (Little Leonard Kami logger)


01: Data Preparation

The raw data will need some preparation prior to analysis, that preparation will differ 
depending on the instruments used to collect it.

In the case of wildlife computers data, the raw data will need to be extracted from .wch 
files into .csv formatting.  This can be done one at a time using WC's software or can be 
done as a batch using the hex decode script.  

SMRU tags have their own, very special, set of issues.  The TDRs from SMRU tags will need 
to undergo very detailed proofing and correction before any of the other steps can take 
place.

02: fix csv and run DA

This step will check for and correct errors in the raw data (eg removing lines with NaN 
for depth) that will interfere with the dive analysis.  The dive analysis performed 
(yt_iknos_da) includes zero-offset correction (ZOC) and generates DiveStat and 
raw_data .csv files.  These data are being analyzed with the sampling resolution native 
to the instrument deployed - they have NOT been subset down to an 8 second sampling 
interval (the standard for comparison across all years and seasons due to memory 
limitation during the earlier years of deployment).

03: subsample and run DA

Step 3 will subsample all dive records down to an 8 second sampling rate and then complete
the same dive analysis performed in 02.  The resulting files will all include 
_SubSample_ in their names.

04: Dive Type

Step 4 uses Patrick Robinson's dive typing logarithm to assign dive types to each dive
identified in steps 2/3.
	