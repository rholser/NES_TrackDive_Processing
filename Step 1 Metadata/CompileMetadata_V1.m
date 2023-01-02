%Compile_Metadata is the first step in processing elephant seal biologging data. It complies metadata from 
% .csv files into a single .mat file (MetaData.mat) that is used throughout all processing steps and
% in final file assembly (both netCDF and mat file formats).
%
%Expected input files: startstop.csv (required for next steps)
%                       tagmetadata.csv (required for next steps)
%                       foragingsuccess.csv (optional)
%
%Created by: Rachel Holser (rholser@ucsc.edu)
%
%V1
% Update Log:
% 31-Dec-2022 - Updates imports for new startstop and tagmetadata fields

clear
%% read Froaging Success
% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 30);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Year",... %1
    "Season",...  %2
    "ID",...%3
    "TOPPID",...%4
    "DeployDate",...%5
    "DeployMass",...%6
    "DeployAdipose",...%7
    "DepartDate",...%8
    "DepartDaysOnShore",...%9
    "DepartMassCorrection",...%10
    "DepartCalcMass",...%11
    "DepartAdiposeCorr",...%12
    "DepartCalcAdipose",...%13
    "RecoverDate",...%14
    "RecoverMass",...%15
    "RecoverAdipose",...%16
    "ArrivalDate",...%17
    "ArrivalDaysOnShore",...%18
    "ArrivalMassCorrection",...%19
    "ArrivalCalcAdipose",...%22
    "ArrivalAdiposeCorr",...%21
    "ArrivalCalcMass",...%20
    "DaysAtSea",...%23
    "PupMass",...%24
    "CalcMassGain",...%25
    "MassGainRate",...%26
    "MassGainPercent",...%27
    "AdiposeGain",...%28
    "LeanGain",...%29
    "EnergyGain",...%30
    "EnergyGainRate",...%31
    "PercentAdiposeOfMassGain",...%32
    "TBGE",...%33
    "TBGEGainPercent"];%34
opts.VariableTypes = ["double",...
    "char",...%2
    "string",...%3
    "double",...%4
    "char",...%5
    "double",...%6
    "double",...%7
    "char",...%8
    "double",...%9
    "double",...%10
    "double",...%11
    "double",...%12
    "double",...%13
    "char",...%14
    "double",...%15
    "double",...%16
    "char",...%17
    "double",...%18
    "double",...%19
    "double",...%20
    "double",...%21
    "double",...%22
    "double",...%23
    "double",...%24
    "double",...%25
    "double",...%26
    "double",...%27
    "double",...%28
    "double",...%29
    "double",...%30
    "double",...%31
    "double",...%32
    "double",...%33
    "double"];%34

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["ID", "DeployDate", "DepartDate", "RecoverDate", "ArrivalDate"],...
    "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Season", "ID", "DeployDate", "DepartDate", "RecoverDate", "ArrivalDate"],...
    "EmptyFieldRule", "auto");

% Import the data
ForagingSuccessAll = readtable("foragingsuccess.csv", opts);

% Clear temporary variables
clear opts

%% Read start/stop data
MetaDataAll=readtable('startstop_female_datapaper.csv');

%% Read tagging metadata
% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 35);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["SealID", "TOPPID", "SatTagManufacturer", "SatTagType", "SatTagID", "SatTagPTT",...
    "SatTagQC", "SatTagComment", "TDR1Manufacturer", "TDR1Type", "TDR1ID", "TDR1Loc", "TDR1QC",...
    "TDR1Comments", "TDR1Manufacturer1", "TDR2Type", "TDR2ID", "TDR2Loc", "TDR2QC", "TDR2Comments",...
    "TDR1Manufacturer2", "TDR3Type", "TDR3ID", "TDR3Loc", "TDR3QC", "TDR3Comment", "Other1", "Other1Loc",...
    "Other1Comment", "Other2", "Other2Loc", "Other2Comment", "Other3", "Other3Loc", "Other3Comment"];
opts.VariableTypes = ["string", "double", "string", "string", "string", "double", "string", "string",...
    "string", "string", "string", "string", "double", "string", "string", "string", "string", "string",...
    "double", "string", "string", "string", "string", "string", "double", "string", "string", "string",...
    "string", "string", "string", "string", "string", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["SealID", "SatTagManufacturer", "SatTagType", "SatTagID", "SatTagQC",...
    "SatTagComment", "TDR1Manufacturer", "TDR1Type", "TDR1ID", "TDR1Loc", "TDR1Comments",...
    "TDR1Manufacturer1", "TDR2Type", "TDR2ID", "TDR2Loc", "TDR2Comments", "TDR1Manufacturer2", "TDR3Type",...
    "TDR3ID", "TDR3Loc", "TDR3Comment", "Other1", "Other1Loc", "Other1Comment", "Other2", "Other2Loc",...
    "Other2Comment", "Other3", "Other3Loc", "Other3Comment"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["SealID", "SatTagManufacturer", "SatTagType", "SatTagID", "SatTagQC",...
    "SatTagComment", "TDR1Manufacturer", "TDR1Type", "TDR1ID", "TDR1Loc", "TDR1Comments",...
    "TDR1Manufacturer1", "TDR2Type", "TDR2ID", "TDR2Loc", "TDR2Comments", "TDR1Manufacturer2", "TDR3Type",...
    "TDR3ID", "TDR3Loc", "TDR3Comment", "Other1", "Other1Loc", "Other1Comment", "Other2", "Other2Loc",...
    "Other2Comment", "Other3", "Other3Loc", "Other3Comment"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, ["TDR1QC", "TDR2QC", "TDR3QC"], "TrimNonNumeric", true);
opts = setvaropts(opts, ["TDR1QC", "TDR2QC", "TDR3QC"], "ThousandsSeparator", ",");

% Import the data
TagMetaDataAll = readtable("tagmetadata.csv", opts);

% Clear temporary variables
clear opts

%% Save all metadata structure into single .mat file for later use
save('MetaData.mat','MetaDataAll','ForagingSuccessAll','TagMetaDataAll')
