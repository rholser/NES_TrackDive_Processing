%Rachel Holser (rholser@ucsc.edu)
%Last Updated: 19-Aug-2022

%Complies relevant metadata into a .mat file for use in eseal data
%processing - MetaData.mat is requires for both file assembly and Appending
%steps.

clear all
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
opts = setvaropts(opts, ["ID", "DeployDate", "DepartDate", "RecoverDate",...
    "ArrivalDate"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Season", "ID", "DeployDate", "DepartDate",...
    "RecoverDate", "ArrivalDate"], "EmptyFieldRule", "auto");

% Import the data
ForagingSuccessAll = readtable("foragingsuccess.csv", opts);

%% Clear temporary variables
clear opts

%% read start/stop data
MetaDataAll=readtable('startstop_female.csv');

%% read tagging metadata
%Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 13);

% Specify range and delimiter of data to import
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["SealID", "TOPPID", "SatTagType", "SatTagID",...
    "SatTagPTT", "SatTagComment", "TDR1Type", "TDR1ID", "TDR1Loc",...
    "TDR1Comment", "TDR2Type", "TDR2ID", "TDR2Loc", "TDR2Comment",...
    "TDR3Type", "TDR3ID", "TDR3Loc", "TDR3Comment", "Other1", "Other1Loc",...
    "Other1Comment", "Other2", "Other2Loc", "Other2Comment", "Other3",...
    "Other3Loc", "Other3Comment"];
opts.VariableTypes = ["string", "double", "string", "string", "string",...
    "string", "string", "string", "string","string", "string", "string",...
    "string",  "string", "string",  "string", "string",  "string", "string",...
    "string", "string", "string", "string", "string", "string", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
% 1. Preserve whitespace in text fields
opts = setvaropts(opts, ["SealID", "SatTagID", "SatTagComment", "TDR1Comment",...
    "TDR2Comment", "TDR3Comment", "Other1", "Other1Loc", "Other1Comment",...
    "Other2", "Other2Loc", "Other2Comment"], "WhitespaceRule", "preserve");
% 2. How to treat empty fields - 'auto' will fill empty fields differently
% depending on data type
opts = setvaropts(opts, ["SealID", "SatTagType", "SatTagID", "SatTagComment",...
    "TDR1Type", "TDR1Loc", "TDR1Comment", "TDR2Type", "TDR2Loc", "TDR2Comment",...
    "TDR3Type", "TDR3Loc", "TDR3Comment", "Other1", "Other1Loc", "Other1Comment",...
    "Other2", "Other2Loc", "Other2Comment"], "EmptyFieldRule", "auto");

% Import the data
TagMetaDataAll = readtable("tagmetadata.csv", opts);

%% Save all metadata structure into single .mat file for later use
save('MetaData.mat','MetaDataAll','ForagingSuccessAll','TagMetaDataAll')
