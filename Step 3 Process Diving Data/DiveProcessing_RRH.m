%Rachel Holser (rholser@ucsc.edu)
%Created 18-May-2022
%Updated 22-Oct-2022

%Consolidates all dive processing steps into one script.
%Requires "New IKNOS" toolbox and modified/custom functions and files:
    %For Step 1 (full resolution ZOC and Dive Analysis):
        %DA_data_compiler_RRH.m
        %change_format_DA_RRH.m
        %yt_iknos_DA_RRH.m
        %MetaData.mat
    %For Step 2 (subsample to 8 sec, ZOC and Dive Analysis):
        %DA_data_compiler_RRH.m
        %subsample_and_DA_RRH.m
        %yt_iknos_DA_RRH.m

%Run change_format_DA_RRH. Also Requires function DA_data_compiler_RRH.m

%This process should not be run in parallel (or in multiple instances of
%matlab) as the function writes temporary files - if multiple instances are
%run, the IKNOS DA function will mix tdr records together.

%Step 1 will load SMRU text files and convert to *tdr_raw.csv, then will check and
%correct for broken dives and save as *tdr.csv

%Step 2 will load little leonardo text files and covert to tdr_raw.csv

%Step 3 will truncate dive records to the start and end times designated in
%startstop.csv and loaded into MetaData.mat.

%% Step 1 - SMRU tag data import

SMRUfiles=dir('*tdr.txt');

for k=15:length(SMRUfiles)
    import_smru_tdr_V4(SMRUfiles(k).name)
end


%% Step 3 - Load, prep file, and DA
clear all
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
    
    change_format_DA2_RRH_TV4_2(file(k).name,Start,End,TOPPID);
end

%% Step 2 - Subsample to 8 seconds and DA
clear all
file=dir('*full.csv');
fileDA=dir('*DAstring.txt');

for k=1:length(file)
    subsample_and_DA_RRH_TV4(file(k).name, fileDA(k).name)
end

