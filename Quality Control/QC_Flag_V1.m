%Created by: R.Holser (rholser@ucsc.edu)
%Created on: 06-Dec-2022
%
% Check QC'd TDRs and designate quality control flags based on completeness of data across each
% deployment, saves updated tagmetadata into MetaData.mat
% 
%Update Log:6
% 31-Dec-2022 - add QC flags to TagMetaDataAll, currently skips 2002 and 2003.

clear
load('All_Filenames.mat');
load('MetaData.mat');

for i=16:size(MetaDataAll,1) %Skips 2002 and 2003 for the time being
    TOPPID=MetaDataAll.TOPPID(i)
    row=find(TagMetaDataAll.TOPPID==TOPPID);

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
        End=round(datenum(MetaDataAll.ArriveDate(i))-datenum(MetaDataAll.DepartDate(i)));
        Days=[0; Days; End];

        %Calculate day differences between sunsequent dives and look for
        %gaps of 2 or more days.
        DayDiffs=diff(Days(:,1));
        ind1=find(DayDiffs>2);
        ind2=find(DayDiffs==2);

        %Check for data gaps of more than 2 days (QC_Flag = 3)
        if size(ind1,1)>0
            TagMetaDataAll.TDR1QC(row)=3;
        %Check for data gaps of 2 days but not more (QC_Flag = 2)
        elseif size(ind2,1)>0 && size(ind1,1)==0
            TagMetaDataAll.TDR1QC(row)=2;
        else
            TagMetaDataAll.TDR1QC(row)=1;
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
            TagMetaDataAll.TDR1QC(row)=4;
        else
            TagMetaDataAll.TDR1QC(row)=5;
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
        End=round(datenum(MetaDataAll.ArriveDate(i))-datenum(MetaDataAll.DepartDate(i)));
        Days=[0; Days; End];

        %Calculate day differences between sunsequent dives and look for
        %gaps of 2 or more days.
        DayDiffs=diff(Days(:,1));
        ind1=find(DayDiffs>2);
        ind2=find(DayDiffs==2);

        %Check for data gaps of more than 2 days (QC_Flag = 3)
        if size(ind1,1)>0
            TagMetaDataAll.TDR2QC(row)=3;
        %Check for data gaps of 2 days but not more (QC_Flag = 2)
        elseif size(ind2,1)>0 && size(ind1,1)==0
            TagMetaDataAll.TDR2QC(row)=2;
        else
            TagMetaDataAll.TDR2QC(row)=1;
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
            TagMetaDataAll.TDR2QC(row)=4;
        else
            TagMetaDataAll.TDR2QC(row)=5;
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
        End=round(datenum(MetaDataAll.ArriveDate(i))-datenum(MetaDataAll.DepartDate(i)));
        Days=[0; Days; End];

        %Calculate day differences between sunsequent dives and look for
        %gaps of 2 or more days.
        DayDiffs=diff(Days(:,1));
        ind1=find(DayDiffs>2);
        ind2=find(DayDiffs==2);

        %Check for data gaps of more than 2 days (QC_Flag = 3)
        if size(ind1,1)>0
            TagMetaDataAll.TDR3QC(row)=3;
        %Check for data gaps of 2 days but not more (QC_Flag = 2)
        elseif size(ind2,1)>0 && size(ind1,1)==0
            TagMetaDataAll.TDR3QC(row)=2;
        else
            TagMetaDataAll.TDR3QC(row)=1;
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
            TagMetaDataAll.TDR3QC(row)=4;
        else
            TagMetaDataAll.TDR3QC(row)=5;
        end
    end
    clear data dataraw filename filenameraw Days DayDiffs
end

%% Save all metadata structure into single .mat file for later use
save('MetaData.mat','MetaDataAll','ForagingSuccessAll','TagMetaDataAll')