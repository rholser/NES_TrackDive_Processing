% DiveProcessing Consolidates all dive processing steps into one script.
%
% Requires "New IKNOS" toolbox and modified/custom functions and files:
%   For Step 2 (full resolution ZOC and Dive Analysis):
%       DA_data_compiler_V4.m
%       change_format_DA_V4_2.m
%       iknos_DA.m
%       MetaData.mat
%   For Step 3 (subsample to 8 sec, ZOC and Dive Analysis):
%       DA_data_compiler_V4.m
%       subsample_DA_V4_2.m
%       iknos_DA.m
%
% This process should not be run in parallel (or in multiple instances of matlab) as the iknos_da 
% function may writes temporary files - if multiple instances are run, this could mix tdr records 
% together.
%
% Created by: Rachel Holser (rholser@ucsc.edu)
% Created on: 18-May-2022
%
% Version 4: 
% Step 1: load SMRU text files and convert to *tdr_raw.csv, then will check and correct for 
% broken dives and save as *_clean_tdr.csv
%
% Step 2: load all load each TDR file (SMRU, WC, or Little Leonardo) in the current directory,
% adjust the timedate formatting, check for major errors in the timeseries (depth spikes, backward
% time jumps (yes, they happen), etc.), truncate the record to deployment start and end time, and 
% will run iknos_da which will do a zero-offset correction and identify and calculate statistics 
% for each dive.
%
% Step 3: load full resolution outputs from Step 2, subsample it to 8 seconds if possible, and 
% run iknos_da on the subsampled data.
%
% Update Log:
% 29-Dec-2022 - changed function names and updated inputs for Step 3

%% Step 1: SMRU tag data import
clear
SMRUfiles=dir('*tdr.txt');

for k=15:length(SMRUfiles)
    import_smru_tdr_V4(SMRUfiles(k).name)
end

%% Step 2: Load, prep file, and DA
clear
file1=dir('*tdr_clean.csv'); %SMRU tag files should end in "tdr_clean.csv"
file2=dir('*Archive.csv'); %WC files should end in "Archive.csv"
file3=dir('*tdr.csv'); %kami tag files should end in "tdr.csv"
file=[file1; file2;file3];
clear file1 file2 file3
load('MetaData.mat');

for k=1:length(file)
    %Find start and end time for each deployment in MetaData using TOPPID
    TOPPID=str2double(strtok(file(k).name,'_'));
    row=find(MetaDataAll.TOPPID==TOPPID);
    Start=MetaDataAll.DepartDate(row);
    End=MetaDataAll.ArriveDate(row);
    
    change_format_DA_V4_2(file(k).name,Start,End,TOPPID);
end

%% Step 3: Subsample to 8 seconds and DA
clear
file=dir('*full.csv');
fileDA=dir('*DAstring.txt');
fileZOC=dir('*full_iknos_rawzoc_data.csv');

for k=1:length(file)
    TOPPID=str2double(strtok(file(k).name,'_'));
    subsample_DA_V4_2(file(k).name, fileDA(k).name, fileZOC(k).name, TOPPID)
end
