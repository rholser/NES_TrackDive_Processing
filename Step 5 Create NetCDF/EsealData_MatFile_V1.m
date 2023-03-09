%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Created by: Rachel Holser (rholser@ucsc.edu), modified from P.Robinson's code
%Created on: 02-Jan-2023
%
% Compiles all available tracking, diving, foraging success, and metadata into tables and structures
% in a single .mat file. Uses AniMotum processed tracking data to generate Track_Best and find locations 
% for each dive (DiveLoc_Best). Creates _TV4_alpha.mat file.
%
% Preparation:
%      Process and assemble all tracking and diving data (Steps 1-3)
%      Create metadata.mat (start/stop, foraging success, tag metadata)
%
% IMPORTANT: Tracking data filenames MUST use standard endings to be discovered and imported correctly 
% in this script: *_AniMotum_crw.csv, *Argos_Raw.csv, *Argos_Crawl.csv, *GPS_Raw.csv, *_llgeo_raw.csv
% Simplified tracking data import - Crawl and GPS-only structures extracted from previous .mat files 
% using ExtractTracks.m (under additional tools)
%
% Dive data from multiple sources will be included with different instruments priortized as follows: 
% 1. Mk9 2. Mk10 3. SMRU CTD 4. Others (Kami). This step is dependent on correct documentation/order 
% of TDR instruments in the TagMetaDataAll spreadsheet.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
load MetaData.mat
load All_Filenames.mat

% Create row of NaNs in TagMetaDataAll table for use in cases where tag data aren't available
    TagMetaDataAll=[array2table(nan(1,size(TagMetaDataAll,2)),'variablenames',...
        TagMetaDataAll.Properties.VariableNames);TagMetaDataAll];

% Add a row of NaN's to top of ForagingSuccessAll table for use in cases where foraging success data 
% aren't available. 
    ForagingSuccessAll=[array2table(nan(1,size(ForagingSuccessAll,2)),...
        'variablenames',ForagingSuccessAll.Properties.VariableNames);ForagingSuccessAll];
    folder='D:\Dropbox\MATLAB\Chapter 3\TV4_beta';

for i=16:size(MetaDataAll,1)
 %% Step 1: clear variables and create empty variables for new file   
    clear TOPPID DiveStat DiveType Dive2Stat Dive2Type Dive3Stat Dive3Type Track_Argos_Raw Track_Argos_Crawl...
        Track_GPS_Raw Track_LLGEO_Raw Track_AniMotum Track_Best MetaData ForagingSuccess

    disp([MetaDataAll.FieldID{i} '_' num2str(MetaDataAll.TOPPID(i))])
    
    % Create all empty variables to be populated
    TOPPID=MetaDataAll.TOPPID(i);
    DiveStat=array2table([]);
    DiveType=array2table([]);
    Dive2Stat=array2table([]);
    Dive2Type=array2table([]);
    Dive3Stat=array2table([]);
    Dive3Type=array2table([]);
    Track_Argos_Raw=array2table([]);
    Track_Argos_Crawl=array2table([]);
    Track_GPS_Raw=array2table([]);
    Track_LLGEO_Raw=array2table([]);
    Track_AniMotum=array2table([]);
    Track_Best=array2table([]);
    ForagingSuccess=[];
    MetaData=[];
           
%% Step 2: MetaData

    % Step 2.1: Populate MetaData
    % Copy from MetaDataAll table and convert to structure
    MetaData=table2struct(MetaDataAll(i,:));
    % Create both datenum and datestring for departure and arrival
    MetaData.DepartDateTime=datetime(MetaData.DepartDate);
    MetaData.DepartDate=datenum(MetaData.DepartDate);
    MetaData.ArriveDateTime=datetime(MetaData.ArriveDate);
    MetaData.ArriveDate=datenum(MetaData.ArriveDate);
    
    % Step 2.2: Populate MetaData.TagDeployInfo
    % Find row in TagMetaDataAll that matches ToppID and copy over data
    row=find(TagMetaDataAll.TOPPID(:)==TOPPID);
    % if no matching row is found, populate MetaData.TagDeployInfo with row of NaNs
    if isempty(row)
        MetaData.TagDeployInfo=table2struct(TagMetaDataAll(1,:));       
    else
        MetaData.TagDeployInfo=table2struct(TagMetaDataAll(row,:));
    end
    clear row
    
    % Step 2.3: Create list of TOPP IDs for other deployments on same animal
    rows=strcmp(MetaData.FieldID,MetaDataAll.FieldID);
    MetaData.AllDeployments=MetaDataAll.TOPPID(rows,1);
    clear rows
    
%% Step 3: Find files associated with current TOPPID

    AniMotumfile=strcat(TrackAniMotumFiles.folder(TrackAniMotumFiles.TOPPID==MetaDataAll.TOPPID(i)),...
        '\',TrackAniMotumFiles.filename(TrackAniMotumFiles.TOPPID==MetaDataAll.TOPPID(i)));
    GPSfile=strcat(GPSFiles.folder(GPSFiles.TOPPID==MetaDataAll.TOPPID(i)),...
        '\',GPSFiles.filename(GPSFiles.TOPPID==MetaDataAll.TOPPID(i)));
    Argosfile=strcat(ArgosFiles.folder(ArgosFiles.TOPPID==MetaDataAll.TOPPID(i)),...
        '\',ArgosFiles.filename(ArgosFiles.TOPPID==MetaDataAll.TOPPID(i)));
    
    tdr1file=strcat(TDRDiveStatFiles.folder(TDRDiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),...
        '\',strtok(TDRDiveStatFiles.filename(TDRDiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),'.'),'_QC.csv');
    tdr1subfile=strcat(TDRSubDiveStatFiles.folder(TDRSubDiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),...
        '\',strtok(TDRSubDiveStatFiles.filename(TDRSubDiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),'.'),'_QC.csv');
    tdr2file=strcat(TDR2DiveStatFiles.folder(TDR2DiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),...
        '\',strtok(TDR2DiveStatFiles.filename(TDR2DiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),'.'),'_QC.csv');
    tdr2subfile=strcat(TDR2SubDiveStatFiles.folder(TDR2SubDiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),...
        '\',strtok(TDR2SubDiveStatFiles.filename(TDR2SubDiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),'.'),'_QC.csv');
    tdr3file=strcat(TDR3DiveStatFiles.folder(TDR3DiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),...
        '\',strtok(TDR3DiveStatFiles.filename(TDR3DiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),'.'),'_QC.csv');
    tdr3subfile=strcat(TDR3SubDiveStatFiles.folder(TDR3SubDiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),...
        '\',strtok(TDR3SubDiveStatFiles.filename(TDR3SubDiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),'.'),'_QC.csv');
    m=strlength(TDRDiveStatFiles.filename(TDRDiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)));
    tdr1typefile=strcat(TDRDiveStatFiles.folder(TDRDiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),...
        '\',extractBefore(TDRDiveStatFiles.filename(TDRDiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),m-23),'_DiveType.csv');
    n=strlength(TDR2DiveStatFiles.filename(TDR2DiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)));
    tdr2typefile=strcat(TDR2DiveStatFiles.folder(TDR2DiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),...
        '\',extractBefore(TDR2DiveStatFiles.filename(TDR2DiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),n-23),'_DiveType.csv');
    o=strlength(TDR3DiveStatFiles.filename(TDR3DiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)));
    tdr3typefile=strcat(TDR3DiveStatFiles.folder(TDR3DiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),...
        '\',extractBefore(TDR3DiveStatFiles.filename(TDR3DiveStatFiles.TOPPID==MetaDataAll.TOPPID(i)),o-23),'_DiveType.csv');
    clear m n o
%% Step 4: Read in TDR data 
       
    % DiveStat and DiveType will contain the highest quality TDR data available, followed by Dive2XXXX 
    % and Dive3XXXX; use SubSampled data if available
    if size(tdr1subfile,1)>0
        DiveStat=readtable(tdr1subfile);
        DiveStat.Lon360=DiveStat.Lon+360;
        ind=find(DiveStat.Lon>0);
        DiveStat.Lon360(ind)=DiveStat.Lon360(ind)-360;
    elseif size(tdr1file,1)>0
        DiveStat=readtable(tdr1file);
        DiveStat.Lon360=DiveStat.Lon+360;
        ind=find(DiveStat.Lon>0);
        DiveStat.Lon360(ind)=DiveStat.Lon360(ind)-360;
    end
    if size(tdr2subfile,1)>0
        Dive2Stat=readtable(tdr2subfile);
        Dive2Stat.Lon360=Dive2Stat.Lon+360;
        ind=find(Dive2Stat.Lon>0);
        Dive2Stat.Lon360(ind)=Dive2Stat.Lon360(ind)-360;
    elseif size(tdr2file,1)>0
        Dive2Stat=readtable(tdr2file);
        Dive2Stat.Lon360=Dive2Stat.Lon+360;
        ind=find(Dive2Stat.Lon>0);
        Dive2Stat.Lon360(ind)=Dive2Stat.Lon360(ind)-360;
    end
    if size(tdr3subfile,1)>0
        Dive3Stat=readtable(tdr3subfile);
        Dive3Stat.Lon360=Dive3Stat.Lon+360;
        ind=find(Dive3Stat.Lon>0);
        Dive3Stat.Lon360(ind)=Dive3Stat.Lon360(ind)-360;
    elseif size(tdr3file,1)>0
        Dive3Stat=readtable(tdr3file);
        Dive3Stat.Lon360=Dive3Stat.Lon+360;
        ind=find(Dive3Stat.Lon>0);
        Dive3Stat.Lon360(ind)=Dive3Stat.Lon360(ind)-360;
    end

    % import dive types, rename variables, and add text categories
    if size(tdr1typefile,1)>0
        DiveType=readtable(tdr1typefile);
        DiveType.Properties.VariableNames={'DiveNumber','DriftDiveIndex','DriftRate',...
            'BenthicDiveIndex','BenthicDiveVerticalRate','CornerIndex','ForagingIndex',...
            'VerticalSpeed90Percentile','VerticalSpeed95Percentile','DiveType'};
        DiveType.DiveTypeName(DiveType.DiveType==0)={'Transit'};
        DiveType.DiveTypeName(DiveType.DiveType==1)={'Forage'};
        DiveType.DiveTypeName(DiveType.DiveType==2)={'Drift'};
        DiveType.DiveTypeName(DiveType.DiveType==3)={'Benthic'};
    end

    if size(tdr2typefile,1)>0
        Dive2Type=readtable(tdr2typefile);
        Dive2Type.Properties.VariableNames={'DiveNumber','DriftDiveIndex','DriftRate',...
            'BenthicDiveIndex','BenthicDiveVerticalRate','CornerIndex','ForagingIndex',...
            'VerticalSpeed90Percentile','VerticalSpeed95Percentile','DiveType'};
        Dive2Type.DiveTypeName(Dive2Type.DiveType==0)={'Transit'};
        Dive2Type.DiveTypeName(Dive2Type.DiveType==1)={'Forage'};
        Dive2Type.DiveTypeName(Dive2Type.DiveType==2)={'Drift'};
        Dive2Type.DiveTypeName(Dive2Type.DiveType==3)={'Benthic'};
    end

    if size(tdr3typefile,1)>0
        Dive3Type=readtable(tdr3typefile);
        Dive3Type.Properties.VariableNames={'DiveNumber','DriftDiveIndex','DriftRate',...
            'BenthicDiveIndex','BenthicDiveVerticalRate','CornerIndex','ForagingIndex',...
            'VerticalSpeed90Percentile','VerticalSpeed95Percentile','DiveType'};
        Dive3Type.DiveTypeName(Dive3Type.DiveType==0)={'Transit'};
        Dive3Type.DiveTypeName(Dive3Type.DiveType==1)={'Forage'};
        Dive3Type.DiveTypeName(Dive3Type.DiveType==2)={'Drift'};
        Dive3Type.DiveTypeName(Dive3Type.DiveType==3)={'Benthic'};
    end

    clear tdr1file tdr1typefile tdr1subfile tdr2file tdr2subfile tdr2typefile tdr3file tdr3subfile tdr3typefile

%% Step 5: check for tracking data and read what is present into tables

    if size(AniMotumfile,1)>0
        % If file is present, load using readtable
        Track_AniMotum=readtable(AniMotumfile);
        % Remove leading variable (numeric index) from AniMotum files, if present
        try
            Track_AniMotum=removevars(Track_AniMotum,{'Var1'});
        end
        % Rename columns for consistency
        Track_AniMotum.Properties.VariableNames = {'TOPPID','DateTime','Lon',...
            'Lat','x','y','x_se_km','y_se_km','u','v','u_se_km','v_se_km','s','s_se'};
        % Create matlab JulDate
        Track_AniMotum.Lon360=Track_AniMotum.Lon+360;
        ind=find(Track_AniMotum.Lon>0);
        Track_AniMotum.Lon360(ind)=Track_AniMotum.Lon360(ind)-360;
        Track_AniMotum.JulDate=datenum(Track_AniMotum.DateTime);
    end

    % Check for presence of data type. 
    if size(Argosfile,1)>0
        %If present, load
        Track_Argos_Raw=readtable(Argosfile);
        Track_Argos_Raw.Properties.VariableNames(4)={'Lon'};
        Track_Argos_Raw.Properties.VariableNames(6)={'Lon2'};
    end
    
    % Check for presence of data type.
    if size(GPSfile,1)>0
        % If present, load and rename variables
        Track_GPS_Raw=readtable(GPSfile,'HeaderLines',4);
        Track_GPS_Raw.Properties.VariableNames(3)={'Lon'};
        Track_GPS_Raw.Properties.VariableNames(4)={'Lon360'};
    end
    
%% Step 6: Create Track_Best - AniMotum Track, includes JD,Lat,Lon, and errors

    if size(Track_AniMotum,1)>0
        Track_Best=array2table([Track_AniMotum.JulDate,Track_AniMotum.Lat,Track_AniMotum.Lon,...
            Track_AniMotum.Lon360,Track_AniMotum.x_se_km,Track_AniMotum.y_se_km]);
        Track_Best.Properties.VariableNames={'JulDate','Lat','Lon','Lon360',...
            'Lat_standard_error','Lon_standard_error'};
    end
    
%% Step 7: Foraging Success and Additional MetaData
   
    % Step 7.1: Populate Foraging Success
    % Find row in ForagingSuccessAll that matches TOPPID
    row=find(ForagingSuccessAll.TOPPID(:)==TOPPID);
    if isempty(row)
        % if no row matches, populate with row of NaN's
        ForagingSuccess=table2struct(ForagingSuccessAll(1,:));       
    else
        % populate with row of data matching TOPPID
        ForagingSuccess=table2struct(ForagingSuccessAll(row,:));
    end
    clear row
         
    % Step 7.2: Populating Group Variables
    DepartDateVec=datevec(MetaData.DepartDate);
    MetaData.Group.Year=DepartDateVec(1,1);
    MetaData.Group.DepartLoc=MetaData.DepartLoc;
    if isnan(MetaData.BirthYear)
        MetaData.Group.KnownAge=0;
    else
        MetaData.Group.KnownAge=1;
    end

    if isempty(MetaData.ArriveLoc)
        MetaData.Group.Recovered=0;
    else
        MetaData.Group.Recovered=1;
    end
    
    % Determine season by departure date (for adulte female eseals only)%%%%%
    % This process needs to be QC'd - some files have 0 season when should be 1%%%
    if ~isnan(MetaData.DepartDate)
        if (datenum(MetaData.DepartDate)-datenum([MetaData.Group.Year 1 1 1 1 1]))<91
            MetaData.Group.Season=1;
        elseif (datenum(MetaData.DepartDate)-datenum([MetaData.Group.Year ...
                1 1 1 1 1]))>131 ...
            && (datenum(MetaData.DepartDate)-datenum([MetaData.Group.Year ...
                1 1 1 1 1]))<274
            MetaData.Group.Season=2;
        else
            MetaData.Group.Season=0;
        end
    else
        MetaData.Group.Season=0;
    end
    clear DepartDateVec

    % Check if complete TDR record exists
    if isempty(DiveStat)
        MetaData.Group.CompleteTDR=0;
    else
        % Pct days w/dive data is >95% of trip length?
        test1=size(unique(floor(DiveStat.JulDate)),1)>...
            ((datenum(MetaData.ArriveDate)-datenum(MetaData.DepartDate))*0.95);
        % First dive within 2 days of departure date from starstop?
        test2=(DiveStat.JulDate(1)-datenum(MetaData.DepartDate))<2;
        % Last dive within 2 days of arrival date from starstop?
        test3=(datenum(MetaData.ArriveDate)-DiveStat.JulDate(end))<2;
        % All 3 parameters must be met
        if  (test1+test2+test3)==3 
            MetaData.Group.CompleteTDR=1;
        else
            MetaData.Group.CompleteTDR=0;
        end
    end
    clear test1 test2 test3
    
    %%%check if complete track exists%%
    if isempty(Track_Best)
        MetaData.Group.CompleteTrack=0;
    else
        % Pct days w/track data is >75% of trip length?
        test1=size(unique(floor(Track_Best.JulDate)),1)>...
            ((datenum(MetaData.ArriveDate)-datenum(MetaData.DepartDate))*0.75);
        % First location within 2 days of departure date from starstop?
        test2=(Track_Best.JulDate(1)-datenum(MetaData.DepartDate))<2;
        % Last location within 2 days of arrival date from starstop?
        test3=(datenum(MetaData.ArriveDate)-Track_Best.JulDate(end))<2;
        % Arrival location is known?
        test4=~isempty(MetaData.ArriveLoc);
        % All 4 parameters must be met
        if (test1+test2+test3+test4)==4 
            MetaData.Group.CompleteTrack=1;
        else
            MetaData.Group.CompleteTrack=0;
        end
    end
    clear test1 test2 test3 test4
       
    %%%%%%%%%%%%%%%%%%%%%%%%   
    % Create new mat file
    save([folder '\' num2str(TOPPID) '_' MetaData.FieldID '_TV4_beta.mat'],...
        'TOPPID',...
        'DiveStat',...
        'DiveType',...
        'Dive2Stat',...
        'Dive2Type',...
        'Dive3Stat',...
        'Dive3Type',...
        'Track_Argos_Raw',...
        'Track_GPS_Raw',...
        'Track_AniMotum',...
        'Track_Best',...
        'MetaData',...
        'ForagingSuccess')
end
