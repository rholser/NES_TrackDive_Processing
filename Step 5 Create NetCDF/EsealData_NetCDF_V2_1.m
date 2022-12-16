%Compiles northern elephant seal tracking and diving data into netCDF files.
%
%Requires filename indexes for each data type to be compiled and uses
%TOPPID 
%
%V1.1
% Created by: Rachel Holser (rholser@ucsc.edu)
% Created on: 18-Aug-2022
%
% Modified: 31-Oct-2022
% Removed Curated Subsampled TDR data
%
%V2.1
% Created by: Rachel Holser
% Created on: 16-Nov-2022
% Creates two netCDF files for each animal (one for raw and curated data,
% one for processed data). Both files will contain all of the same global
% attributes so metadata are available in both files.
%
% Modified: 04-Dec-2022
%

clear
load('MetaData.mat');
load('All_FileNames.mat');

filename='2014001_12933_tdr_raw.csv';
data=readtable(filename);
TOPPID=2014001;
i=446;
%i=639;

for i=1:size(TagMetaDataAll,1)
    TOPPID=TagMetaDataAll.TOPPID(i)
    
    j=find(MetaDataAll.TOPPID==TOPPID);
    oldFormat = netcdf.setDefaultFormat('NC_FORMAT_NETCDF4');
    %% Create level 1&2 netCDF file, groups, and global attributes
    filename=[num2str(TOPPID) '_TrackTDR_RawCurated.nc'];
    ncid=netcdf.create(filename,'CLOBBER');

    %Raw Data Group
    RawGrpID=netcdf.defGrp(ncid,'RAW_DATA');
    RawArgosGrpID=netcdf.defGrp(RawGrpID,'RAW_ARGOS');
    RawGPRGrpID=netcdf.defGrp(RawGrpID,'RAW_GPS');
    RawTDR1GrpID=netcdf.defGrp(RawGrpID,'RAW_TDR1');
    RawTDR2GrpID=netcdf.defGrp(RawGrpID,'RAW_TDR2');
    RawTDR3GrpID=netcdf.defGrp(RawGrpID,'RAW_TDR3');

    %Curated Data Group
    CuratedGrpID=netcdf.defGrp(ncid,'CURATED_DATA');
    CuratedTrackGrpID=netcdf.defGrp(CuratedGrpID,'CURATED_LOCATIONS');
    CleanTDR1GrpID=netcdf.defGrp(CuratedGrpID,'CLEAN_TDR1');
    ZOCTDR1GrpID=netcdf.defGrp(CuratedGrpID,'ZOC_TDR1');
    CleanTDR2GrpID=netcdf.defGrp(CuratedGrpID,'CLEAN_TDR2');
    ZOCTDR2GrpID=netcdf.defGrp(CuratedGrpID,'ZOC_TDR2');
    CleanTDR3GrpID=netcdf.defGrp(CuratedGrpID,'CLEAN_TDR3');
    ZOCTDR3GrpID=netcdf.defGrp(CuratedGrpID,'ZOC_TDR3');

    %Global Attributes
    %%%%%Creation/versions/permissions
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"), "_____DATA_PROCESSING_AND_ATTRIBUTION_____",'________');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"), 'creation_date',string(datetime("now")));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "MATLAB Version", version);
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "R Version", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "foieGras Version", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "DA-ZOC Version", '2.2/1.1');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Data_Owner", 'Daniel Costa');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Is_Data_Public",...
        'Yes: data can be used freely as long as data owner is properly cited');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Citation", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Citation_DOI", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Data_Type", 'Tracking and diving time-series data');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Data_Assembly_By", 'UCSC/Rachel Holser');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Timezone", 'UTC');

    %%%%%Animal MetaData    
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "____ANIMAL_METADATA____",'________');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "SealID",'');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Species", 'Mirounga angustirostris');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Sex", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Age_Class", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Birth_Year", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Had_Pup", '');
    
    %%%%%Deployment MetaData
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "____DEPLOYMENT_METADATA____",'________');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "DeploymentID",TOPPID);
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Deployment_Year", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Deployment_Season", string(MetaDataAll.Season(j)));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Instruments_Recovered", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Other_Deployments",'' ); %Need to build this in somehow
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Departure_Location", string(MetaDataAll.DepartLoc(j)));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Departure_Lat", MetaDataAll.DepartLat(j));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Departure_Lon", MetaDataAll.DepartLon(j));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Departure_Datetime", string(MetaDataAll.DepartDate(j)));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Arrival_Location", string(MetaDataAll.ArriveLoc(j)));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Arrival_Lat", MetaDataAll.ArriveLat(j));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Arrival_Lon", MetaDataAll.ArriveLon(j));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Arrival_Datetime", string(MetaDataAll.ArriveDate(j))); 
    
    %%%%%Data Quality
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "____DATA_QUALITY____",'________');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Track_QC_Flag",'');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR1_QC_Flag",'');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR2_QC_Flag",'');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR3_QC_Flag",'');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR1_SamplingFrequency", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR1_DepthResolution", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR2_SamplingFrequency", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR2_DepthResolution", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR3_SamplingFrequency", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR3_DepthResolution", '');

    %%%%%Instrument MetaData
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "____INSTRUMENT_METADATA____",'________');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "PTT", TagMetaDataAll.SatTagPTT(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Argos_Tag_Model", TagMetaDataAll.SatTagType(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Argos_Tag_ID", TagMetaDataAll.SatTagID(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Argos_Tag_Manufacturer", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "GPS_Tag_Model", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "GPS_Tag_ID", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "GPS_Tag_Manufacturer", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR1_Tag_Model", TagMetaDataAll.TDR1Type(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR1_Tag_ID", TagMetaDataAll.TDR1ID(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR1_Tag_Manufacturer", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR1_Comments", TagMetaDataAll.TDR1Comment(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR2_Tag_Model", TagMetaDataAll.TDR2Type(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR2_Tag_ID", TagMetaDataAll.TDR2ID(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR2_Tag_Manufacturer", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR2_Comments", TagMetaDataAll.TDR2Comment(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR3_Tag_Model", TagMetaDataAll.TDR3Type(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR3_Tag_ID", TagMetaDataAll.TDR3ID(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR3_Tag_Manufacturer", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR3_Comments", TagMetaDataAll.TDR3Comment(i));

    %% Raw Data Group
    % Argos Raw - RawArgosGrpID
    try
        data=readtable(strcat(ArgosFiles.folder(ArgosFiles.TOPPID==TOPPID),'\',...
            ArgosFiles.filename(ArgosFiles.TOPPID==TOPPID)));
    end

    netcdf.reDef(ncid);
    if exist('data','var')==1
        RawArgosdimid=netcdf.defDim(RawGrpID,'RawArgos_rows',size(data,1));
    else
        RawArgosdimid=netcdf.defDim(RawGrpID,'RawArgos_rows',0);
    end
    RawArgosDate=netcdf.defVar(RawArgosGrpID,'PASS_DATE','NC_STRING',RawArgosdimid);
    netcdf.putAtt(ncid,RawArgosDate,"Description","Date of Argos-based location estimate");
    RawArgosTime=netcdf.defVar(RawArgosGrpID,'PASS_TIME','NC_STRING',RawArgosdimid);
    netcdf.putAtt(ncid,RawArgosTime,"Description","Time of Argos-based location estimate");
    RawArgosClass=netcdf.defVar(RawArgosGrpID,'CLASS','NC_STRING',RawArgosdimid);
    netcdf.putAtt(ncid,RawArgosClass,"Description","Location class of Argos-based location estimate");
    RawArgosLat1=netcdf.defVar(RawArgosGrpID,'LAT1','NC_DOUBLE',RawArgosdimid);
    netcdf.putAtt(ncid,RawArgosLat1,"Description","Latitude of Argos-based location estimate");
    netcdf.putAtt(ncid,RawArgosLat1,'Units','decimal degrees');
    RawArgosLon1=netcdf.defVar(RawArgosGrpID,'LON1','NC_DOUBLE',RawArgosdimid);
    netcdf.putAtt(ncid,RawArgosLon1,"Description","Longitude of Argos-based location estimate");
    netcdf.putAtt(ncid,RawArgosLon1,'Units','decimal degrees');
    netcdf.endDef(ncid);

    if ~isempty(data)
        netcdf.putVar(RawArgosGrpID,RawArgosDate,data.PassDate)
        netcdf.putVar(RawArgosGrpID,RawArgosTime,data.PassTime)
        netcdf.putVar(RawArgosGrpID,RawArgosClass,data.Class)
        netcdf.putVar(RawArgosGrpID,RawArgosLat1,data.Latitude)
        netcdf.putVar(RawArgosGrpID,RawArgosLon1,data.Longitude)
    else
    end
    clear data

    %GPS Raw - RawGPRGrpID
    try
        data=readtable(strcat(GPSFiles.folder(GPSFiles.TOPPID==TOPPID),'\',...
            GPSFiles.file(GPSFiles.TOPPID==TOPPID)), "HeaderLines",3);
    end

    netcdf.reDef(ncid);
    if exist('data','var')==1
        RawGPSdimid=netcdf.defDim(RawGrpID,'RawGPS_rows',size(data,1));
    else
        RawGPSdimid=netcdf.defDim(RawGrpID,'RawGPS_rows',0);
    end
    RawGPSDate=netcdf.defVar(RawGPSGrpID,'DATE','NC_STRING',RawArgosdimid);
    netcdf.putAtt(ncid,RawGPSDate,"Description","Date of GPS-based location estimate");
    RawGPSTime=netcdf.defVar(RawGPSGrpID,'TIME','NC_STRING',RawGPSdimid);
    netcdf.putAtt(ncid,RawGPSTime,"Description","Time of GPS-based location estimate");
    RawGPSSats=netcdf.defVar(RawGPSGrpID,'NUM_SATELLITES','NC_DOUBLE',RawGPSdimid);
    netcdf.putAtt(ncid,RawGPSSats,"Description","Number of GPS satellites detected for location estimate");
    RawGPSLat=netcdf.defVar(RawGPSGrpID,'LAT','NC_DOUBLE',RawGPSdimid);
    netcdf.putAtt(ncid,RawGPSLat,"Description","Latitude of GPS-based location estimate");
    netcdf.putAtt(ncid,RawGPSLat,'Units','decimal degrees');
    RawGPSLon=netcdf.defVar(RawGPSGrpID,'LON','NC_DOUBLE',RawGPSdimid);
    netcdf.putAtt(ncid,RawGPSLon,"Description","Longitude of GPS-based location estimate");
    netcdf.putAtt(ncid,RawGPSLon,'Units','decimal degrees');
    netcdf.endDef(ncid);

    if ~isempty(data)
        netcdf.putVar(RawGPSGrpID,RawGPSDate,string(data.Day))
        netcdf.putVar(RawGPSGrpID,RawGPSTime,string(data.Time))
        netcdf.putVar(RawGPSGrpID,RawGPSSats,data.Satellites)
        netcdf.putVar(RawGPSGrpID,RawGPSLat,data.Latitude)
        netcdf.putVar(RawGPSGrpID,RawGPSLon,data.Longitude)
    else
    end
    clear data

    %TDR1 Raw - RawTDR1GrpID
    try
        data=readtable(strcat(TDRRawFiles.folder(TDRRawFiles.TOPPID==TOPPID),'\',...
            TDRRawFiles.filename(TDRRawFiles.TOPPID==TOPPID)));
    end

    netcdf.reDef(ncid);
    if exist('data','var')==1
        RawTDR1dimid=netcdf.defDim(RawGrpID,'RawTDR1_rows',size(data,1));
    else
        RawTDR1dimid=netcdf.defDim(RawGrpID,'RawTDR1_rows',0);
    end
    RawTDR1Date=netcdf.defVar(RawTDR1GrpID,'DATE','NC_STRING',RawTDR1dimid);
    RawTDR1Depth=netcdf.defVar(RawTDR1GrpID,'DEPTH','NC_DOUBLE',RawTDR1dimid);
    RawTDR1Temp=netcdf.defVar(RawTDR1GrpID,'EXTERNAL_TEMP','NC_DOUBLE',RawTDR1dimid);
    RawTDR1Light=netcdf.defVar(RawTDR1GrpID,'LIGHT','NC_DOUBLE',RawTDR1dimid);
    netcdf.endDef(ncid);

    if ~isempty(data)
        %Set up different imports to account for different instrument types/formats
        %Wildlife Computers - may include light and temp
        if contains(TDR1RawFiles.filename(TDR1RawFiles.TOPPID==TOPPID),'out-Archive')==1
            netcdf.putVar(RawTDR1GrpID,RawTDR1Date,string(data.Time));
            netcdf.putVar(RawTDR1GrpID,RawTDR1Depth,data.Depth);

            data_names=data.Properties.VariableNames;
            m=size(data,2);

            %Look for different variable names for temp and light.  If none, no
            %data to include
            if sum(strcmp({'ExternalTemp'},data_names(:)))>0
                netcdf.putVar(RawTDR1GrpID,RawTDR1Temp,data.ExternalTemp);
            elseif sum(strcmp({'Temp'},data_names(:)))>0
                netcdf.putVar(RawTDR1GrpID,RawTDR1Temp,data.Temp);
            elseif sum(strcmp({'ExternalTemperature'},data_names(:)))>0
                netcdf.putVar(RawTDR1GrpID,RawTDR1Temp,data.ExternalTemperature);
            end

            if sum(strcmp({'LightLevel'},data_names(:)))>0
                netcdf.putVar(RawTDR1GrpID,RawTDR1Light,data.LightLevel);
            elseif sum(strcmp({'Light'},data_names(:)))>0
                netcdf.putVar(RawTDR1GrpID,RawTDR1Light,data.Light);
            end
            %SMRU
        elseif contains(TDR1RawFiles.filename(TDR1RawFiles.TOPPID==TOPPID),'tdr')==1
            netcdf.putVar(RawTDR1GrpID,RawTDR1Date,data.Time);
            netcdf.putVar(RawTDR1GrpID,RawTDR1Depth,data.Depth);
            %Little Leonardo Kami
        elseif contains(TDR1RawFiles.filename(TDR1RawFiles.TOPPID==TOPPID),'kami')==1
            netcdf.putVar(RawTDR1GrpID,RawTDR1Date,data.Time);
            netcdf.putVar(RawTDR1GrpID,RawTDR1Depth,data.Depth);
            %Little Leonardo Stroke
        elseif contains(TDR1RawFiles.filename(TDR1RawFiles.TOPPID==TOPPID),'stroke')==1
            netcdf.putVar(RawTDR1GrpID,RawTDR1Date,data.Time);
            netcdf.putVar(RawTDR1GrpID,RawTDR1Depth,data.Depth);
        end
        netcdf.putAtt(RawTDR1GrpID,RawTDR1Temp,'Units','Degrees C');
    else
    end
    clear data data_names

    %TDR2 Raw - RawTDR2GrpID
    try
        data=readtable(strcat(TDR2RawFiles.folder(TDR2RawFiles.TOPPID==TOPPID),'\',...
            TDR2RawFiles.filename(TDR2RawFiles.TOPPID==TOPPID)));
    end

    netcdf.reDef(ncid);
    if exist('data','var')==1
        RawTDR2dimid=netcdf.defDim(RawGrpID,'RawTDR2_rows',size(data,1));
    else
        RawTDR2dimid=netcdf.defDim(RawGrpID,'RawTDR2_rows',0);
    end
    RawTDR2Date=netcdf.defVar(RawTDR2GrpID,'DATE','NC_STRING',RawTDR2dimid);
    RawTDR2Depth=netcdf.defVar(RawTDR2GrpID,'DEPTH','NC_DOUBLE',RawTDR2dimid);
    RawTDR2Temp=netcdf.defVar(RawTDR2GrpID,'EXTERNAL_TEMP','NC_DOUBLE',RawTDR2dimid);
    RawTDR2Light=netcdf.defVar(RawTDR2GrpID,'LIGHT','NC_DOUBLE',RawTDR2dimid);
    netcdf.endDef(ncid);
    if ~isempty(data)

        %Set up different imports to account for different instrument types/formats
        %Wildlife Computers - may include light and temp
        if contains(TDR2RawFiles.filename(TDR2RawFiles.TOPPID==TOPPID),'out-Archive')==1
            netcdf.putVar(RawTDR2GrpID,RawTDR2Date,string(data.Time));
            netcdf.putVar(RawTDR2GrpID,RawTDR2Depth,data.Depth);

            data_names=data.Properties.VariableNames;
            m=size(data,2);

            %Look for different variable names for temp and light.  If none, no
            %data to include
            if sum(strcmp({'ExternalTemp'},data_names(:)))>0
                netcdf.putVar(RawTDR2GrpID,RawTDR2Temp,data.ExternalTemp);
            elseif sum(strcmp({'Temp'},data_names(:)))>0
                netcdf.putVar(RawTDR2GrpID,RawTDR2Temp,data.Temp);
            elseif sum(strcmp({'ExternalTemperature'},data_names(:)))>0
                netcdf.putVar(RawTDR2GrpID,RawTDR2Temp,data.ExternalTemperature);
            end

            if sum(strcmp({'LightLevel'},data_names(:)))>0
                netcdf.putVar(RawTDR2GrpID,RawTDR2Light,data.LightLevel);
            elseif sum(strcmp({'Light'},data_names(:)))>0
                netcdf.putVar(RawTDR2GrpID,RawTDR2Light,data.Light);
            end

            %SMRU
        elseif contains(TDR2RawFiles.filename(TDR2RawFiles.TOPPID==TOPPID),'tdr')==1
            netcdf.putVar(RawTDR2GrpID,RawTDR2Date,data.Time);
            netcdf.putVar(RawTDR2GrpID,RawTDR2Depth,data.Depth);
            %Little Leonardo Kami
        elseif contains(TDR2RawFiles.filename(TDR2RawFiles.TOPPID==TOPPID),'kami')==1
            netcdf.putVar(RawTDR2GrpID,RawTDR2Date,data.Time);
            netcdf.putVar(RawTDR2GrpID,RawTDR2Depth,data.Depth);
            %Little Leonardo Stroke
        elseif contains(TDR2RawFiles.filename(TDR2RawFiles.TOPPID==TOPPID),'stroke')==1
            netcdf.putVar(RawTDR2GrpID,RawTDR2Date,data.Time);
            netcdf.putVar(RawTDR2GrpID,RawTDR2Depth,data.Depth);
        end
        netcdf.putAtt(RawTDR2GrpID,RawTDR2Temp,'Units','Degrees C');
    else
    end
    clear data data_names

    %TDR3 Raw - RawTDR3GrpID
    try
        data=readtable(strcat(TDR3RawFiles.folder(TDR3RawFiles.TOPPID==TOPPID),'\',...
            TDR3RawFiles.filename(TDR3RawFiles.TOPPID==TOPPID)));
    end
    netcdf.reDef(ncid);
    if exist('data','var')==1
        RawTDR3dimid=netcdf.defDim(RawGrpID,'RawTDR3_rows',size(data,1));
    else
        RawTDR3dimid=netcdf.defDim(RawGrpID,'RawTDR3_rows',0);
    end
    RawTDR3Date=netcdf.defVar(RawTDR3GrpID,'DATE','NC_STRING',RawTDR3dimid);
    RawTDR3Depth=netcdf.defVar(RawTDR3GrpID,'DEPTH','NC_DOUBLE',RawTDR3dimid);
    RawTDR3Temp=netcdf.defVar(RawTDR3GrpID,'EXTERNAL_TEMP','NC_DOUBLE',RawTDR3dimid);
    RawTDR3Light=netcdf.defVar(RawTDR3GrpID,'LIGHT','NC_DOUBLE',RawTDR3dimid);
    netcdf.endDef(ncid);

    if ~isempty(data)
        %Set up different imports to account for different instrument types/formats
        %Wildlife Computers - may include light and temp
        if contains(TDR3RawFiles.filename(TDR3RawFiles.TOPPID==TOPPID),'out-Archive')==1
            netcdf.putVar(RawTDR3GrpID,RawTDR3Date,string(data.Time));
            netcdf.putVar(RawTDR3GrpID,RawTDR3Depth,data.Depth);

            data_names=data.Properties.VariableNames;
            m=size(data,2);

            %Look for different variable names for temp and light.  If none, no
            %data to include
            if sum(strcmp({'ExternalTemp'},data_names(:)))>0
                netcdf.putVar(RawTDR3GrpID,RawTDR3Temp,data.ExternalTemp);
            elseif sum(strcmp({'Temp'},data_names(:)))>0
                netcdf.putVar(RawTDR3GrpID,RawTDR3Temp,data.Temp);
            elseif sum(strcmp({'ExternalTemperature'},data_names(:)))>0
                netcdf.putVar(RawTDR3GrpID,RawTDR3Temp,data.ExternalTemperature);
            end

            if sum(strcmp({'LightLevel'},data_names(:)))>0
                netcdf.putVar(RawTDR3GrpID,RawTDR3Light,data.LightLevel);
            elseif sum(strcmp({'Light'},data_names(:)))>0
                netcdf.putVar(RawTDR3GrpID,RawTDR3Light,data.Light);
            end

            %SMRU
        elseif contains(TDR3RawFiles.filename(TDR3RawFiles.TOPPID==TOPPID),'tdr')==1
            netcdf.putVar(RawTDR3GrpID,RawTDR3Date,data.Time);
            netcdf.putVar(RawTDR3GrpID,RawTDR3Depth,data.Depth);
            %Little Leonardo Kami
        elseif contains(TDR3RawFiles.filename(TDR3RawFiles.TOPPID==TOPPID),'kami')==1
            netcdf.putVar(RawTDR3GrpID,RawTDR3Date,data.Time);
            netcdf.putVar(RawTDR3GrpID,RawTDR3Depth,data.Depth);
            %Little Leonardo Stroke
        elseif contains(TDR3RawFiles.filename(TDR3RawFiles.TOPPID==TOPPID),'stroke')==1
            netcdf.putVar(RawTDR3GrpID,RawTDR3Date,data.Time);
            netcdf.putVar(RawTDR3GrpID,RawTDR3Depth,data.Depth);
        end
        netcdf.putAtt(RawTDR3GrpID,RawTDR3Temp,'Units','Degrees C');
    else
    end
    clear data data_names

    %% Curated Data Group
    % Track Clean
    try
        data=readtable(strcat(TrackCleanFiles.folder(TrackCleanFiles.TOPPID==TOPPID),'\',...
            TrackCleanFiles.filename(TrackCleanFiles.TOPPID==TOPPID)));
    end

    netcdf.reDef(ncid);
    if exist('data','var')==1
        CleanTrackdimid=netcdf.defDim(CuratedGrpID,'CleanTrack_rows',size(data,1));
    else
        CleanTrackdimid=netcdf.defDim(CuratedGrpID,'CleanTrack_rows',0);
    end
    CleanTrackDate=netcdf.defVar(CuratedTrackGrpID,'DATE','NC_STRING',CleanTrackdimid);
    netcdf.putAtt(ncid,CleanTrackDate,"Description","Date and time of Argos-based location estimate");
    CleanTrackLat=netcdf.defVar(CuratedTrackGrpID,'LAT','NC_DOUBLE',CleanTrackdimid);
    netcdf.putAtt(ncid,CleanTrackLat,"Description","Latitude of Argos-based location estimate");
    netcdf.putAtt(ncid,CleanTrackLat,'Units','decimal degrees');
    CleanTrackLon=netcdf.defVar(CuratedTrackGrpID,'LON','NC_DOUBLE',CleanTrackdimid);
    netcdf.putAtt(ncid,CleanTrackLat,"Description","Longitude of Argos-based location estimate");
    netcdf.putAtt(ncid,CleanTrackLon,'Units','decimal degrees');
    CleanTrackLocClass=netcdf.defVar(CuratedTrackGrpID,'LOC_CLASS','NC_STRING',CleanTrackdimid);
    netcdf.putAtt(ncid,CleanTrackLocClass,"Description","Location class of Argos-based location estimate");
    CleanTrackSMajA=netcdf.defVar(CuratedTrackGrpID,'SEMI_MAJ_AXIS','NC_DOUBLE',CleanTrackdimid);
    netcdf.putAtt(ncid,CleanTrackSMajA,"Description","Semi-major axis of Argos-based location estimate’s error ellipse");
    CleanTrackSMinA=netcdf.defVar(CuratedTrackGrpID,'SEMI_MIN_AXIS','NC_DOUBLE',CleanTrackdimid);
    netcdf.putAtt(ncid,CleanTrackSMinA,"Description","Semi-minor axis of Argos-based location estimate’s error ellipse");
    CleanTrackEllipseOr=netcdf.defVar(CuratedTrackGrpID,'ELLIPSE_ORIENTATION','NC_DOUBLE',CleanTrackdimid);
    netcdf.putAtt(ncid,CleanTrackEllipseOr,"Description","Semi-major axis orientation from north");
    %%%%can we have group attributes?  Need to figure out where to put this
    %%%%information
    %netcdf.putAtt(CuratedGrpID,CuratedTrackGrpID,"Description", "Locations, location classes, and" + ...
    %    " errors (if available) of Argos and GPS data combined and prepared for foieGras processing.");
    netcdf.endDef(ncid);
    if ~isempty(data)
        netcdf.putVar(CuratedTrackGrpID,CleanTrackDate,string(data.Date));
        netcdf.putVar(CuratedTrackGrpID,CleanTrackLat,data.Latitude);
        netcdf.putVar(CuratedTrackGrpID,CleanTrackLon,data.Longitude);
        netcdf.putVar(CuratedTrackGrpID,CleanTrackLocClass,data.LocationClass);
        netcdf.putVar(CuratedTrackGrpID,CleanTrackSMajA,data.SemiMajorAxis);
        netcdf.putVar(CuratedTrackGrpID,CleanTrackSMinA,data.SemiMinorAxis);
        netcdf.putVar(CuratedTrackGrpID,CleanTrackEllipseOr,data.EllipseOrientation);
    else
    end
    clear data

    %TDR1 Clean
    try
        data=readmatrix(TDRCleanFiles.folder(TDRCleanFiles.TOPPID==TOPPID),'\',...
            TDRCleanFiles.filename(TDRCleanFiles.TOPPID==TOPPID));
    end

    %Define length dimension and variables for TDR1 Clean
    netcdf.reDef(ncid);
    if exist('data','var')==1
        CleanTDR1dimid=netcdf.defDim(ncid,'CleanTDR1_rows',size(data,1));
    else
        CleanTDR1dimid=netcdf.defDim(ncid,'CleanTDR1_rows',0);
    end
    CleanTDR1Year=netcdf.defVar(CleanTDR1GrpID,'YEAR','NC_DOUBLE',CleanTDR1dimid);
    CleanTDR1Month=netcdf.defVar(CleanTDR1GrpID,'MONTH','NC_DOUBLE',CleanTDR1dimid);
    CleanTDR1Day=netcdf.defVar(CleanTDR1GrpID,'DAY','NC_DOUBLE',CleanTDR1dimid);
    CleanTDR1Hour=netcdf.defVar(CleanTDR1GrpID,'HOUR','NC_DOUBLE',CleanTDR1dimid);
    CleanTDR1Min=netcdf.defVar(CleanTDR1GrpID,'MIN','NC_DOUBLE',CleanTDR1dimid);
    CleanTDR1Sec=netcdf.defVar(CleanTDR1GrpID,'SEC','NC_DOUBLE',CleanTDR1dimid);
    CleanTDR1Depth=netcdf.defVar(CleanTDR1GrpID,'DEPTH','NC_DOUBLE',CleanTDR1dimid);
    netcdf.endDef(ncid);

    %Write in Data
    if ~isempty(data)
        netcdf.putVar(CleanTDR1GrpID,CleanTDR1Year,data(:,1));
        netcdf.putVar(CleanTDR1GrpID,CleanTDR1Month,data(:,2));
        netcdf.putVar(CleanTDR1GrpID,CleanTDR1Day,data(:,3));
        netcdf.putVar(CleanTDR1GrpID,CleanTDR1Hour,data(:,4));
        netcdf.putVar(CleanTDR1GrpID,CleanTDR1Min,data(:,5));
        netcdf.putVar(CleanTDR1GrpID,CleanTDR1Sec,data(:,6));
        netcdf.putVar(CleanTDR1GrpID,CleanTDR1Depth,data(:,7));
    else
    end

    clear data

    %TDR1 ZOC
    try
        data=readmatrix(TDRZOCFiles.folder(TDRZOCFiles.TOPPID==TOPPID),'\',...
            TDRZOCFiles.filename(TDRZOCFiles.TOPPID==TOPPID),'HeaderLines',26);
    end

    %Define length dimension and variables for TDR1 ZOC
    netcdf.reDef(ncid);
    if exist('data','var')==1
        ZOCTDR1dimid=netcdf.defDim(ncid,'ZOCTDR1_rows',size(data,1));
    else
        ZOCTDR1dimid=netcdf.defDim(ncid,'ZOCTDR1_rows',0);
    end
    ZOCTDR1Date=netcdf.defVar(ZOCTDR1GrpID,'DATE','NC_DOUBLE',ZOCTDR1dimid);
    netcdf.putAtt(ZOCTDR1GrpID,ZOCTDR1Date,'Description','MATLAB serial date');
    netcdf.putAtt(ZOCTDR1GrpID,ZOCTDR1Date,'Origin','January 0, 0000 in the proleptic ISO calendar');
    ZOCTDR1CorrDepth=netcdf.defVar(ZOCTDR1GrpID,'CORR_DEPTH','NC_DOUBLE',ZOCTDR1dimid);
    netcdf.putAtt(ZOCTDR1GrpID,ZOCTDR1CorrDepth,'Description','Depth corrected for true surface')
    netcdf.putAtt(ZOCTDR1GrpID,ZOCTDR1CorrDepth,'Units','meters')
    ZOCTDR1Depth=netcdf.defVar(ZOCTDR1GrpID,'DEPTH','NC_DOUBLE',ZOCTDR1dimid);
    netcdf.putAtt(ZOCTDR1GrpID,ZOCTDR1Depth,'Description','Uncorrected depth')
    netcdf.putAtt(ZOCTDR1GrpID,ZOCTDR1Depth,'Units','meters')
    netcdf.endDef(ZOCTDR1GrpID);

    %Write in data
    if ~isempty(data)
        netcdf.putVar(ZOCTDR1GrpID,ZOCTDR1Date,data(:,2));
        netcdf.putVar(ZOCTDR1GrpID,ZOCTDR1CorrDepth,data(:,1));
        netcdf.putVar(ZOCTDR1GrpID,ZOCTDR1Depth,data(:,3));
    else
    end
    clear data

    %TDR2 Clean
    try
        data=readmatrix(TDR2CleanFiles.folder(TDR2CleanFiles.TOPPID==TOPPID),'\',...
            TDR2CleanFiles.filename(TDR2CleanFiles.TOPPID==TOPPID));
    end
    %Define length dimension and variables for TDR2 Clean
    netcdf.reDef(ncid);
    if exist('data','var')==1
        CleanTDR2dimid=netcdf.defDim(ncid,'CleanTDR2_rows',size(data,1));
    else
        CleanTDR2dimid=netcdf.defDim(ncid,'CleanTDR2_rows',0);
    end
    CleanTDR2Year=netcdf.defVar(CleanTDR2GrpID,'YEAR','NC_DOUBLE',CleanTDR2dimid);
    CleanTDR2Month=netcdf.defVar(CleanTDR2GrpID,'MONTH','NC_DOUBLE',CleanTDR2dimid);
    CleanTDR2Day=netcdf.defVar(CleanTDR2GrpID,'DAY','NC_DOUBLE',CleanTDR2dimid);
    CleanTDR2Hour=netcdf.defVar(CleanTDR2GrpID,'HOUR','NC_DOUBLE',CleanTDR2dimid);
    CleanTDR2Min=netcdf.defVar(CleanTDR2GrpID,'MIN','NC_DOUBLE',CleanTDR2dimid);
    CleanTDR2Sec=netcdf.defVar(CleanTDR2GrpID,'SEC','NC_DOUBLE',CleanTDR2dimid);
    CleanTDR2Depth=netcdf.defVar(CleanTDR2GrpID,'DEPTH','NC_DOUBLE',CleanTDR2dimid);
    netcdf.endDef(ncid);

    %Write in Data
    if ~isempty(data)
        netcdf.putVar(CleanTDR2GrpID,CleanTDR2Year,data(:,1));
        netcdf.putVar(CleanTDR2GrpID,CleanTDR2Month,data(:,2));
        netcdf.putVar(CleanTDR2GrpID,CleanTDR2Day,data(:,3));
        netcdf.putVar(CleanTDR2GrpID,CleanTDR2Hour,data(:,4));
        netcdf.putVar(CleanTDR2GrpID,CleanTDR2Min,data(:,5));
        netcdf.putVar(CleanTDR2GrpID,CleanTDR2Sec,data(:,6));
        netcdf.putVar(CleanTDR2GrpID,CleanTDR2Depth,data(:,7));
    else
    end

    clear data

    %TDR2 ZOC
    try
        data=readmatrix(TDR2ZOCFiles.folder(TDR2ZOCFiles.TOPPID==TOPPID),'\',...
            TDR2ZOCFiles.filename(TDR2ZOCFiles.TOPPID==TOPPID),'HeaderLines',26);
    end
    %Define length dimension and variables for TDR1 ZOC
    netcdf.reDef(ncid);
    if exist('data','var')==1
        ZOCTDR2dimid=netcdf.defDim(ncid,'ZOCTDR2_rows',size(data,1));
    else
        ZOCTDR2dimid=netcdf.defDim(ncid,'ZOCTDR2_rows',0);
    end
    ZOCTDR2Date=netcdf.defVar(ZOCTDR2GrpID,'DATE','NC_DOUBLE',ZOCTDR2dimid);
    netcdf.putAtt(ZOCTDR2GrpID,ZOCTDR2Date,'Description','MATLAB serial date');
    netcdf.putAtt(ZOCTDR2GrpID,ZOCTDR2Date,'Origin','January 0, 0000 in the proleptic ISO calendar');
    ZOCTDR2CorrDepth=netcdf.defVar(ZOCTDR2GrpID,'CORR_DEPTH','NC_DOUBLE',ZOCTDR2dimid);
    netcdf.putAtt(ZOCTDR2GrpID,ZOCTDR2CorrDepth,'Description','Depth corrected for true surface')
    netcdf.putAtt(ZOCTDR2GrpID,ZOCTDR2CorrDepth,'Units','meters')
    ZOCTDR2Depth=netcdf.defVar(ZOCTDR2GrpID,'DEPTH','NC_DOUBLE',ZOCTDR2dimid);
    netcdf.putAtt(ZOCTDR2GrpID,ZOCTDR2Depth,'Description','Uncorrected depth')
    netcdf.putAtt(ZOCTDR2GrpID,ZOCTDR2Depth,'Units','meters')
    netcdf.endDef(ZOCTDR2GrpID);

    %Write in data
    if ~isempty(data)
        netcdf.putVar(ZOCTDR2GrpID,ZOCTDR2Date,data(:,2));
        netcdf.putVar(ZOCTDR2GrpID,ZOCTDR2CorrDepth,data(:,1));
        netcdf.putVar(ZOCTDR2GrpID,ZOCTDR2Depth,data(:,3));
    else
    end
    clear data

    %TDR2 Clean
    try
        data=readmatrix(TDR2CleanFiles.folder(TDR2CleanFiles.TOPPID==TOPPID),'\',...
            TDR2CleanFiles.filename(TDR2CleanFiles.TOPPID==TOPPID));
    end
    %Define length dimension and variables for TDR2 Clean
    netcdf.reDef(ncid);
    if exist('data','var')==1
        CleanTDR2dimid=netcdf.defDim(ncid,'CleanTDR2_rows',size(data,1));
    else
        CleanTDR2dimid=netcdf.defDim(ncid,'CleanTDR2_rows',0);
    end
    CleanTDR2Year=netcdf.defVar(CleanTDR2GrpID,'YEAR','NC_DOUBLE',CleanTDR2dimid);
    CleanTDR2Month=netcdf.defVar(CleanTDR2GrpID,'MONTH','NC_DOUBLE',CleanTDR2dimid);
    CleanTDR2Day=netcdf.defVar(CleanTDR2GrpID,'DAY','NC_DOUBLE',CleanTDR2dimid);
    CleanTDR2Hour=netcdf.defVar(CleanTDR2GrpID,'HOUR','NC_DOUBLE',CleanTDR2dimid);
    CleanTDR2Min=netcdf.defVar(CleanTDR2GrpID,'MIN','NC_DOUBLE',CleanTDR2dimid);
    CleanTDR2Sec=netcdf.defVar(CleanTDR2GrpID,'SEC','NC_DOUBLE',CleanTDR2dimid);
    CleanTDR2Depth=netcdf.defVar(CleanTDR2GrpID,'DEPTH','NC_DOUBLE',CleanTDR2dimid);
    netcdf.endDef(ncid);

    %Write in Data
    if ~isempty(data)
        netcdf.putVar(CleanTDR2GrpID,CleanTDR2Year,data(:,1));
        netcdf.putVar(CleanTDR2GrpID,CleanTDR2Month,data(:,2));
        netcdf.putVar(CleanTDR2GrpID,CleanTDR2Day,data(:,3));
        netcdf.putVar(CleanTDR2GrpID,CleanTDR2Hour,data(:,4));
        netcdf.putVar(CleanTDR2GrpID,CleanTDR2Min,data(:,5));
        netcdf.putVar(CleanTDR2GrpID,CleanTDR2Sec,data(:,6));
        netcdf.putVar(CleanTDR2GrpID,CleanTDR2Depth,data(:,7));
    else
    end
    clear data

    %TDR2 ZOC
    try
        data=readmatrix(TDR2ZOCFiles.folder(TDR2ZOCFiles.TOPPID==TOPPID),'\',...
            TDR2ZOCFiles.filename(TDR2ZOCFiles.TOPPID==TOPPID),'HeaderLines',26);
    end
    %Define length dimension and variables for TDR1 ZOC
    netcdf.reDef(ncid);
    if exist('data','var')==1
        ZOCTDR2dimid=netcdf.defDim(ncid,'ZOCTDR2_rows',size(data,1));
    else
        ZOCTDR2dimid=netcdf.defDim(ncid,'ZOCTDR2_rows',0);
    end
    ZOCTDR2Date=netcdf.defVar(ZOCTDR2GrpID,'DATE','NC_DOUBLE',ZOCTDR2dimid);
    netcdf.putAtt(ZOCTDR2GrpID,ZOCTDR2Date,'Description','MATLAB serial date');
    netcdf.putAtt(ZOCTDR2GrpID,ZOCTDR2Date,'Origin','January 0, 0000 in the proleptic ISO calendar');
    ZOCTDR2CorrDepth=netcdf.defVar(ZOCTDR2GrpID,'CORR_DEPTH','NC_DOUBLE',ZOCTDR2dimid);
    netcdf.putAtt(ZOCTDR2GrpID,ZOCTDR2CorrDepth,'Description','Depth corrected for true surface')
    netcdf.putAtt(ZOCTDR2GrpID,ZOCTDR2CorrDepth,'Units','meters')
    ZOCTDR2Depth=netcdf.defVar(ZOCTDR2GrpID,'DEPTH','NC_DOUBLE',ZOCTDR2dimid);
    netcdf.putAtt(ZOCTDR2GrpID,ZOCTDR2Depth,'Description','Uncorrected depth')
    netcdf.putAtt(ZOCTDR2GrpID,ZOCTDR2Depth,'Units','meters')
    netcdf.endDef(ZOCTDR2GrpID);

    %Write in data
    if ~isempty(data)
        netcdf.putVar(ZOCTDR2GrpID,ZOCTDR2Date,data(:,2));
        netcdf.putVar(ZOCTDR2GrpID,ZOCTDR2CorrDepth,data(:,1));
        netcdf.putVar(ZOCTDR2GrpID,ZOCTDR2Depth,data(:,3));
    else
    end
    clear data
    
netcdf.close(ncid);

    %% Create level 3 netCDF file, groups, and global attributes
    filename=[num2str(TOPPID) '_TrackTDR_Processed.nc'];
    ncid=netcdf.create(filename,'CLOBBER');

    %Data Groups
    TDR1GrpID=netcdf.defGrp(ncid,'TDR1');
    TDR1SubGrpID=netcdf.defGrp(ncid,'TDR1_SUB');
    TDR2GrpID=netcdf.defGrp(ncid,'TDR2');
    TDR2SubGrpID=netcdf.defGrp(ncid,'TDR2_SUB');
    TDR3GrpID=netcdf.defGrp(ncid,'TDR3');
    TDR3SubGrpID=netcdf.defGrp(ncid,'TDR3_SUB');
    foieGrasGrpID=netcdf.defGrp(ncid,'FOIE_GRAS');

    %Global Attributes
    %%%%%Creation/versions/permissions
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"), "_____DATA_PROCESSING_AND_ATTRIBUTION_____",'________');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"), 'creation_date',string(datetime("now")));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "MATLAB Version", version);
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "R Version", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "foieGras Version", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "DA-ZOC Version", '2.2/1.1');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Data_Owner", 'Daniel Costa');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Is_Data_Public",...
        'Yes: data can be used freely as long as data owner is properly cited');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Citation", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Citation_DOI", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Data_Type", 'Tracking and diving time-series data');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Data_Assembly_By", 'UCSC/Rachel Holser');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Timezone", 'UTC');

    %%%%%Animal MetaData    
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "____ANIMAL_METADATA____",'________');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "SealID",'');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Species", 'Mirounga angustirostris');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Sex", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Age_Class", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Birth_Year", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Had_Pup", '');
    
    %%%%%Deployment MetaData
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "____DEPLOYMENT_METADATA____",'________');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "DeploymentID",TOPPID);
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Deployment_Year", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Deployment_Season", string(MetaDataAll.Season(j)));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Instruments_Recovered", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Other_Deployments",'' ); %Need to build this in somehow
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Departure_Location", string(MetaDataAll.DepartLoc(j)));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Departure_Lat", MetaDataAll.DepartLat(j));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Departure_Lon", MetaDataAll.DepartLon(j));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Departure_Datetime", string(MetaDataAll.DepartDate(j)));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Arrival_Location", string(MetaDataAll.ArriveLoc(j)));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Arrival_Lat", MetaDataAll.ArriveLat(j));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Arrival_Lon", MetaDataAll.ArriveLon(j));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Arrival_Datetime", string(MetaDataAll.ArriveDate(j))); 
    
    %%%%%Data Quality
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "____DATA_QUALITY____",'________');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Track_QC_Flag",'');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR1_QC_Flag",'');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR2_QC_Flag",'');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR3_QC_Flag",'');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR1_SamplingFrequency", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR1_DepthResolution", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR2_SamplingFrequency", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR2_DepthResolution", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR3_SamplingFrequency", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR3_DepthResolution", '');

    %%%%%Instrument MetaData
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "____INSTRUMENT_METADATA____",'________');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "PTT", TagMetaDataAll.SatTagPTT(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Argos_Tag_Model", TagMetaDataAll.SatTagType(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Argos_Tag_ID", TagMetaDataAll.SatTagID(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "Argos_Tag_Manufacturer", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "GPS_Tag_Model", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "GPS_Tag_ID", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "GPS_Tag_Manufacturer", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR1_Tag_Model", TagMetaDataAll.TDR1Type(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR1_Tag_ID", TagMetaDataAll.TDR1ID(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR1_Tag_Manufacturer", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR1_Comments", TagMetaDataAll.TDR1Comment(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR2_Tag_Model", TagMetaDataAll.TDR2Type(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR2_Tag_ID", TagMetaDataAll.TDR2ID(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR2_Tag_Manufacturer", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR2_Comments", TagMetaDataAll.TDR2Comment(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR3_Tag_Model", TagMetaDataAll.TDR3Type(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR3_Tag_ID", TagMetaDataAll.TDR3ID(i));
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR3_Tag_Manufacturer", '');
    netcdf.putAtt(ncid, netcdf.getConstant("NC_GLOBAL"),  "TDR3_Comments", TagMetaDataAll.TDR3Comment(i));

%% Primary Variables
    % TDR1 DiveStat
    %load DiveStat file
    try
        data=readtable(strcat(TDRDiveStatFiles.folder(TDRDiveStatFiles.TOPPID==TOPPID),'\',...
            TDRDiveStatFiles.filename(TDRDiveStatFiles.TOPPID==TOPPID)),'NumHeaderLines',25);
        data.DateTime=datetime(data.JulDate,"ConvertFrom","datenum");
    end
    %Create a 1-D variable (length of divestat x 1) for each column of the
    %DiveStat file and populate each from the loaded file
    netcdf.reDef(ncid);
    if exist('data','var')==1
        TDR1dimid=netcdf.defDim(TDR1GrpID,'TDR1_NumDives',size(data,1));
    else
        TDR1dimid=netcdf.defDim(TDR1GrpID,'TDR1_NumDives',0);
    end

    TDR1Date=netcdf.defVar(TDR1GrpID,'TDR1_DATE',"NC_STRING",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1Date,"Description","Date and time at of the start of the dive")
    netcdf.putAtt(TDR1GrpID,TDR1Date,'Time Zone','UTC');
    TDR1Depth=netcdf.defVar(TDR1GrpID,'TDR1_MAXDEPTH',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1Depth,'Description','Maximum depth recorded during dive');
    netcdf.putAtt(TDR1GrpID,TDR1Depth,'Units','meters');
    TDR1Dur=netcdf.defVar(TDR1GrpID,'TDR1_DURATION',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1Dur,'Description','Total duration of the dive');
    netcdf.putAtt(TDR1GrpID,TDR1Dur,'Units','seconds');
    TDR1DTime=netcdf.defVar(TDR1GrpID,'TDR1_DESC_TIME',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1DTime,'Description','Time spend in descent phase of dive');
    netcdf.putAtt(TDR1GrpID,TDR1DTime,'Units','seconds');
    TDR1BTime=netcdf.defVar(TDR1GrpID,'TDR1_BOTT_TIME',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1BTime,'Description','Time spend in bottom phase of dive');
    netcdf.putAtt(TDR1GrpID,TDR1BTime,'Units','seconds');
    TDR1ATime=netcdf.defVar(TDR1GrpID,'TDR1_ASC_TIME',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1ATime,'Description','Time spend in ascent phase of dive');
    netcdf.putAtt(TDR1GrpID,TDR1ATime,'Units','seconds');
    TDR1DRate=netcdf.defVar(TDR1GrpID,'TDR1_DESC_RATE',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1DRate,'Description','Average rate of descent');
    netcdf.putAtt(TDR1GrpID,TDR1DRate,'Units','meters per second');
    TDR1ARate=netcdf.defVar(TDR1GrpID,'TDR1_ASC_RATE',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1ARate,'Description','Average rate of ascent');
    netcdf.putAtt(TDR1GrpID,TDR1ARate,'Units','meters per second');
    TDR1PDI=netcdf.defVar(TDR1GrpID,'TDR1_PDI',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1PDI,"Description","Post-Dive Interval (surface time after the dive)");
    netcdf.putAtt(TDR1GrpID,TDR1PDI,'Units','seconds');
    TDR1DWigD=netcdf.defVar(TDR1GrpID,'TDR1_WIGGLES_DESC',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1DWigD,'Description',"Number of vertical inflections detected during descent" + ...
        " phase");
    netcdf.putAtt(TDR1GrpID,TDR1DWigD,'Units',"Count");
    TDR1DWigB=netcdf.defVar(TDR1GrpID,'TDR1_WIGGLES_BOTT',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1DWigB,'Description',"Number of vertical inflections detected during bottom" + ...
        " phase");
    netcdf.putAtt(TDR1GrpID,TDR1DWigB,'Units',"Count");
    TDR1DWigA=netcdf.defVar(TDR1GrpID,'TDR1_WIGGLES_ASC',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1DWigA,'Description',"Number of vertical inflections detected during ascent" + ...
        " phase");
    netcdf.putAtt(TDR1GrpID,TDR1DWigA,'Units',"Count");
    TDR1TotVertDist=netcdf.defVar(TDR1GrpID,'TDR1_TOT_VERT_DIST_BOTT',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1TotVertDist,"Description","Sum of all of the depth changes during the" + ...
        " bottom phase of the dive");
    netcdf.putAtt(TDR1GrpID,TDR1TotVertDist,"Units","meters");
    TDR1BottRng=netcdf.defVar(TDR1GrpID,'TDR1_BOTT_RANGE',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1BottRng,"Description","Difference between max and min depth of the bottom phase");
    netcdf.putAtt(TDR1GrpID,TDR1BottRng,"Units","meters");
    TDR1Eff=netcdf.defVar(TDR1GrpID,'TDR1_EFFICIENCY',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1Eff,"Description","Ratio of bottom time to dive cycle (Duration + PDI)")
    netcdf.putAtt(TDR1GrpID,TDR1Eff,"Units","")
    TDR1IDZ=netcdf.defVar(TDR1GrpID,'TDR1_IDZ',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1IDZ,"Description","Intra-Depth Zone: a binary (0,1) indicator of whether" + ...
        " the max depth of the dive is within 20% of the max depth of the previous dive (see Tremblay" + ...
        " & Cherel, 2000)")
    netcdf.putAtt(TDR1GrpID,TDR1IDZ,"Units","")
    TDR1SolarEl=netcdf.defVar(TDR1GrpID,'TDR1_SOLAR_EL',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1SolarEl,"Description","Angle of the sun relative to the horizon line" + ...
        " (-90\circ - 90 \circ) calculated from lat, lon, date, and time.");
    netcdf.putAtt(TDR1GrpID,TDR1SolarEl,"Units","\circ");
    TDR1Lat=netcdf.defVar(TDR1GrpID,'TDR1_LAT',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1Lat,"Description","Decimal latitude at the start of the dive")
    TDR1Lon=netcdf.defVar(TDR1GrpID,'TDR1_LON',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1Lon,"Description","Decimal longitude at the start of the dive")
    TDR1LatSE=netcdf.defVar(TDR1GrpID,'TDR1_LAT_SE_KM',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1LatSE,"Description","Latitude error")
    netcdf.putAtt(TDR1GrpID,TDR1LatSE,"Units","km")
    TDR1LonSE=netcdf.defVar(TDR1GrpID,'TDR1_LON_SE_KM',"NC_DOUBLE",TDR1dimid);
    netcdf.putAtt(TDR1GrpID,TDR1LonSE,"Description","Longitude error")
    netcdf.putAtt(TDR1GrpID,TDR1LonSE,"Units","km")
    TDR1Year=netcdf.defVar(TDR1GrpID,'TDR1_YEAR',"NC_DOUBLE",TDR1dimid);
    TDR1Month=netcdf.defVar(TDR1GrpID,'TDR1_MONTH',"NC_DOUBLE",TDR1dimid);
    TDR1Day=netcdf.defVar(TDR1GrpID,'TDR1_DAY',"NC_DOUBLE",TDR1dimid);
    TDR1Hour=netcdf.defVar(TDR1GrpID,'TDR1_HOUR',"NC_DOUBLE",TDR1dimid);
    TDR1Min=netcdf.defVar(TDR1GrpID,'TDR1_MIN',"NC_DOUBLE",TDR1dimid);
    TDR1Sec=netcdf.defVar(TDR1GrpID,'TDR1_SEC',"NC_DOUBLE",TDR1dimid);
    netcdf.endDef(TDR1GrpID);

    if ~isempty(data)
        netcdf.putVar(TDR1GrpID,TDR1Date,string(data.DateTime));
        netcdf.putVar(TDR1GrpID,TDR1Depth,data.Maxdepth);
        netcdf.putVar(TDR1GrpID,TDR1Dur,data.Dduration);
        netcdf.putVar(TDR1GrpID,TDR1DTime,data.DescTime);
        netcdf.putVar(TDR1GrpID,TDR1BTime,data.Botttime);
        netcdf.putVar(TDR1GrpID,TDR1ATime,data.AscTime);
        netcdf.putVar(TDR1GrpID,TDR1DRate,data.DescRate);
        netcdf.putVar(TDR1GrpID,TDR1ARate,data.AscRate);
        netcdf.putVar(TDR1GrpID,TDR1PDI,data.PDI);
        netcdf.putVar(TDR1GrpID,TDR1DWigD,data.DWigglesDesc);
        netcdf.putVar(TDR1GrpID,TDR1DWigB,data.DWigglesBott);
        netcdf.putVar(TDR1GrpID,TDR1DWigA,data.DWigglesAsc);
        netcdf.putVar(TDR1GrpID,TDR1TotVertDist,data.TotVertDistBot);
        netcdf.putVar(TDR1GrpID,TDR1BottRng,data.BottRange);
        netcdf.putVar(TDR1GrpID,TDR1IDZ,data.IDZ);
        %netcdf.putVar(TDR1GrpID,TDR1SolarEl,data.SolarEl);
        %netcdf.putVar(TDR1GrpID,TDR1Lat,data.Lat);
        %netcdf.putVar(TDR1GrpID,TDR1Lon,data.Lon);
        %netcdf.putVar(TDR1GrpID,TDR1LatSE,data.Lat);
        %netcdf.putVar(TDR1GrpID,TDR1LonSE,data.Lat);
        netcdf.putVar(TDR1GrpID,TDR1Year,data.Year);
        netcdf.putVar(TDR1GrpID,TDR1Month,data.Month);
        netcdf.putVar(TDR1GrpID,TDR1Day,data.Day);
        netcdf.putVar(TDR1GrpID,TDR1Hour,data.Hour);
        netcdf.putVar(TDR1GrpID,TDR1Min,data.Min);
        netcdf.putVar(TDR1GrpID,TDR1Sec,data.Sec);
    else
    end
    clear data
    
    % TDR2 DiveStat
    %load DiveStat file
    try
        data=readtable(strcat(TDR2DiveStatFiles.folder(TDR2DiveStatFiles.TOPPID==TOPPID),'\',...
            TDR2DiveStatFiles.filename(TDR2DiveStatFiles.TOPPID==TOPPID)),'NumHeaderLines',25);
        data.DateTime=datetime(data.JulDate,"ConvertFrom","datenum");
    end
    %Create a 1-D variable (length of divestat x 1) for each column of the
    %DiveStat file and populate each from the loaded file
    netcdf.reDef(ncid);
    if exist('data','var')==1
        TDR2dimid=netcdf.defDim(TDR2GrpID,'TDR2_NumDives',size(data,1));
    else
        TDR2dimid=netcdf.defDim(TDR2GrpID,'TDR2_NumDives',0);
    end

    TDR2Date=netcdf.defVar(TDR2GrpID,'TDR2_DATE',"NC_STRING",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2Date,"Description","Date and time at of the start of the dive")
    netcdf.putAtt(TDR2GrpID,TDR2Date,'Time Zone','UTC');
    TDR2Depth=netcdf.defVar(TDR2GrpID,'TDR2_MAXDEPTH',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2Depth,'Description','Maximum depth recorded during dive');
    netcdf.putAtt(TDR2GrpID,TDR2Depth,'Units','meters');
    TDR2Dur=netcdf.defVar(TDR2GrpID,'TDR2_DURATION',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2Dur,'Description','Total duration of the dive');
    netcdf.putAtt(TDR2GrpID,TDR2Dur,'Units','seconds');
    TDR2DTime=netcdf.defVar(TDR2GrpID,'TDR2_DESC_TIME',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2DTime,'Description','Time spend in descent phase of dive');
    netcdf.putAtt(TDR2GrpID,TDR2DTime,'Units','seconds');
    TDR2BTime=netcdf.defVar(TDR2GrpID,'TDR2_BOTT_TIME',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2BTime,'Description','Time spend in bottom phase of dive');
    netcdf.putAtt(TDR2GrpID,TDR2BTime,'Units','seconds');
    TDR2ATime=netcdf.defVar(TDR2GrpID,'TDR2_ASC_TIME',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2ATime,'Description','Time spend in ascent phase of dive');
    netcdf.putAtt(TDR2GrpID,TDR2ATime,'Units','seconds');
    TDR2DRate=netcdf.defVar(TDR2GrpID,'TDR2_DESC_RATE',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2DRate,'Description','Average rate of descent');
    netcdf.putAtt(TDR2GrpID,TDR2DRate,'Units','meters per second');
    TDR2ARate=netcdf.defVar(TDR2GrpID,'TDR2_ASC_RATE',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2ARate,'Description','Average rate of ascent');
    netcdf.putAtt(TDR2GrpID,TDR2ARate,'Units','meters per second');
    TDR2PDI=netcdf.defVar(TDR2GrpID,'TDR2_PDI',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2PDI,"Description","Post-Dive Interval (surface time after the dive)");
    netcdf.putAtt(TDR2GrpID,TDR2PDI,'Units','seconds');
    TDR2DWigD=netcdf.defVar(TDR2GrpID,'TDR2_WIGGLES_DESC',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2DWigD,'Description',"Number of vertical inflections detected during descent" + ...
        " phase")
    netcdf.putAtt(TDR2GrpID,TDR2DWigD,'Units',"Count")
    TDR2DWigB=netcdf.defVar(TDR2GrpID,'TDR2_WIGGLES_BOTT',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2DWigB,'Description',"Number of vertical inflections detected during bottom" + ...
        " phase")
    netcdf.putAtt(TDR2GrpID,TDR2DWigB,'Units',"Count")
    TDR2DWigA=netcdf.defVar(TDR2GrpID,'TDR2_WIGGLES_ASC',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2DWigA,'Description',"Number of vertical inflections detected during ascent" + ...
        " phase")
    netcdf.putAtt(TDR2GrpID,TDR2DWigA,'Units',"Count")
    TDR2TotVertDist=netcdf.defVar(TDR2GrpID,'TDR2_TOT_VERT_DIST_BOTT',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2TotVertDist,"Description","Sum of all of the depth changes during the" + ...
        " bottom phase of the dive")
    netcdf.putAtt(TDR2GrpID,TDR2TotVertDist,"Units","meters")
    TDR2BottRng=netcdf.defVar(TDR2GrpID,'TDR2_BOTT_RANGE',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2BottRng,"Description","Difference between max and min depth of the bottom phase")
    netcdf.putAtt(TDR2GrpID,TDR2BottRng,"Units","meters")
    TDR2Eff=netcdf.defVar(TDR2GrpID,'TDR2_EFFICIENCY',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2Eff,"Description","Ratio of bottom time to dive cycle (Duration + PDI)")
    netcdf.putAtt(TDR2GrpID,TDR2Eff,"Units","")
    TDR2IDZ=netcdf.defVar(TDR2GrpID,'TDR2_IDZ',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2IDZ,"Description","Intra-Depth Zone: a binary (0,1) indicator of whether" + ...
        " the max depth of the dive is within 20% of the max depth of the previous dive (see Tremblay" + ...
        " & Cherel, 2000)")
    netcdf.putAtt(TDR2GrpID,TDR2IDZ,"Units","")
    TDR2SolarEl=netcdf.defVar(TDR2GrpID,'TDR2_SOLAR_EL',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2SolarEl,"Description","Angle of the sun relative to the horizon line" + ...
        " (-90\circ - 90 \circ) calculated from lat, lon, date, and time.")
    netcdf.putAtt(TDR2GrpID,TDR2SolarEl,"Units","\circ")
    TDR2Lat=netcdf.defVar(TDR2GrpID,'TDR2_LAT',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2Lat,"Description","Decimal latitude at the start of the dive")
    TDR2Lon=netcdf.defVar(TDR2GrpID,'TDR2_LON',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2Lon,"Description","Decimal longitude at the start of the dive")
    TDR2LatSE=netcdf.defVar(TDR2GrpID,'TDR2_LAT_SE_KM',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2LatSE,"Description","Latitude error")
    netcdf.putAtt(TDR2GrpID,TDR2LatSE,"Units","km")
    TDR2LonSE=netcdf.defVar(TDR2GrpID,'TDR2_LON_SE_KM',"NC_DOUBLE",TDR2dimid);
    netcdf.putAtt(TDR2GrpID,TDR2LonSE,"Description","Longitude error")
    netcdf.putAtt(TDR2GrpID,TDR2LonSE,"Units","km")
    TDR2Year=netcdf.defVar(TDR2GrpID,'TDR2_YEAR',"NC_DOUBLE",TDR2dimid);
    TDR2Month=netcdf.defVar(TDR2GrpID,'TDR2_MONTH',"NC_DOUBLE",TDR2dimid);
    TDR2Day=netcdf.defVar(TDR2GrpID,'TDR2_DAY',"NC_DOUBLE",TDR2dimid);
    TDR2Hour=netcdf.defVar(TDR2GrpID,'TDR2_HOUR',"NC_DOUBLE",TDR2dimid);
    TDR2Min=netcdf.defVar(TDR2GrpID,'TDR2_MIN',"NC_DOUBLE",TDR2dimid);
    TDR2Sec=netcdf.defVar(TDR2GrpID,'TDR2_SEC',"NC_DOUBLE",TDR2dimid);
    netcdf.endDef(ncid);

    if exist('data','var')==1
        netcdf.putVar(TDR2GrpID,TDR2Date,string(data.DateTime));
        netcdf.putVar(TDR2GrpID,TDR2Depth,data.Maxdepth);
        netcdf.putVar(TDR2GrpID,TDR2Dur,data.Dduration);
        netcdf.putVar(TDR2GrpID,TDR2DTime,data.DescTime);
        netcdf.putVar(TDR2GrpID,TDR2BTime,data.Botttime);
        netcdf.putVar(TDR2GrpID,TDR2ATime,data.AscTime);
        netcdf.putVar(TDR2GrpID,TDR2DRate,data.DescRate);
        netcdf.putVar(TDR2GrpID,TDR2ARate,data.AscRate);
        netcdf.putVar(TDR2GrpID,TDR2PDI,data.PDI);
        netcdf.putVar(TDR2GrpID,TDR2DWigD,data.DWigglesDesc);
        netcdf.putVar(TDR2GrpID,TDR2DWigB,data.DWigglesBott);
        netcdf.putVar(TDR2GrpID,TDR2DWigA,data.DWigglesAsc);
        netcdf.putVar(TDR2GrpID,TDR2TotVertDist,data.TotVertDistBot);
        netcdf.putVar(TDR2GrpID,TDR2BottRng,data.BottRange);
        netcdf.putVar(TDR2GrpID,TDR2IDZ,data.IDZ);
        %netcdf.putVar(TDR2GrpID,TDR2SolarEl,data.SolarEl);
        %netcdf.putVar(TDR2GrpID,TDR2Lat,data.Lat);
        %netcdf.putVar(TDR2GrpID,TDR2Lon,data.Lon);
        %netcdf.putVar(TDR2GrpID,TDR2LatSE,data.Lat);
        %netcdf.putVar(TDR2GrpID,TDR2LonSE,data.Lat);
        netcdf.putVar(TDR2GrpID,TDR2Year,data.Year);
        netcdf.putVar(TDR2GrpID,TDR2Month,data.Month);
        netcdf.putVar(TDR2GrpID,TDR2Day,data.Day);
        netcdf.putVar(TDR2GrpID,TDR2Hour,data.Hour);
        netcdf.putVar(TDR2GrpID,TDR2Min,data.Min);
        netcdf.putVar(TDR2GrpID,TDR2Sec,data.Sec);
    else
    end
    clear data

    % TDR3 DiveStat
    %load DiveStat file
    try
        data=readtable(strcat(TDR3DiveStatFiles.folder(TDR3DiveStatFiles.TOPPID==TOPPID),'\',...
            TDR3DiveStatFiles.filename(TDR3DiveStatFiles.TOPPID==TOPPID)),'NumHeaderLines',25);
        data.DateTime=datetime(data.JulDate,"ConvertFrom","datenum");
    end
    %Create a 1-D variable (length of divestat x 1) for each column of the
    %DiveStat file and populate each from the loaded file
    netcdf.reDef(ncid);
    if exist('data','var')==1
        TDR3dimid=netcdf.defDim(TDR3GrpID,'TDR3_NumDives',size(data,1));
    else
        TDR3dimid=netcdf.defDim(TDR3GrpID,'TDR3_NumDives',0);
    end

    TDR3Date=netcdf.defVar(TDR3GrpID,'TDR3_DATE',"NC_STRING",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3Date,"Description","Date and time at of the start of the dive")
    netcdf.putAtt(TDR3GrpID,TDR3Date,'Time Zone','UTC');
    TDR3Depth=netcdf.defVar(TDR3GrpID,'TDR3_MAXDEPTH',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3Depth,'Description','Maximum depth recorded during dive');
    netcdf.putAtt(TDR3GrpID,TDR3Depth,'Units','meters');
    TDR3Dur=netcdf.defVar(TDR3GrpID,'TDR3_DURATION',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3Dur,'Description','Total duration of the dive');
    netcdf.putAtt(TDR3GrpID,TDR3Dur,'Units','seconds');
    TDR3DTime=netcdf.defVar(TDR3GrpID,'TDR3_DESC_TIME',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3DTime,'Description','Time spend in descent phase of dive');
    netcdf.putAtt(TDR3GrpID,TDR3DTime,'Units','seconds');
    TDR3BTime=netcdf.defVar(TDR3GrpID,'TDR3_BOTT_TIME',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3BTime,'Description','Time spend in bottom phase of dive');
    netcdf.putAtt(TDR3GrpID,TDR3BTime,'Units','seconds');
    TDR3ATime=netcdf.defVar(TDR3GrpID,'TDR3_ASC_TIME',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3ATime,'Description','Time spend in ascent phase of dive');
    netcdf.putAtt(TDR3GrpID,TDR3ATime,'Units','seconds');
    TDR3DRate=netcdf.defVar(TDR3GrpID,'TDR3_DESC_RATE',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3DRate,'Description','Average rate of descent');
    netcdf.putAtt(TDR3GrpID,TDR3DRate,'Units','meters per second');
    TDR3ARate=netcdf.defVar(TDR3GrpID,'TDR3_ASC_RATE',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3ARate,'Description','Average rate of ascent');
    netcdf.putAtt(TDR3GrpID,TDR3ARate,'Units','meters per second');
    TDR3PDI=netcdf.defVar(TDR3GrpID,'TDR3_PDI',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3PDI,"Description","Post-Dive Interval (surface time after the dive)");
    netcdf.putAtt(TDR3GrpID,TDR3PDI,'Units','seconds');
    TDR3DWigD=netcdf.defVar(TDR3GrpID,'TDR3_WIGGLES_DESC',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3DWigD,'Description',"Number of vertical inflections detected during " + ...
        "descent phase")
    netcdf.putAtt(TDR3GrpID,TDR3DWigD,'Units',"Count")
    TDR3DWigB=netcdf.defVar(TDR3GrpID,'TDR3_WIGGLES_BOTT',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3DWigB,'Description',"Number of vertical inflections detected during " + ...
        "bottom phase")
    netcdf.putAtt(TDR3GrpID,TDR3DWigB,'Units',"Count")
    TDR3DWigA=netcdf.defVar(TDR3GrpID,'TDR3_WIGGLES_ASC',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3DWigA,'Description',"Number of vertical inflections detected during " + ...
        "ascent phase")
    netcdf.putAtt(TDR3GrpID,TDR3DWigA,'Units',"Count")
    TDR3TotVertDist=netcdf.defVar(TDR3GrpID,'TDR3_TOT_VERT_DIST_BOTT',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3TotVertDist,"Description","Sum of all of the depth changes during the " + ...
        "bottom phase of the dive")
    netcdf.putAtt(TDR3GrpID,TDR3TotVertDist,"Units","meters")
    TDR3BottRng=netcdf.defVar(TDR3GrpID,'TDR3_BOTT_RANGE',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3BottRng,"Description","Difference between max and min depth of the " + ...
        "bottom phase")
    netcdf.putAtt(TDR3GrpID,TDR3BottRng,"Units","meters")
    TDR3Eff=netcdf.defVar(TDR3GrpID,'TDR3_EFFICIENCY',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3Eff,"Description","Ratio of bottom time to dive cycle (Duration + PDI)")
    netcdf.putAtt(TDR3GrpID,TDR3Eff,"Units","")
    TDR3IDZ=netcdf.defVar(TDR3GrpID,'TDR3_IDZ',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3IDZ,"Description","Intra-Depth Zone: a binary (0,1) indicator of whether" + ...
        " the max depth of the dive is within 20% of the max depth of the previous dive (see " + ...
        "Tremblay & Cherel, 2000)")
    netcdf.putAtt(TDR3GrpID,TDR3IDZ,"Units","")
    TDR3SolarEl=netcdf.defVar(TDR3GrpID,'TDR3_SOLAR_EL',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3SolarEl,"Description","Angle of the sun relative to the horizon line" + ...
        " (-90\circ - 90 \circ) calculated from lat, lon, date, and time.")
    netcdf.putAtt(TDR3GrpID,TDR3SolarEl,"Units","\circ")
    TDR3Lat=netcdf.defVar(TDR3GrpID,'TDR3_LAT',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3Lat,"Description","Decimal latitude at the start of the dive")
    TDR3Lon=netcdf.defVar(TDR3GrpID,'TDR3_LON',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3Lon,"Description","Decimal longitude at the start of the dive")
    TDR3LatSE=netcdf.defVar(TDR3GrpID,'TDR3_LAT_SE_KM',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3LatSE,"Description","Latitude error")
    netcdf.putAtt(TDR3GrpID,TDR3LatSE,"Units","km")
    TDR3LonSE=netcdf.defVar(TDR3GrpID,'TDR3_LON_SE_KM',"NC_DOUBLE",TDR3dimid);
    netcdf.putAtt(TDR3GrpID,TDR3LonSE,"Description","Longitude error")
    netcdf.putAtt(TDR3GrpID,TDR3LonSE,"Units","km")
    TDR3Year=netcdf.defVar(TDR3GrpID,'TDR3_YEAR',"NC_DOUBLE",TDR3dimid);
    TDR3Month=netcdf.defVar(TDR3GrpID,'TDR3_MONTH',"NC_DOUBLE",TDR3dimid);
    TDR3Day=netcdf.defVar(TDR3GrpID,'TDR3_DAY',"NC_DOUBLE",TDR3dimid);
    TDR3Hour=netcdf.defVar(TDR3GrpID,'TDR3_HOUR',"NC_DOUBLE",TDR3dimid);
    TDR3Min=netcdf.defVar(TDR3GrpID,'TDR3_MIN',"NC_DOUBLE",TDR3dimid);
    TDR3Sec=netcdf.defVar(TDR3GrpID,'TDR3_SEC',"NC_DOUBLE",TDR3dimid);
    netcdf.endDef(ncid);

    if exist('data','var')==1
        netcdf.putVar(TDR3GrpID,TDR3Date,string(data.DateTime));
        netcdf.putVar(TDR3GrpID,TDR3Depth,data.Maxdepth);
        netcdf.putVar(TDR3GrpID,TDR3Dur,data.Dduration);
        netcdf.putVar(TDR3GrpID,TDR3DTime,data.DescTime);
        netcdf.putVar(TDR3GrpID,TDR3BTime,data.Botttime);
        netcdf.putVar(TDR3GrpID,TDR3ATime,data.AscTime);
        netcdf.putVar(TDR3GrpID,TDR3DRate,data.DescRate);
        netcdf.putVar(TDR3GrpID,TDR3ARate,data.AscRate);
        netcdf.putVar(TDR3GrpID,TDR3PDI,data.PDI);
        netcdf.putVar(TDR3GrpID,TDR3DWigD,data.DWigglesDesc);
        netcdf.putVar(TDR3GrpID,TDR3DWigB,data.DWigglesBott);
        netcdf.putVar(TDR3GrpID,TDR3DWigA,data.DWigglesAsc);
        netcdf.putVar(TDR3GrpID,TDR3TotVertDist,data.TotVertDistBot);
        netcdf.putVar(TDR3GrpID,TDR3BottRng,data.BottRange);
        netcdf.putVar(TDR3GrpID,TDR3IDZ,data.IDZ);
        %netcdf.putVar(TDR3GrpID,TDR3SolarEl,data.SolarEl);
        %netcdf.putVar(TDR3GrpID,TDR3Lat,data.Lat);
        %netcdf.putVar(TDR3GrpID,TDR3Lon,data.Lon);
        %netcdf.putVar(TDR3GrpID,TDR3LatSE,data.Lat);
        %netcdf.putVar(TDR3GrpID,TDR3LonSE,data.Lat);
        netcdf.putVar(TDR3GrpID,TDR3Year,data.Year);
        netcdf.putVar(TDR3GrpID,TDR3Month,data.Month);
        netcdf.putVar(TDR3GrpID,TDR3Day,data.Day);
        netcdf.putVar(TDR3GrpID,TDR3Hour,data.Hour);
        netcdf.putVar(TDR3GrpID,TDR3Min,data.Min);
        netcdf.putVar(TDR3GrpID,TDR3Sec,data.Sec);
    else
    end
    clear data

    % TDR1 Subset DiveStat
    %load DiveStat file
    try
        data=readtable(strcat(TDR1SubDiveStatFiles.folder(TDR1SubDiveStatFiles.TOPPID==TOPPID),'\',...
            TDR1SubDiveStatFiles.filename(TDR1SubDiveStatFiles.TOPPID==TOPPID)),'NumHeaderLines',25);
        data.DateTime=datetime(data.JulDate,"ConvertFrom","datenum");
    end

    %Create a 1-D variable (length of divestat x 1) for each column of the
    %DiveStat file and populate each from the loaded file
    netcdf.reDef(ncid);
    if exist('data','var')==1
        TDR1Subdimid=netcdf.defDim(TDR1SubGrpID,'TDR1Sub_NumDives',size(data,1));
    else
        TDR1Subdimid=netcdf.defDim(TDR1SubGrpID,'TDR1Sub_NumDives',0);
    end

    TDR1SubDate=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_DATE',"NC_STRING",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDate,"Description","Date and time at of the start of the dive")
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDate,'Time Zone','UTC');
    TDR1SubDepth=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_MAXDEPTH',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDepth,'Description','Maximum depth recorded during dive');
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDepth,'Units','meters');
    TDR1SubDur=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_DURATION',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDur,'Description','Total duration of the dive');
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDur,'Units','seconds');
    TDR1SubDTime=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_DESC_TIME',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDTime,'Description','Time spend in descent phase of dive');
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDTime,'Units','seconds');
    TDR1SubBTime=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_BOTT_TIME',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubBTime,'Description','Time spend in bottom phase of dive');
    netcdf.putAtt(TDR1SubGrpID,TDR1SubBTime,'Units','seconds');
    TDR1SubATime=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_ASC_TIME',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubATime,'Description','Time spend in ascent phase of dive');
    netcdf.putAtt(TDR1SubGrpID,TDR1SubATime,'Units','seconds');
    TDR1SubDRate=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_DESC_RATE',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDRate,'Description','Average rate of descent');
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDRate,'Units','meters per second');
    TDR1SubARate=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_ASC_RATE',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubARate,'Description','Average rate of ascent');
    netcdf.putAtt(TDR1SubGrpID,TDR1SubARate,'Units','meters per second');
    TDR1SubPDI=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_PDI',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubPDI,"Description","Post-Dive Interval (surface time after the dive)");
    netcdf.putAtt(TDR1SubGrpID,TDR1SubPDI,'Units','seconds');
    TDR1SubDWigD=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_WIGGLES_DESC',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDWigD,'Description',"Number of vertical inflections detected during" + ...
        " descent phase")
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDWigD,'Units',"Count")
    TDR1SubDWigB=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_WIGGLES_BOTT',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDWigB,'Description',"Number of vertical inflections detected during" + ...
        " bottom phase")
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDWigB,'Units',"Count")
    TDR1SubDWigA=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_WIGGLES_ASC',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDWigA,'Description',"Number of vertical inflections detected during" + ...
        " ascent phase")
    netcdf.putAtt(TDR1SubGrpID,TDR1SubDWigA,'Units',"Count")
    TDR1SubTotVertDist=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_TOT_VERT_DIST_BOTT',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubTotVertDist,"Description","Sum of all of the depth changes during" + ...
        " the bottom phase of the dive")
    netcdf.putAtt(TDR1SubGrpID,TDR1SubTotVertDist,"Units","meters")
    TDR1SubBottRng=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_BOTT_RANGE',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubBottRng,"Description","Difference between max and min depth of the" + ...
        " bottom phase")
    netcdf.putAtt(TDR1SubGrpID,TDR1SubBottRng,"Units","meters")
    TDR1SubEff=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_EFFICIENCY',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubEff,"Description","Ratio of bottom time to dive cycle (Duration + PDI)")
    netcdf.putAtt(TDR1SubGrpID,TDR1SubEff,"Units","")
    TDR1SubIDZ=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_IDZ',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubIDZ,"Description","Intra-Depth Zone: a binary (0,1) indicator of" + ...
        " whether the max depth of the dive is within 20% of the max depth of the previous dive" + ...
        " (see Tremblay & Cherel, 2000)")
    netcdf.putAtt(TDR1SubGrpID,TDR1SubIDZ,"Units","")
    TDR1SubSolarEl=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_SOLAR_EL',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubSolarEl,"Description","Angle of the sun relative to the horizon line" + ...
        " (-90\circ - 90 \circ) calculated from lat, lon, date, and time.")
    netcdf.putAtt(TDR1SubGrpID,TDR1SubSolarEl,"Units","\circ")
    TDR1SubLat=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_LAT',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubLat,"Description","Decimal latitude at the start of the dive")
    TDR1SubLon=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_LON',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubLon,"Description","Decimal longitude at the start of the dive")
    TDR1SubLatSE=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_LAT_SE_KM',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubLatSE,"Description","Latitude error")
    netcdf.putAtt(TDR1SubGrpID,TDR1SubLatSE,"Units","km")
    TDR1SubLonSE=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_LON_SE_KM',"NC_DOUBLE",TDR1Subdimid);
    netcdf.putAtt(TDR1SubGrpID,TDR1SubLonSE,"Description","Longitude error")
    netcdf.putAtt(TDR1SubGrpID,TDR1SubLonSE,"Units","km")
    TDR1SubYear=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_YEAR',"NC_DOUBLE",TDR1Subdimid);
    TDR1SubMonth=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_MONTH',"NC_DOUBLE",TDR1Subdimid);
    TDR1SubDay=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_DAY',"NC_DOUBLE",TDR1Subdimid);
    TDR1SubHour=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_HOUR',"NC_DOUBLE",TDR1Subdimid);
    TDR1SubMin=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_MIN',"NC_DOUBLE",TDR1Subdimid);
    TDR1SubSec=netcdf.defVar(TDR1SubGrpID,'TDR1Sub_SEC',"NC_DOUBLE",TDR1Subdimid);
    netcdf.endDef(ncid);

    if exist('data','var')==1
        netcdf.putVar(TDR1SubGrpID,TDR1SubDate,string(data.DateTime));
        netcdf.putVar(TDR1SubGrpID,TDR1SubDepth,data.Maxdepth);
        netcdf.putVar(TDR1SubGrpID,TDR1SubDur,data.Dduration);
        netcdf.putVar(TDR1SubGrpID,TDR1SubDTime,data.DescTime);
        netcdf.putVar(TDR1SubGrpID,TDR1SubBTime,data.Botttime);
        netcdf.putVar(TDR1SubGrpID,TDR1SubATime,data.AscTime);
        netcdf.putVar(TDR1SubGrpID,TDR1SubDRate,data.DescRate);
        netcdf.putVar(TDR1SubGrpID,TDR1SubARate,data.AscRate);
        netcdf.putVar(TDR1SubGrpID,TDR1SubPDI,data.PDI);
        netcdf.putVar(TDR1SubGrpID,TDR1SubDWigD,data.DWigglesDesc);
        netcdf.putVar(TDR1SubGrpID,TDR1SubDWigB,data.DWigglesBott);
        netcdf.putVar(TDR1SubGrpID,TDR1SubDWigA,data.DWigglesAsc);
        netcdf.putVar(TDR1SubGrpID,TDR1SubTotVertDist,data.TotVertDistBot);
        netcdf.putVar(TDR1SubGrpID,TDR1SubBottRng,data.BottRange);
        netcdf.putVar(TDR1SubGrpID,TDR1SubIDZ,data.IDZ);
        %netcdf.putVar(TDR1SubGrpID,TDR1SubSolarEl,data.SolarEl);
        %netcdf.putVar(TDR1SubGrpID,TDR1SubLat,data.Lat);
        %netcdf.putVar(TDR1SubGrpID,TDR1SubLon,data.Lon);
        %netcdf.putVar(TDR1SubGrpID,TDR1SubLatSE,data.Lat);
        %netcdf.putVar(TDR1SubGrpID,TDR1SubLonSE,data.Lat);
        netcdf.putVar(TDR1SubGrpID,TDR1SubYear,data.Year);
        netcdf.putVar(TDR1SubGrpID,TDR1SubMonth,data.Month);
        netcdf.putVar(TDR1SubGrpID,TDR1SubDay,data.Day);
        netcdf.putVar(TDR1SubGrpID,TDR1SubHour,data.Hour);
        netcdf.putVar(TDR1SubGrpID,TDR1SubMin,data.Min);
        netcdf.putVar(TDR1SubGrpID,TDR1SubSec,data.Sec);
    else
    end
    clear data

    % TDR2Sub DiveStat
    %load DiveStat file
    try
        data=readtable(strcat(TDR2SubDiveStatFiles.folder(TDR2SubDiveStatFiles.TOPPID==TOPPID),'\',...
            TDR2SubDiveStatFiles.filename(TDR2SubDiveStatFiles.TOPPID==TOPPID)),'NumHeaderLines',25);
        data.DateTime=datetime(data.JulDate,"ConvertFrom","datenum");
    end
    %Create a 1-D variable (length of divestat x 1) for each column of the
    %DiveStat file and populate each from the loaded file
    netcdf.reDef(ncid);
    if exist('data','var')==1
        TDR2Subdimid=netcdf.defDim(TDR2SubGrpID,'TDR2Sub_NumDives',size(data,1));
    else
        TDR2Subdimid=netcdf.defDim(TDR2SubGrpID,'TDR2Sub_NumDives',0);
    end

    TDR2SubDate=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_DATE',"NC_STRING",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDate,"Description","Date and time at of the start of the dive")
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDate,'Time Zone','UTC');
    TDR2SubDepth=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_MAXDEPTH',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDepth,'Description','Maximum depth recorded during dive');
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDepth,'Units','meters');
    TDR2SubDur=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_DURATION',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDur,'Description','Total duration of the dive');
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDur,'Units','seconds');
    TDR2SubDTime=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_DESC_TIME',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDTime,'Description','Time spend in descent phase of dive');
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDTime,'Units','seconds');
    TDR2SubBTime=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_BOTT_TIME',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubBTime,'Description','Time spend in bottom phase of dive');
    netcdf.putAtt(TDR2SubGrpID,TDR2SubBTime,'Units','seconds');
    TDR2SubATime=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_ASC_TIME',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubATime,'Description','Time spend in ascent phase of dive');
    netcdf.putAtt(TDR2SubGrpID,TDR2SubATime,'Units','seconds');
    TDR2SubDRate=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_DESC_RATE',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDRate,'Description','Average rate of descent');
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDRate,'Units','meters per second');
    TDR2SubARate=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_ASC_RATE',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubARate,'Description','Average rate of ascent');
    netcdf.putAtt(TDR2SubGrpID,TDR2SubARate,'Units','meters per second');
    TDR2SubPDI=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_PDI',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubPDI,"Description","Post-Dive Interval (surface time after the dive)");
    netcdf.putAtt(TDR2SubGrpID,TDR2SubPDI,'Units','seconds');
    TDR2SubDWigD=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_WIGGLES_DESC',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDWigD,'Description',"Number of vertical inflections detected during " + ...
        "descent phase")
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDWigD,'Units',"Count")
    TDR2SubDWigB=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_WIGGLES_BOTT',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDWigB,'Description',"Number of vertical inflections detected during " + ...
        "bottom phase")
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDWigB,'Units',"Count")
    TDR2SubDWigA=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_WIGGLES_ASC',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDWigA,'Description',"Number of vertical inflections detected during " + ...
        "ascent phase")
    netcdf.putAtt(TDR2SubGrpID,TDR2SubDWigA,'Units',"Count")
    TDR2SubTotVertDist=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_TOT_VERT_DIST_BOTT',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubTotVertDist,"Description","Sum of all of the depth changes during " + ...
        "the bottom phase of the dive")
    netcdf.putAtt(TDR2SubGrpID,TDR2SubTotVertDist,"Units","meters")
    TDR2SubBottRng=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_BOTT_RANGE',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubBottRng,"Description","Difference between max and min depth of the " + ...
        "bottom phase")
    netcdf.putAtt(TDR2SubGrpID,TDR2SubBottRng,"Units","meters")
    TDR2SubEff=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_EFFICIENCY',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubEff,"Description","Ratio of bottom time to dive cycle (Duration + PDI)")
    netcdf.putAtt(TDR2SubGrpID,TDR2SubEff,"Units","")
    TDR2SubIDZ=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_IDZ',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubIDZ,"Description","Intra-Depth Zone: a binary (0,1) indicator of" + ...
        " whether the max depth of the dive is within 20% of the max depth of the previous dive" + ...
        " (see Tremblay & Cherel, 2000)")
    netcdf.putAtt(TDR2SubGrpID,TDR2SubIDZ,"Units","")
    TDR2SubSolarEl=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_SOLAR_EL',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubSolarEl,"Description","Angle of the sun relative to the horizon" + ...
        " line (-90\circ - 90 \circ) calculated from lat, lon, date, and time.")
    netcdf.putAtt(TDR2SubGrpID,TDR2SubSolarEl,"Units","\circ")
    TDR2SubLat=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_LAT',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubLat,"Description","Decimal latitude at the start of the dive")
    TDR2SubLon=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_LON',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubLon,"Description","Decimal longitude at the start of the dive")
    TDR2SubLatSE=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_LAT_SE_KM',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubLatSE,"Description","Latitude error")
    netcdf.putAtt(TDR2SubGrpID,TDR2SubLatSE,"Units","km")
    TDR2SubLonSE=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_LON_SE_KM',"NC_DOUBLE",TDR2Subdimid);
    netcdf.putAtt(TDR2SubGrpID,TDR2SubLonSE,"Description","Longitude error")
    netcdf.putAtt(TDR2SubGrpID,TDR2SubLonSE,"Units","km")
    TDR2SubYear=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_YEAR',"NC_DOUBLE",TDR2Subdimid);
    TDR2SubMonth=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_MONTH',"NC_DOUBLE",TDR2Subdimid);
    TDR2SubDay=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_DAY',"NC_DOUBLE",TDR2Subdimid);
    TDR2SubHour=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_HOUR',"NC_DOUBLE",TDR2Subdimid);
    TDR2SubMin=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_MIN',"NC_DOUBLE",TDR2Subdimid);
    TDR2SubSec=netcdf.defVar(TDR2SubGrpID,'TDR2Sub_SEC',"NC_DOUBLE",TDR2Subdimid);
    netcdf.endDef(ncid);

    if exist('data','var')==1
        netcdf.putVar(TDR2SubGrpID,TDR2SubDate,string(data.DateTime));
        netcdf.putVar(TDR2SubGrpID,TDR2SubDepth,data.Maxdepth);
        netcdf.putVar(TDR2SubGrpID,TDR2SubDur,data.Dduration);
        netcdf.putVar(TDR2SubGrpID,TDR2SubDTime,data.DescTime);
        netcdf.putVar(TDR2SubGrpID,TDR2SubBTime,data.Botttime);
        netcdf.putVar(TDR2SubGrpID,TDR2SubATime,data.AscTime);
        netcdf.putVar(TDR2SubGrpID,TDR2SubDRate,data.DescRate);
        netcdf.putVar(TDR2SubGrpID,TDR2SubARate,data.AscRate);
        netcdf.putVar(TDR2SubGrpID,TDR2SubPDI,data.PDI);
        netcdf.putVar(TDR2SubGrpID,TDR2SubDWigD,data.DWigglesDesc);
        netcdf.putVar(TDR2SubGrpID,TDR2SubDWigB,data.DWigglesBott);
        netcdf.putVar(TDR2SubGrpID,TDR2SubDWigA,data.DWigglesAsc);
        netcdf.putVar(TDR2SubGrpID,TDR2SubTotVertDist,data.TotVertDistBot);
        netcdf.putVar(TDR2SubGrpID,TDR2SubBottRng,data.BottRange);
        netcdf.putVar(TDR2SubGrpID,TDR2SubIDZ,data.IDZ);
        %netcdf.putVar(TDR2SubGrpID,TDR2SubSolarEl,data.SolarEl);
        %netcdf.putVar(TDR2SubGrpID,TDR2SubLat,data.Lat);
        %netcdf.putVar(TDR2SubGrpID,TDR2SubLon,data.Lon);
        %netcdf.putVar(TDR2SubGrpID,TDR2SubLatSE,data.Lat);
        %netcdf.putVar(TDR2SubGrpID,TDR2SubLonSE,data.Lat);
        netcdf.putVar(TDR2SubGrpID,TDR2SubYear,data.Year);
        netcdf.putVar(TDR2SubGrpID,TDR2SubMonth,data.Month);
        netcdf.putVar(TDR2SubGrpID,TDR2SubDay,data.Day);
        netcdf.putVar(TDR2SubGrpID,TDR2SubHour,data.Hour);
        netcdf.putVar(TDR2SubGrpID,TDR2SubMin,data.Min);
        netcdf.putVar(TDR2SubGrpID,TDR2SubSec,data.Sec);
    else
    end
    clear data

    % TDR3Sub DiveStat
    %load DiveStat file
    try
        data=readtable(strcat(TDR3SubDiveStatFiles.folder(TDR3SubDiveStatFiles.TOPPID==TOPPID),'\',...
            TDR3SubDiveStatFiles.filename(TDR3SubDiveStatFiles.TOPPID==TOPPID)),'NumHeaderLines',25);
        data.DateTime=datetime(data.JulDate,"ConvertFrom","datenum");
    end

    %Create a 1-D variable (length of divestat x 1) for each column of the
    %DiveStat file and populate each from the loaded file
    netcdf.reDef(ncid);
    if exist('data','var')==1
        TDR3Subdimid=netcdf.defDim(TDR3SubGrpID,'TDR3Sub_NumDives',size(data,1));
    else
        TDR3Subdimid=netcdf.defDim(TDR3SubGrpID,'TDR3Sub_NumDives',0);
    end

    TDR3SubDate=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_DATE',"NC_STRING",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDate,"Description","Date and time at of the start of the dive")
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDate,'Time Zone','UTC');
    TDR3SubDepth=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_MAXDEPTH',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDepth,'Description','Maximum depth recorded during dive');
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDepth,'Units','meters');
    TDR3SubDur=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_DURATION',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDur,'Description','Total duration of the dive');
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDur,'Units','seconds');
    TDR3SubDTime=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_DESC_TIME',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDTime,'Description','Time spend in descent phase of dive');
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDTime,'Units','seconds');
    TDR3SubBTime=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_BOTT_TIME',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubBTime,'Description','Time spend in bottom phase of dive');
    netcdf.putAtt(TDR3SubGrpID,TDR3SubBTime,'Units','seconds');
    TDR3SubATime=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_ASC_TIME',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubATime,'Description','Time spend in ascent phase of dive');
    netcdf.putAtt(TDR3SubGrpID,TDR3SubATime,'Units','seconds');
    TDR3SubDRate=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_DESC_RATE',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDRate,'Description','Average rate of descent');
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDRate,'Units','meters per second');
    TDR3SubARate=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_ASC_RATE',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubARate,'Description','Average rate of ascent');
    netcdf.putAtt(TDR3SubGrpID,TDR3SubARate,'Units','meters per second');
    TDR3SubPDI=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_PDI',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubPDI,"Description","Post-Dive Interval (surface time after the dive)");
    netcdf.putAtt(TDR3SubGrpID,TDR3SubPDI,'Units','seconds');
    TDR3SubDWigD=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_WIGGLES_DESC',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDWigD,'Description',"Number of vertical inflections detected during " + ...
        "descent phase")
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDWigD,'Units',"Count")
    TDR3SubDWigB=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_WIGGLES_BOTT',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDWigB,'Description',"Number of vertical inflections detected during " + ...
        "bottom phase")
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDWigB,'Units',"Count")
    TDR3SubDWigA=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_WIGGLES_ASC',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDWigA,'Description',"Number of vertical inflections detected during " + ...
        "ascent phase")
    netcdf.putAtt(TDR3SubGrpID,TDR3SubDWigA,'Units',"Count")
    TDR3SubTotVertDist=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_TOT_VERT_DIST_BOTT',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubTotVertDist,"Description","Sum of all of the depth changes during " + ...
        "the bottom phase of the dive")
    netcdf.putAtt(TDR3SubGrpID,TDR3SubTotVertDist,"Units","meters")
    TDR3SubBottRng=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_BOTT_RANGE',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubBottRng,"Description","Difference between max and min depth of the " + ...
        "bottom phase")
    netcdf.putAtt(TDR3SubGrpID,TDR3SubBottRng,"Units","meters")
    TDR3SubEff=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_EFFICIENCY',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubEff,"Description","Ratio of bottom time to dive cycle (Duration + PDI)")
    netcdf.putAtt(TDR3SubGrpID,TDR3SubEff,"Units","")
    TDR3SubIDZ=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_IDZ',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubIDZ,"Description","Intra-Depth Zone: a binary (0,1) indicator of" + ...
        " whether the max depth of the dive is within 20% of the max depth of the previous dive" + ...
        " (see Tremblay & Cherel, 2000)")
    netcdf.putAtt(TDR3SubGrpID,TDR3SubIDZ,"Units","")
    TDR3SubSolarEl=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_SOLAR_EL',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubSolarEl,"Description","Angle of the sun relative to the horizon " + ...
        "line (-90\circ - 90 \circ) calculated from lat, lon, date, and time.")
    netcdf.putAtt(TDR3SubGrpID,TDR3SubSolarEl,"Units","\circ")
    TDR3SubLat=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_LAT',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubLat,"Description","Decimal latitude at the start of the dive")
    TDR3SubLon=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_LON',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubLon,"Description","Decimal longitude at the start of the dive")
    TDR3SubLatSE=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_LAT_SE_KM',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubLatSE,"Description","Latitude error")
    netcdf.putAtt(TDR3SubGrpID,TDR3SubLatSE,"Units","km")
    TDR3SubLonSE=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_LON_SE_KM',"NC_DOUBLE",TDR3Subdimid);
    netcdf.putAtt(TDR3SubGrpID,TDR3SubLonSE,"Description","Longitude error")
    netcdf.putAtt(TDR3SubGrpID,TDR3SubLonSE,"Units","km")
    TDR3SubYear=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_YEAR',"NC_DOUBLE",TDR3Subdimid);
    TDR3SubMonth=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_MONTH',"NC_DOUBLE",TDR3Subdimid);
    TDR3SubDay=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_DAY',"NC_DOUBLE",TDR3Subdimid);
    TDR3SubHour=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_HOUR',"NC_DOUBLE",TDR3Subdimid);
    TDR3SubMin=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_MIN',"NC_DOUBLE",TDR3Subdimid);
    TDR3SubSec=netcdf.defVar(TDR3SubGrpID,'TDR3Sub_SEC',"NC_DOUBLE",TDR3Subdimid);
    netcdf.endDef(ncid);

    if exist('data','var')==1
        netcdf.putVar(TDR3SubGrpID,TDR3SubDate,string(data.DateTime));
        netcdf.putVar(TDR3SubGrpID,TDR3SubDepth,data.Maxdepth);
        netcdf.putVar(TDR3SubGrpID,TDR3SubDur,data.Dduration);
        netcdf.putVar(TDR3SubGrpID,TDR3SubDTime,data.DescTime);
        netcdf.putVar(TDR3SubGrpID,TDR3SubBTime,data.Botttime);
        netcdf.putVar(TDR3SubGrpID,TDR3SubATime,data.AscTime);
        netcdf.putVar(TDR3SubGrpID,TDR3SubDRate,data.DescRate);
        netcdf.putVar(TDR3SubGrpID,TDR3SubARate,data.AscRate);
        netcdf.putVar(TDR3SubGrpID,TDR3SubPDI,data.PDI);
        netcdf.putVar(TDR3SubGrpID,TDR3SubDWigD,data.DWigglesDesc);
        netcdf.putVar(TDR3SubGrpID,TDR3SubDWigB,data.DWigglesBott);
        netcdf.putVar(TDR3SubGrpID,TDR3SubDWigA,data.DWigglesAsc);
        netcdf.putVar(TDR3SubGrpID,TDR3SubTotVertDist,data.TotVertDistBot);
        netcdf.putVar(TDR3SubGrpID,TDR3SubBottRng,data.BottRange);
        netcdf.putVar(TDR3SubGrpID,TDR3SubIDZ,data.IDZ);
        %netcdf.putVar(TDR3SubGrpID,TDR3SubSolarEl,data.SolarEl);
        %netcdf.putVar(TDR3SubGrpID,TDR3SubLat,data.Lat);
        %netcdf.putVar(TDR3SubGrpID,TDR3SubLon,data.Lon);
        %netcdf.putVar(TDR3SubGrpID,TDR3SubLatSE,data.Lat);
        %netcdf.putVar(TDR3SubGrpID,TDR3SubLonSE,data.Lat);
        netcdf.putVar(TDR3SubGrpID,TDR3SubYear,data.Year);
        netcdf.putVar(TDR3SubGrpID,TDR3SubMonth,data.Month);
        netcdf.putVar(TDR3SubGrpID,TDR3SubDay,data.Day);
        netcdf.putVar(TDR3SubGrpID,TDR3SubHour,data.Hour);
        netcdf.putVar(TDR3SubGrpID,TDR3SubMin,data.Min);
        netcdf.putVar(TDR3SubGrpID,TDR3SubSec,data.Sec);
    else
    end
    clear data

    %foieGras Track
    try
        data=readtable(strcat(TrackFoieGrasFiles.folder(TrackFoieGrasFiles.TOPPID==TOPPID),'\',...
            TrackFoieGrasFiles.filename(TrackFoieGrasFiles.TOPPID==TOPPID)));
    end
    
    netcdf.reDef(ncid);
    if exist('data','var')==1
        TrackfoieGrasdimid=netcdf.defDim(foieGrasGrpID,'TrackfoieGrasdimid',size(data,1));
    else
        TrackfoieGrasdimid=netcdf.defDim(foieGrasGrpID,'TrackfoieGrasdimid',0);
    end

    foieGrasLat=netcdf.defVar(foieGrasGrpID,'FOIEGRAS_LAT',"NC_DOUBLE",TrackfoieGrasdimid);
    netcdf.putAtt(foieGrasGrpID,foieGrasLat,"Description","foieGras track latitudes")
    netcdf.putAtt(foieGrasGrpID,foieGrasLat,'Units','decimal degrees');
    foieGrasLon=netcdf.defVar(foieGrasGrpID,'FOIEGRAS_LON',"NC_DOUBLE",TrackfoieGrasdimid);
    netcdf.putAtt(foieGrasGrpID,foieGrasLon,"Description","foieGras track longitudes")
    netcdf.putAtt(foieGrasGrpID,foieGrasLon,'Units','decimal degrees');
    foieGrasDate=netcdf.defVar(foieGrasGrpID,'FOIEGRAS_DATE',"NC_STRING",TrackfoieGrasdimid);
    netcdf.putAtt(foieGrasGrpID,foieGrasDate,"Description","Date and time of foieGras interpolated location estimate")
    netcdf.putAtt(foieGrasGrpID,foieGrasDate,'Time Zone','UTC');
    foieGrasX=netcdf.defVar(foieGrasGrpID,'FOIEGRAS_X',"NC_DOUBLE",TrackfoieGrasdimid);
    netcdf.putAtt(foieGrasGrpID,foieGrasX,"Description","foieGras interpolated location estimate longitude in km, World Mercator Projection");
    netcdf.putAtt(foieGrasGrpID,foieGrasX,'Units','km');
    foieGrasY=netcdf.defVar(foieGrasGrpID,'FOIEGRAS_Y',"NC_DOUBLE",TrackfoieGrasdimid);
    netcdf.putAtt(foieGrasGrpID,foieGrasY,"Description","foieGras interpolated location estimate latitude in km, World Mercator Projection");
    netcdf.putAtt(foieGrasGrpID,foieGrasY,'Units','km');
    foieGrasXse=netcdf.defVar(foieGrasGrpID,'FOIEGRAS_X_SE',"NC_DOUBLE",TrackfoieGrasdimid);
    netcdf.putAtt(foieGrasGrpID,foieGrasXse,"Description","foieGras interpolated location estimate standard error in longitude");
    netcdf.putAtt(foieGrasGrpID,foieGrasXse,'Units','km');
    foieGrasYse=netcdf.defVar(foieGrasGrpID,'FOIEGRAS_Y_SE',"NC_DOUBLE",TrackfoieGrasdimid);
    netcdf.putAtt(foieGrasGrpID,foieGrasYse,"Description","foieGras interpolated location estimate standard error in latitude");
    netcdf.putAtt(foieGrasGrpID,foieGrasYse,'Units','km');
    foieGrasU=netcdf.defVar(foieGrasGrpID,'FOIEGRAS_U',"NC_DOUBLE",TrackfoieGrasdimid);
    netcdf.putAtt(foieGrasGrpID,foieGrasU,"Description","foieGras estimated velocity in x direction");
    netcdf.putAtt(foieGrasGrpID,foieGrasU,'Units','m/s');
    foieGrasV=netcdf.defVar(foieGrasGrpID,'FOIEGRAS_V',"NC_DOUBLE",TrackfoieGrasdimid);
    netcdf.putAtt(foieGrasGrpID,foieGrasV,"Description","foieGras estimated velocity in y direction");
    netcdf.putAtt(foieGrasGrpID,foieGrasV,'Units','m/s');
    foieGrasUse=netcdf.defVar(foieGrasGrpID,'FOIEGRAS_U_SE',"NC_DOUBLE",TrackfoieGrasdimid);
    netcdf.putAtt(foieGrasGrpID,foieGrasUse,"Description","foieGras estimated standard error of velocity in x direction");
    netcdf.putAtt(foieGrasGrpID,foieGrasUse,'Units','m/s');
    foieGrasVse=netcdf.defVar(foieGrasGrpID,'FOIEGRAS_V_SE',"NC_DOUBLE",TrackfoieGrasdimid);
    netcdf.putAtt(foieGrasGrpID,foieGrasVse,"Description","foieGras estimated standard error of velocity in y direction");
    netcdf.putAtt(foieGrasGrpID,foieGrasVse,'Units','m/s');
    foieGrasS=netcdf.defVar(foieGrasGrpID,'FOIEGRAS_S',"NC_DOUBLE",TrackfoieGrasdimid);
    netcdf.putAtt(foieGrasGrpID,foieGrasS,"Description"," foieGras estimated directionless velocity");
    netcdf.putAtt(foieGrasGrpID,foieGrasS,'Units','m/s');
    foieGrasSse=netcdf.defVar(foieGrasGrpID,'FOIEGRAS_S_SE',"NC_DOUBLE",TrackfoieGrasdimid);
    netcdf.putAtt(foieGrasGrpID,foieGrasSse,"Description","foieGras estimated standard deviation in directionless velocity");
    netcdf.putAtt(foieGrasGrpID,foieGrasSse,'Units','m/s');
    netcdf.endDef(ncid);
    if exist('data','var')==1
        netcdf.putVar(foieGrasGrpID,foieGrasDate,string(data.date));
        netcdf.putVar(foieGrasGrpID,foieGrasLat,data.lat);
        netcdf.putVar(foieGrasGrpID,foieGrasLon,data.lon);
        netcdf.putVar(foieGrasGrpID,foieGrasX,data.x);
        netcdf.putVar(foieGrasGrpID,foieGrasY,data.y);
        netcdf.putVar(foieGrasGrpID,foieGrasXse,data.x_se);
        netcdf.putVar(foieGrasGrpID,foieGrasYse,data.y_se);
        netcdf.putVar(foieGrasGrpID,foieGrasU,data.u);
        netcdf.putVar(foieGrasGrpID,foieGrasV,data.v);
        netcdf.putVar(foieGrasGrpID,foieGrasUse,data.u_se);
        netcdf.putVar(foieGrasGrpID,foieGrasVse,data.v_se);
        netcdf.putVar(foieGrasGrpID,foieGrasS,data.s);
        netcdf.putVar(foieGrasGrpID,foieGrasSse,data.s_se);
    else
    end
    clear data
    
netcdf.close(ncid);
clearvars -except MetaDataAll TagMetaDataAll i 
end

    ncinfo(filename);
