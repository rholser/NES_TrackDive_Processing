%Created by: R.Holser (rholser@ucsc.edu)
%Created on: 06-Dec-2022
%
% Check QC'd TDRs and designate quality control flags based on completeness
% of data across each deployment.
% 

clear
load('All_Filenames.mat');
load('MetaData.mat');

for i=1:size(MetaDataAll,1)
    TOPPID=MetaDataAll.TOPPID(i)

    %% Check TDR1
    %Find filenames for DiveStat and raw files based on TOPPID
    filename=strcat(strtok(strcat(TDRDiveStatFiles.folder(TDRDiveStatFiles.TOPPID==TOPPID),'\',...
        TDRDiveStatFiles.filename(TDRDiveStatFiles.TOPPID==TOPPID)),'.'),'_QC.csv');
    filenameraw=strcat(TDRRawFiles.folder(TDRRawFiles.TOPPID==TOPPID),'\',...
        TDRRawFiles.filename(TDRRawFiles.TOPPID==TOPPID));
    %load DiveStat file
    try
        data=readtable(filename);
        data.DateTime=datetime(data.JulDate,"ConvertFrom","datenum");
    end

    %If there is a DiveStat file, check for data continuity
    if exist('data','var')==1
        Days=round(datenum(data.DateTime-MetaDataAll.DepartDate(i)));
        Start=round(data.JulDate(1)-datenum(MetaDataAll.DepartDate(i)));
        End=round(data.JulDate(end)-datenum(MetaDataAll.DepartDate(i)));
        Days=[Start; Days; End];

        %Calculate day differences between sunsequent dives and look for
        %gaps of 2 or more days.
        DayDiffs=diff(Days(:,1));
        ind1=find(DayDiffs>2);
        ind2=find(DayDiffs==2);

        %Check for data gaps of more than 2 days (QC_Flag = 3)
        if size(ind1,1)>0
            TDR1_Flag=3;
        %Check for data gaps of 2 days but not more (QC_Flag = 2)
        elseif size(ind2,1)>0 && size(ind1,1)==0
            TDR1_Flag=2;
        else
            TDR1_Flag=1;
        end
    %If there is no DiveStat file, check for raw data. If raw data
    %exists, further processing was not completed due to instrument
    %fault (QC_Flag = 4). If no raw data, QC_Flag = 5.
    else
        %load raw file
        try
            dataraw=readtable(filenameraw);
        end
        if exist('dataraw','var')==1
            TDR1_Flag=4;
        else
            TDR1_Flag=5;
        end
    end
    clear data dataraw filename filenameraw Days DayDiffs

    %% Check TDR2
    %Find filenames for DiveStat and raw files based on TOPPID
    filename=strcat(strtok(strcat(TDR2DiveStatFiles.folder(TDR2DiveStatFiles.TOPPID==TOPPID),'\',...
        TDR2DiveStatFiles.filename(TDR2DiveStatFiles.TOPPID==TOPPID)),'.'),'_QC.csv');
    filenameraw=strcat(TDR2RawFiles.folder(TDR2RawFiles.TOPPID==TOPPID),'\',...
        TDR2RawFiles.filename(TDR2RawFiles.TOPPID==TOPPID));
    %load DiveStat file
    try
        data=readtable(filename);
        data.DateTime=datetime(data.JulDate,"ConvertFrom","datenum");
    end

    %If there is a DiveStat file, check for data continuity
    if exist('data','var')==1
        Days=round(datenum(data.DateTime-MetaDataAll.DepartDate(i)));
        Start=round(data.JulDate(1)-datenum(MetaDataAll.DepartDate(i)));
        End=round(data.JulDate(end)-datenum(MetaDataAll.DepartDate(i)));
        Days=[Start; Days; End];

        %Calculate day differences between sunsequent dives and look for
        %gaps of 2 or more days.
        DayDiffs=diff(Days(:,1));
        ind1=find(DayDiffs>2);
        ind2=find(DayDiffs==2);

        %Check for data gaps of more than 2 days (QC_Flag = 3)
        if size(ind1,1)>0
            TDR2_Flag=3;
        %Check for data gaps of 2 days but not more (QC_Flag = 2)
        elseif size(ind2,1)>0 && size(ind1,1)==0
            TDR2_Flag=2;
        else
            TDR2_Flag=1;
        end
    %If there is no DiveStat file, check for raw data. If raw data
    %exists, further processing was not completed due to instrument
    %fault (QC_Flag = 4). If no raw data, QC_Flag = 5.
    else
        %load raw file
        try
            dataraw=readtable(filenameraw);
        end
        if exist('dataraw','var')==1
            TDR2_Flag=4;
        else
            TDR2_Flag=5;
        end
    end
    clear data dataraw filename filenameraw Days DayDiffs

    %% Check TDR3
    %Find filenames for DiveStat and raw files based on TOPPID
    filename=strcat(strtok(strcat(TDR3DiveStatFiles.folder(TDR3DiveStatFiles.TOPPID==TOPPID),'\',...
        TDR3DiveStatFiles.filename(TDR3DiveStatFiles.TOPPID==TOPPID)),'.'),'_QC.csv');
    filenameraw=strcat(TDR3RawFiles.folder(TDR3RawFiles.TOPPID==TOPPID),'\',...
        TDR3RawFiles.filename(TDR3RawFiles.TOPPID==TOPPID));
    %load DiveStat file
    try
        data=readtable(filename);
        data.DateTime=datetime(data.JulDate,"ConvertFrom","datenum");
    end

    %If there is a DiveStat file, check for data continuity
    if exist('data','var')==1
        Days=round(datenum(data.DateTime-MetaDataAll.DepartDate(i)));
        Start=round(data.JulDate(1)-datenum(MetaDataAll.DepartDate(i)));
        End=round(data.JulDate(end)-datenum(MetaDataAll.DepartDate(i)));
        Days=[Start; Days; End];

        %Calculate day differences between sunsequent dives and look for
        %gaps of 2 or more days.
        DayDiffs=diff(Days(:,1));
        ind1=find(DayDiffs>2);
        ind2=find(DayDiffs==2);

        %Check for data gaps of more than 2 days (QC_Flag = 3)
        if size(ind1,1)>0
            TDR3_Flag=3;
        %Check for data gaps of 2 days but not more (QC_Flag = 2)
        elseif size(ind2,1)>0 && size(ind1,1)==0
            TDR3_Flag=2;
        else
            TDR3_Flag=1;
        end
    %If there is no DiveStat file, check for raw data. If raw data
    %exists, further processing was not completed due to instrument
    %fault (QC_Flag = 4). If no raw data, QC_Flag = 5.
    else
        %load raw file
        try
            dataraw=readtable(filenameraw);
        end
        if exist('dataraw','var')==1
            TDR3_Flag=4;
        else
            TDR3_Flag=5;
        end
    end
    clear data dataraw filename filenameraw Days DayDiffs
end

