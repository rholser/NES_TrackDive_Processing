%Created by: Rachel Holser (rholser@ucsc.edu) and Arina Favilla
%(afavilla@ucsc.edu)
%Created on: 24-Aug-2022
%Last modified: 01-Dec-2022
%
%Script compiles filenames of all data files to be loaded into netCDF
%files. Creates separate table for each data type for ease of organization.
%TDR order determined based on data quality, completeness, and tag type.
clear
load('MetaData.mat')

%% TrackFoieGrasFiles: TOPPID, foieGras filename

%Preallocate space and format table
TrackFoieGrasFiles=NaN(size(MetaDataAll,1),2);
TrackFoieGrasFiles=array2table(TrackFoieGrasFiles,'VariableNames',{'TOPPID','filename'});
TrackFoieGrasFiles.filename=string(TrackFoieGrasFiles.filename);

%Find all files with foieGras_crw in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\**\*foieGras_crw.csv');
for i=1:size(files,1)
    %Pull TOPPID directly from filename
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        TrackFoieGrasFiles.TOPPID(i)=str2double(strtok(files(i).name,'_'));
        TrackFoieGrasFiles.filename(i)=strcat(files(i).folder,'\',files(i).name);
    end
end

%Remove extra rows in table
TrackFoieGrasFiles=sortrows(TrackFoieGrasFiles);
TrackFoieGrasFiles(isnan(TrackFoieGrasFiles.TOPPID),:)=[];
clear files

%% ArgosFiles: TOPPID, raw argos filename

%Preallocate space and format table
ArgosFiles=NaN(size(MetaDataAll,1),2);
ArgosFiles=array2table(ArgosFiles,'VariableNames',{'TOPPID','filename'});
ArgosFiles.filename=string(ArgosFiles.filename);

%Find all files with RawArgos in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\**\*RawArgos.csv');
for i=1:size(files,1)
    %Pull TOPPID directly from filename
    ArgosFiles.TOPPID(i)=str2double(strtok(files(i).name,'_'));
    ArgosFiles.filename(i)=files(i).name;
end

%Remove extra rows in table
ArgosFiles=sortrows(ArgosFiles);
ArgosFiles(isnan(ArgosFiles.TOPPID),:)=[];
clear files

%% GPSFiles: TOPPID, raw GPS filename

%Preallocate space and format table
GPSFiles=NaN(size(MetaDataAll,1),2);
GPSFiles=array2table(GPSFiles,'VariableNames',{'TOPPID','filename'});
GPSFiles.filename=string(GPSFiles.filename);

%Find all files with FastGPS in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\**\*FastGPS.csv');
for i=1:size(files,1)
    %Pull TOPPID directly from filename
    GPSFiles.TOPPID(i)=str2double(strtok(files(i).name,'_'));
    GPSFiles.filename(i)=files(i).name;
end

%Remove extra rows in table
GPSFiles=sortrows(GPSFiles);
GPSFiles(isnan(GPSFiles.TOPPID),:)=[];
clear files

%% TrackCleanFiles: TOPPID, clean pre-processed track files

%Preallocate space and format table
TrackCleanFiles=NaN(size(MetaDataAll,1),2);
TrackCleanFiles=array2table(TrackCleanFiles,'VariableNames',{'TOPPID','filename'});
TrackCleanFiles.filename=string(TrackCleanFiles.filename);

%Find all files with raw_pre_foieGras in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\**\*raw_pre_foieGras.csv');
for i=1:size(files,1)
    %Pull TOPPID directly from filename
    TrackCleanFiles.TOPPID(i)=str2double(strtok(files(i).name,'_'));
    TrackCleanFiles.filename(i)=files(i).name;
end

%Remove extra rows in table
TrackCleanFiles=sortrows(TrackCleanFiles);
TrackCleanFiles(isnan(TrackCleanFiles.TOPPID),:)=[];
clear files

%% TDRRawFiles: TOPPID, raw data filename

%Preallocate space and format table
TDRRawFiles=NaN(size(MetaDataAll,1),2);
TDRRawFiles=array2table(TDRRawFiles,'VariableNames',{'TOPPID','filename'});
TDRRawFiles.filename=string(TDRRawFiles.filename);

%Find all files with Archive in filename
files1=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*Archive.csv');
%Find all files with tdr_raw in filename
files2=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_tdr_raw.csv');
%Find all files with Kami_tdr in filename
files3=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_Kami_tdr.csv');
%Find all files with Stroke_tdr in filename
files4=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_Stroke_tdr.csv');
files=[files1; files2; files3; files4];
for i=1:size(files,1)
    %Check if file is for TDR1ID in TagMetaDataAll
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        if sum(strfind(files(i).name,TagMetaDataAll.TDR1ID(TagMetaDataAll.TOPPID==TOPPID)),...
                strfind(files(i).name,TagMetaDataAll.TDR1Type(TagMetaDataAll.TOPPID==TOPPID)))>=1 
            TDRRawFiles.filename(i)=files(i).name;    
            %Pull TOPPID directly from filename
            TDRRawFiles.TOPPID(i)=TOPPID;
        end 
    end
    clear TOPPID
end

%Sort by TOPPID and remove extra rows in table
TDRRawFiles=sortrows(TDRRawFiles);
TDRRawFiles(isnan(TDRRawFiles.TOPPID),:)=[];
clear files files1 files2 files3 files4

%% TDRCleanFiles: TOPPID, pre-processed filename (*_DAprep_full.csv)

%Preallocate space and format table
TDRCleanFiles=NaN(size(MetaDataAll,1),2);
TDRCleanFiles=array2table(TDRCleanFiles,'VariableNames',{'TOPPID','filename'});
TDRCleanFiles.filename=string(TDRCleanFiles.filename);

%Find all files with _full in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_full.csv');
for i=1:size(files,1)
    %Pull TOPPID directly from filename
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        %Check if file is for TDR1ID in TagMetaDataAll
        if sum(strfind(files(i).name,TagMetaDataAll.TDR1ID(TagMetaDataAll.TOPPID==TOPPID)),...
                strfind(files(i).name,TagMetaDataAll.TDR1Type(TagMetaDataAll.TOPPID==TOPPID)))>=1 
            TDRCleanFiles.filename(i)=files(i).name;    
            TDRCleanFiles.TOPPID(i)=TOPPID;
        end 
    end
    clear TOPPID
end

%Remove extra rows in table
TDRCleanFiles=sortrows(TDRCleanFiles);
TDRCleanFiles(isnan(TDRCleanFiles.TOPPID),:)=[];
clear files

%% TDRZOCFiles: TOPPID, ZOC output filename (*_full_iknos_raw.csv)

%Preallocate space and format table
TDRZOCFiles=NaN(size(MetaDataAll,1),2);
TDRZOCFiles=array2table(TDRZOCFiles,'VariableNames',{'TOPPID','filename'});
TDRZOCFiles.filename=string(TDRZOCFiles.filename);

%Find all files with _full_iknos_raw_data in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_full_iknos_raw_data.csv');
for i=1:size(files,1)
   %Pull TOPPID directly from filename
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        %Check if file is for TDR1ID in TagMetaDataAll
        if sum(strfind(files(i).name,TagMetaDataAll.TDR1ID(TagMetaDataAll.TOPPID==TOPPID)),...
                strfind(files(i).name,TagMetaDataAll.TDR1Type(TagMetaDataAll.TOPPID==TOPPID)))>=1 
            TDRZOCFiles.filename(i)=files(i).name;    
            TDRZOCFiles.TOPPID(i)=TOPPID;
        end 
    end
    clear TOPPID
end

%Remove extra rows in table
TDRZOCFiles=sortrows(TDRZOCFiles);
TDRZOCFiles(isnan(TDRZOCFiles.TOPPID),:)=[];
clear files

%% TDRDiveStatFiles: TOPPID, Dive Stat filename (_full_iknos_DiveStat.csv)

%Preallocate space and format table
TDRDiveStatFiles=NaN(size(MetaDataAll,1),2);
TDRDiveStatFiles=array2table(TDRDiveStatFiles,'VariableNames',{'TOPPID','filename'});
TDRDiveStatFiles.filename=string(TDRDiveStatFiles.filename);

%Find all files with _full_iknos_DiveStat in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_full_iknos_DiveStat.csv');
for i=1:size(files,1)
   %Pull TOPPID directly from filename
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        %Check if file is for TDR1ID in TagMetaDataAll
        if sum(strfind(files(i).name,TagMetaDataAll.TDR1ID(TagMetaDataAll.TOPPID==TOPPID)),...
                strfind(files(i).name,TagMetaDataAll.TDR1Type(TagMetaDataAll.TOPPID==TOPPID)))>=1 
            TDRDiveStatFiles.filename(i)=files(i).name;    
            TDRDiveStatFiles.TOPPID(i)=TOPPID;
        end 
    end
    clear TOPPID
end

%Remove extra rows in table
TDRDiveStatFiles=sortrows(TDRDiveStatFiles);
TDRDiveStatFiles(isnan(TDRDiveStatFiles.TOPPID),:)=[];
clear files

%% TDRSubDiveStatFiles: TOPPID, Dive Stat filename (_SubSample_iknos_DiveStat.csv)

%Preallocate space and format table
TDRSubDiveStatFiles=NaN(size(MetaDataAll,1),2);
TDRSubDiveStatFiles=array2table(TDRSubDiveStatFiles,'VariableNames',{'TOPPID','filename'});
TDRSubDiveStatFiles.filename=string(TDRSubDiveStatFiles.filename);

%Find all files with _SubSample_iknos_DiveStat in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_SubSample_iknos_DiveStat.csv');
for i=1:size(files,1)
   %Pull TOPPID directly from filename
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        %Check if file is for TDR1ID in TagMetaDataAll
        if sum(strfind(files(i).name,TagMetaDataAll.TDR1ID(TagMetaDataAll.TOPPID==TOPPID)),...
                strfind(files(i).name,TagMetaDataAll.TDR1Type(TagMetaDataAll.TOPPID==TOPPID)))>=1 
            TDRSubDiveStatFiles.filename(i)=files(i).name;    
            TDRSubDiveStatFiles.TOPPID(i)=TOPPID;
        end 
    end
    clear TOPPID
end

%Remove extra rows in table
TDRSubDiveStatFiles=sortrows(TDRSubDiveStatFiles);
TDRSubDiveStatFiles(isnan(TDRSubDiveStatFiles.TOPPID),:)=[];
clear files

%% TDR2RawFiles: TOPPID, raw data filename

%Preallocate space and format table
TDR2RawFiles=NaN(size(MetaDataAll,1),2);
TDR2RawFiles=array2table(TDR2RawFiles,'VariableNames',{'TOPPID','filename'});
TDR2RawFiles.filename=string(TDR2RawFiles.filename);

%Find all files with Archive in filename
files1=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*Archive.csv');
%Find all files with tdr_raw in filename
files2=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_tdr_raw.csv');
%Find all files with Kami_tdr in filename
files3=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_Kami_tdr.csv');
%Find all files with Stroke_tdr in filename
files4=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_Stroke_tdr.csv');
files=[files1; files2; files3; files4];
for i=1:size(files,1)
    %Check if file is for TDR1ID in TagMetaDataAll
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        if sum(strfind(files(i).name,TagMetaDataAll.TDR2ID(TagMetaDataAll.TOPPID==TOPPID)),...
                strfind(files(i).name,TagMetaDataAll.TDR2Type(TagMetaDataAll.TOPPID==TOPPID)))>=1 
            TDR2RawFiles.filename(i)=files(i).name;    
            %Pull TOPPID directly from filename
            TDR2RawFiles.TOPPID(i)=TOPPID;
        end 
    end
    clear TOPPID
end

%Sort by TOPPID and remove extra rows in table
TDR2RawFiles=sortrows(TDR2RawFiles);
TDR2RawFiles(isnan(TDR2RawFiles.TOPPID),:)=[];
clear files

%% TDR2CleanFiles: TOPPID, pre-processed filename (*_DAprep_full.csv)

%Preallocate space and format table
TDR2CleanFiles=NaN(size(MetaDataAll,1),2);
TDR2CleanFiles=array2table(TDR2CleanFiles,'VariableNames',{'TOPPID','filename'});
TDR2CleanFiles.filename=string(TDR2CleanFiles.filename);

%Find all files with _full in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_full.csv');
for i=1:size(files,1)
    %Pull TOPPID directly from filename
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        %Check if file is for TDR1ID in TagMetaDataAll
        if sum(strfind(files(i).name,TagMetaDataAll.TDR2ID(TagMetaDataAll.TOPPID==TOPPID)),...
                strfind(files(i).name,TagMetaDataAll.TDR2Type(TagMetaDataAll.TOPPID==TOPPID)))>=1 
            TDR2CleanFiles.filename(i)=files(i).name;    
            TDR2CleanFiles.TOPPID(i)=TOPPID;
        end 
    end
    clear TOPPID
end

%Remove extra rows in table
TDR2CleanFiles=sortrows(TDR2CleanFiles);
TDR2CleanFiles(isnan(TDR2CleanFiles.TOPPID),:)=[];
clear files

%% TDR2ZOCFiles: TOPPID, ZOC output filename (*_full_iknos_raw.csv)

%Preallocate space and format table
TDR2ZOCFiles=NaN(size(MetaDataAll,1),2);
TDR2ZOCFiles=array2table(TDR2ZOCFiles,'VariableNames',{'TOPPID','filename'});
TDR2ZOCFiles.filename=string(TDR2ZOCFiles.filename);

%Find all files with _full_iknos_raw_data in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_full_iknos_raw_data.csv');
for i=1:size(files,1)
   %Pull TOPPID directly from filename
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        %Check if file is for TDR1ID in TagMetaDataAll
        if sum(strfind(files(i).name,TagMetaDataAll.TDR2ID(TagMetaDataAll.TOPPID==TOPPID)),...
                strfind(files(i).name,TagMetaDataAll.TDR2Type(TagMetaDataAll.TOPPID==TOPPID)))>=1 
            TDR2ZOCFiles.filename(i)=files(i).name;    
            TDR2ZOCFiles.TOPPID(i)=TOPPID;
        end 
    end
    clear TOPPID
end

%Remove extra rows in table
TDR2ZOCFiles=sortrows(TDR2ZOCFiles);
TDR2ZOCFiles(isnan(TDR2ZOCFiles.TOPPID),:)=[];
clear files

%% TDR2DiveStatFiles: TOPPID, Dive Stat filename (_full_iknos_DiveStat.csv)

%Preallocate space and format table
TDR2DiveStatFiles=NaN(size(MetaDataAll,1),2);
TDR2DiveStatFiles=array2table(TDR2DiveStatFiles,'VariableNames',{'TOPPID','filename'});
TDR2DiveStatFiles.filename=string(TDR2DiveStatFiles.filename);

%Find all files with _full_iknos_DiveStat in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_full_iknos_DiveStat.csv');
for i=1:size(files,1)
   %Pull TOPPID directly from filename
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        %Check if file is for TDR2ID in TagMetaDataAll
        if sum(strfind(files(i).name,TagMetaDataAll.TDR2ID(TagMetaDataAll.TOPPID==TOPPID)),...
                strfind(files(i).name,TagMetaDataAll.TDR2Type(TagMetaDataAll.TOPPID==TOPPID)))>=1 
            TDR2DiveStatFiles.filename(i)=files(i).name;    
            TDR2DiveStatFiles.TOPPID(i)=TOPPID;
        end 
    end
    clear TOPPID
end

%Remove extra rows in table
TDR2DiveStatFiles=sortrows(TDR2DiveStatFiles);
TDR2DiveStatFiles(isnan(TDR2DiveStatFiles.TOPPID),:)=[];
clear files

%% TDR2SubDiveStatFiles: TOPPID, Dive Stat filename (_SubSample_iknos_DiveStat.csv)

%Preallocate space and format table
TDR2SubDiveStatFiles=NaN(size(MetaDataAll,1),2);
TDR2SubDiveStatFiles=array2table(TDR2SubDiveStatFiles,'VariableNames',{'TOPPID','filename'});
TDR2SubDiveStatFiles.filename=string(TDR2SubDiveStatFiles.filename);

%Find all files with _full_iknos_DiveStat in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_SubSample_iknos_DiveStat.csv');
for i=1:size(files,1)
   %Pull TOPPID directly from filename
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        %Check if file is for TDR2ID in TagMetaDataAll
        if sum(strfind(files(i).name,TagMetaDataAll.TDR2ID(TagMetaDataAll.TOPPID==TOPPID)),...
                strfind(files(i).name,TagMetaDataAll.TDR2Type(TagMetaDataAll.TOPPID==TOPPID)))>=1 
            TDR2SubDiveStatFiles.filename(i)=files(i).name;    
            TDR2SubDiveStatFiles.TOPPID(i)=TOPPID;
        end 
    end
    clear TOPPID
end

%Remove extra rows in table
TDR2SubDiveStatFiles=sortrows(TDR2SubDiveStatFiles);
TDR2SubDiveStatFiles(isnan(TDR2SubDiveStatFiles.TOPPID),:)=[];
clear files

%% TDR3RawFiles: TOPPID, raw data filename

%Preallocate space and format table
TDR3RawFiles=NaN(size(MetaDataAll,1),2);
TDR3RawFiles=array2table(TDR3RawFiles,'VariableNames',{'TOPPID','filename'});
TDR3RawFiles.filename=string(TDR3RawFiles.filename);

%Find all files with Archive in filename
files1=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*Archive.csv');
%Find all files with tdr_raw in filename
files2=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_tdr_raw.csv');
%Find all files with Kami_tdr in filename
files3=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_Kami_tdr.csv');
%Find all files with Stroke_tdr in filename
files4=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_Stroke_tdr.csv');
files=[files1; files2; files3; files4];
for i=1:size(files,1)
    %Check if file is for TDR3ID in TagMetaDataAll
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        if sum(strfind(files(i).name,TagMetaDataAll.TDR3ID(TagMetaDataAll.TOPPID==TOPPID)),...
                strfind(files(i).name,TagMetaDataAll.TDR3Type(TagMetaDataAll.TOPPID==TOPPID)))>=1 
            TDR3RawFiles.filename(i)=files(i).name;    
            %Pull TOPPID directly from filename
            TDR3RawFiles.TOPPID(i)=TOPPID;
        end 
    end
    clear TOPPID
end

%Sort by TOPPID and remove extra rows in table
TDR3RawFiles=sortrows(TDR3RawFiles);
TDR3RawFiles(isnan(TDR3RawFiles.TOPPID),:)=[];
clear files

%% TDR3CleanFiles: TOPPID, pre-processed filename (*_DAprep_full.csv)

%Preallocate space and format table
TDR3CleanFiles=NaN(size(MetaDataAll,1),2);
TDR3CleanFiles=array2table(TDR3CleanFiles,'VariableNames',{'TOPPID','filename'});
TDR3CleanFiles.filename=string(TDR3CleanFiles.filename);

%Find all files with _full in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_full.csv');
for i=1:size(files,1)
    %Pull TOPPID directly from filename
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        %Check if file is for TDR3ID in TagMetaDataAll
        if sum(strfind(files(i).name,TagMetaDataAll.TDR3ID(TagMetaDataAll.TOPPID==TOPPID)),...
                strfind(files(i).name,TagMetaDataAll.TDR3Type(TagMetaDataAll.TOPPID==TOPPID)))>=1 
            TDR3CleanFiles.filename(i)=files(i).name;    
            TDR3CleanFiles.TOPPID(i)=TOPPID;
        end 
    end
    clear TOPPID
end

%Remove extra rows in table
TDR3CleanFiles=sortrows(TDR3CleanFiles);
TDR3CleanFiles(isnan(TDR3CleanFiles.TOPPID),:)=[];
clear files

%% TDR3ZOCFiles: TOPPID, ZOC output filename (*_full_iknos_raw.csv)

%Preallocate space and format table
TDR3ZOCFiles=NaN(size(MetaDataAll,1),2);
TDR3ZOCFiles=array2table(TDR3ZOCFiles,'VariableNames',{'TOPPID','filename'});
TDR3ZOCFiles.filename=string(TDR3ZOCFiles.filename);

%Find all files with _full_iknos_raw_data in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_full_iknos_raw_data.csv');
for i=1:size(files,1)
   %Pull TOPPID directly from filename
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        %Check if file is for TDR3ID in TagMetaDataAll
        if sum(strfind(files(i).name,TagMetaDataAll.TDR3ID(TagMetaDataAll.TOPPID==TOPPID)),...
                strfind(files(i).name,TagMetaDataAll.TDR3Type(TagMetaDataAll.TOPPID==TOPPID)))>=1 
            TDR3ZOCFiles.filename(i)=files(i).name;    
            TDR3ZOCFiles.TOPPID(i)=TOPPID;
        end 
    end
    clear TOPPID
end

%Remove extra rows in table
TDR3ZOCFiles=sortrows(TDR3ZOCFiles);
TDR3ZOCFiles(isnan(TDR3ZOCFiles.TOPPID),:)=[];
clear files

%% TDR3DiveStatFiles: TOPPID, Dive Stat filename (_full_iknos_DiveStat.csv)

%Preallocate space and format table
TDR3DiveStatFiles=NaN(size(MetaDataAll,1),2);
TDR3DiveStatFiles=array2table(TDR3DiveStatFiles,'VariableNames',{'TOPPID','filename'});
TDR3DiveStatFiles.filename=string(TDR3DiveStatFiles.filename);

%Find all files with _full_iknos_DiveStat in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_full_iknos_DiveStat.csv');
for i=1:size(files,1)
   %Pull TOPPID directly from filename
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        %Check if file is for TDR3ID in TagMetaDataAll
        if sum(strfind(files(i).name,TagMetaDataAll.TDR3ID(TagMetaDataAll.TOPPID==TOPPID)),...
                strfind(files(i).name,TagMetaDataAll.TDR3Type(TagMetaDataAll.TOPPID==TOPPID)))>=1 
            TDR3DiveStatFiles.filename(i)=files(i).name;    
            TDR3DiveStatFiles.TOPPID(i)=TOPPID;
        end 
    end
    clear TOPPID
end

%Remove extra rows in table
TDR3DiveStatFiles=sortrows(TDR3DiveStatFiles);
TDR3DiveStatFiles(isnan(TDR3DiveStatFiles.TOPPID),:)=[];
clear files

%% TDR3SubDiveStatFiles: TOPPID, Dive Stat filename (_SubSample_iknos_DiveStat.csv)

%Preallocate space and format table
TDR3SubDiveStatFiles=NaN(size(MetaDataAll,1),2);
TDR3SubDiveStatFiles=array2table(TDR3SubDiveStatFiles,'VariableNames',{'TOPPID','filename'});
TDR3SubDiveStatFiles.filename=string(TDR3SubDiveStatFiles.filename);

%Find all files with _full_iknos_DiveStat in filename
files=dir('F:\Data\Eseal_Data\Tracking Diving 2004-2020\TDRs\**\*_SubSample_iknos_DiveStat.csv');
for i=1:size(files,1)
   %Pull TOPPID directly from filename
    TOPPID=str2double(strtok(files(i).name,'_'));
    if sum(TagMetaDataAll.TOPPID==TOPPID)>0
        %Check if file is for TDR3ID in TagMetaDataAll
        if sum(strfind(files(i).name,TagMetaDataAll.TDR3ID(TagMetaDataAll.TOPPID==TOPPID)),...
                strfind(files(i).name,TagMetaDataAll.TDR3Type(TagMetaDataAll.TOPPID==TOPPID)))>=1 
            TDR3SubDiveStatFiles.filename(i)=files(i).name;    
            TDR3SubDiveStatFiles.TOPPID(i)=TOPPID;
        end 
    end
    clear TOPPID
end

%Remove extra rows in table
TDR3SubDiveStatFiles=sortrows(TDR3SubDiveStatFiles);
TDR3SubDiveStatFiles(isnan(TDR3SubDiveStatFiles.TOPPID),:)=[];
clear files

save('All_Filenames.mat','TrackFoieGrasFiles','ArgosFiles','GPSFiles','TrackCleanFiles',...
    'TDRRawFiles','TDRCleanFiles','TDRZOCFiles','TDRDiveStatFiles','TDRSubDiveStatFiles',...
    'TDR2RawFiles','TDR2CleanFiles','TDR2ZOCFiles','TDR2DiveStatFiles','TDR2SubDiveStatFiles',...
    'TDR3RawFiles','TDR3CleanFiles','TDR3ZOCFiles','TDR3DiveStatFiles','TDR3SubDiveStatFiles');
