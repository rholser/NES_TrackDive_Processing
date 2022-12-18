%Created by: Rachel Holser (rholser@ucsc.edu)
%Created on: 24-Aug-2022
%Last modified: 

%Script compiles filenames of all data files to be loaded into netCDF
%files. Creates separate table for each data type for ease of organization.
%TDR order determined based on data quality, completeness, and tag type.

load('MetaData.mat')

%% TrackFoieGrasFiles: TOPPID, foieGras filename

%Preallocate space and format table
TrackFoieGrasFiles=NaN(size(MetaDataAll,1),2);
TrackFoieGrasFiles=array2table(TrackFoieGrasFiles,'VariableNames',{'TOPPID','filename'});
TrackFoieGrasFiles.filename=string(TrackFoieGrasFiles.filename);

%Find all files with foieGras in filename
files=dir('*foieGras*.csv');
for i=1:size(files,1)
    %Pull TOPPID directly from filename
    TrackFoieGrasFiles.TOPPID(i)=str2num(strtok(files(i).name,'_'));
    TrackFoieGrasFiles.filename(i)=files(i).name;
end

%Remove extra rows in table
TrackFoieGrasFiles(isnan(TrackFoieGrasFiles.TOPPID),:)=[];
clear files

%% ArgosFiles: TOPPID, raw argos filename


%% GPSFiles: TOPPID, raw GPS filename


%% TrackCleanFiles: TOPPID, clean pre-processed track files

%% TDR1RawFiles: TOPPID, raw data filename

%% TDRCleanFiles: TOPPID, pre-processed filename (*_DAprep_full.csv)

%Preallocate space and format table
TDRCleanFiles=NaN(size(MetaDataAll,1),2);
TDRCleanFiles=array2table(TDRCleanFiles,'VariableNames',{'TOPPID','filename'});
TDRCleanFiles.filename=string(TDRCleanFiles.filename);

%Find all files with foieGras in filename
files=dir('*_full.csv');
for i=1:size(files,1)
    %Pull TOPPID directly from filename
    TDRCleanFiles.TOPPID(i)=str2num(strtok(files(i).name,'_'));
    TDRCleanFiles.filename(i)=files(i).name;
end

%Remove extra rows in table
TDRCleanFiles(isnan(TDRCleanFiles.TOPPID),:)=[];
clear files

%% TDRZOCFiles: TOPPID, ZOC output filename (*_full_iknos_raw.csv)

%Preallocate space and format table
TDRZOCFiles=NaN(size(MetaDataAll,1),2);
TDRZOCFiles=array2table(TDRZOCFiles,'VariableNames',{'TOPPID','filename'});
TDRZOCFiles.filename=string(TDRZOCFiles.filename);

%Find all files with foieGras in filename
files=dir('*_full_iknos_raw_data.csv');
for i=1:size(files,1)
    %Pull TOPPID directly from filename
    TDRZOCFiles.TOPPID(i)=str2num(strtok(files(i).name,'_'));
    TDRZOCFiles.filename(i)=files(i).name;
end

%Remove extra rows in table
TDRZOCFiles(isnan(TDRZOCFiles.TOPPID),:)=[];
clear files

%% TDRDiveStatFiles: TOPPID, Dive Stat filename (_full_iknos_DiveStat.csv)

%Preallocate space and format table
TDRDiveStatFiles=NaN(size(MetaDataAll,1),2);
TDRDiveStatFiles=array2table(TDRDiveStatFiles,'VariableNames',{'TOPPID','filename'});
TDRDiveStatFiles.filename=string(TDRDiveStatFiles.filename);

%Find all files with foieGras in filename
files=dir('*_full_iknos_DiveStat.csv');
for i=1:size(files,1)
    %Pull TOPPID directly from filename
    TDRDiveStatFiles.TOPPID(i)=str2num(strtok(files(i).name,'_'));
    TDRDiveStatFiles.filename(i)=files(i).name;
end

%Remove extra rows in table
TDRDiveStatFiles(isnan(TDRDiveStatFiles.TOPPID),:)=[];
clear files


%% TDRSubCleanFiles: TOPPID, pre-processed filename (*_SubSample.csv)

%Preallocate space and format table
TDRSubCleanFiles=NaN(size(MetaDataAll,1),2);
TDRSubCleanFiles=array2table(TDRSubCleanFiles,'VariableNames',{'TOPPID','filename'});
TDRSubCleanFiles.filename=string(TDRSubCleanFiles.filename);

%Find all files with foieGras in filename
files=dir('*_SubSample.csv');
for i=1:size(files,1)
    %Pull TOPPID directly from filename
    TDRSubCleanFiles.TOPPID(i)=str2num(strtok(files(i).name,'_'));
    TDRSubCleanFiles.filename(i)=files(i).name;
end

%Remove extra rows in table
TDRSubCleanFiles(isnan(TDRSubCleanFiles.TOPPID),:)=[];
clear files

%% TDRSubZOCFiles: TOPPID, ZOC output filename (*_SubSample_iknos_raw.csv)
%Preallocate space and format table
TDRSubZOCFiles=NaN(size(MetaDataAll,1),2);
TDRSubZOCFiles=array2table(TDRSubZOCFiles,'VariableNames',{'TOPPID','filename'});
TDRSubZOCFiles.filename=string(TDRSubZOCFiles.filename);

%Find all files with foieGras in filename
files=dir('*_SubSample_iknos_raw_data.csv');
for i=1:size(files,1)
    %Pull TOPPID directly from filename
    TDRSubZOCFiles.TOPPID(i)=str2num(strtok(files(i).name,'_'));
    TDRSubZOCFiles.filename(i)=files(i).name;
end

%Remove extra rows in table
TDRSubZOCFiles(isnan(TDRSubZOCFiles.TOPPID),:)=[];
clear files
%% TDRSubDiveStatFiles: TOPPID, Dive Stat filename (_SubSample_iknos_DiveStat.csv)

%Preallocate space and format table
TDRSubDiveStatFiles=NaN(size(MetaDataAll,1),2);
TDRSubDiveStatFiles=array2table(TDRSubDiveStatFiles,'VariableNames',{'TOPPID','filename'});
TDRSubDiveStatFiles.filename=string(TDRSubDiveStatFiles.filename);

%Find all files with foieGras in filename
files=dir('*_SubSample_iknos_DiveStat.csv');
for i=1:size(files,1)
    %Pull TOPPID directly from filename
    TDRSubDiveStatFiles.TOPPID(i)=str2num(strtok(files(i).name,'_'));
    TDRSubDiveStatFiles.filename(i)=files(i).name;
end

%Remove extra rows in table
TDRSubDiveStatFiles(isnan(TDRSubDiveStatFiles.TOPPID),:)=[];
clear files

%% TDR2RawFiles: TOPPID, raw data filename

%% TDR2CleanFiles: TOPPID, pre-processed filename (*_DAprep_full.csv)

%% TDR2ZOCFiles: TOPPID, ZOC output filename (*_full_iknos_raw.csv)

%% TDR2DiveStatFiles: TOPPID, Dive Stat filename (_full_iknos_DiveStat.csv)
%TDR2SubCleanFiles: TOPPID, pre-processed filename (*_SubSample.csv)
%TDR2SubZOCFiles: TOPPID, ZOC output filename (*_SubSample_iknos_raw.csv)
%TDR2SubDiveStatFiles: TOPPID, Dive Stat filename (_SubSample_iknos_DiveStat.csv)

%TDR3RawFiles: TOPPID, raw data filename
%TDR3CleanFiles: TOPPID, pre-processed filename (*_DAprep_full.csv)
%TDR3ZOCFiles: TOPPID, ZOC output filename (*_full_iknos_raw.csv)
%TDR3DiveStatFiles: TOPPID, Dive Stat filename (_full_iknos_DiveStat.csv)
%TDR3SubCleanFiles: TOPPID, pre-processed filename (*_SubSample.csv)
%TDR3SubZOCFiles: TOPPID, ZOC output filename (*_SubSample_iknos_raw.csv)
%TDR3SubDiveStatFiles: TOPPID, Dive Stat filename (_SubSample_iknos_DiveStat.csv)

save('All_Filenames.mat','TrackFoieGrasFiles','TDRCleanFiles','TDRZOCFiles','TDRDiveStatFiles',...
    'TDRSubCleanFiles','TDRSubZOCFiles','TDRSubDiveStatFiles');