%Created by: R.Holser (rholser@ucsc.edu)
%Created on: 02-Dec-2022
%
% Quality Control all DiveStat files
%   1: Check for 0 PDI and merge with subsequent dives
%   2: Check for Asc/Desc Rates >3 m/s
%   3: Chrck for Duration >150 min

clear
load('All_Filenames.mat');

%% TDR1 Full Resolution 
for i=1:size(TDRDiveStatFiles)
    %Pull TOPPID from filename
    TOPPID=str2double(strtok(TDRDiveStatFiles.filename(i),'_'));
    filename=strcat(TDRDiveStatFiles.folder(TDRDiveStatFiles.TOPPID==TOPPID),'\',...
        TDRDiveStatFiles.filename(TDRDiveStatFiles.TOPPID==TOPPID));
    %load DiveStat file
    data=readtable(filename,'NumHeaderLines',25);
    %locate all dives with PDI's of 0 (Dive A).
    ind=find(data.PDI==0);
    if ~isempty(ind)
        %Merge Dive A with subsequent dive (Dive B): Use descent values
        %from Dive A; combine durations, bottom times, and foraging
        %metrics; use max depth, ascent values, and IDZ from Dive B.
        %Recalculate efficiency using new values.
        for j=1:size(ind,1)
            data.Maxdepth(ind(j,1))=data.Maxdepth(ind(j,1)+1);
            data.Dduration(ind(j,1))=data.Dduration(ind(j,1))+data.Dduration(ind(j,1)+1);
            data.Botttime(ind(j,1))=data.Botttime(ind(j,1))+data.Botttime(ind(j,1)+1);
            data.AscTime(ind(j,1))=data.AscTime(ind(j,1)+1);
            data.AscRate(ind(j,1))=data.AscRate(ind(j,1)+1);
            data.PDI(ind(j,1))=data.PDI(ind(j,1)+1);
            data.DWigglesDesc(ind(j,1))=data.DWigglesDesc(ind(j,1))+data.DWigglesDesc(ind(j,1)+1);
            data.DWigglesBott(ind(j,1))=data.DWigglesBott(ind(j,1))+data.DWigglesBott(ind(j,1)+1);
            data.DWigglesAsc(ind(j,1))=data.DWigglesAsc(ind(j,1))+data.DWigglesAsc(ind(j,1)+1);
            data.TotVertDistBot(ind(j,1))=data.TotVertDistBot(ind(j,1))+data.TotVertDistBot(ind(j,1)+1);
            data.BottRange(ind(j,1))=data.BottRange(ind(j,1))+data.BottRange(ind(j,1)+1);
            data.Efficiency(ind(j,1))=data.Botttime(ind(j,1))/(data.Dduration(ind(j,1))+data.PDI(ind(j,1)));
            data.IDZ(ind(j,1))=data.IDZ(ind(j,1)+1);
        end
        %Remove Dive B
        data(ind(:,1)+1,:)=[];
    end
    %Remove dives with ascent rate over 3m/s
    ind2=find(data.AscRate>3);
    data(ind2(:,1),:)=[];
    %Remove dives with descent rate over 3m/s
    ind3=find(data.DescRate>3);
    data(ind3(:,1),:)=[];
    %Remove dives with duration over 150min
    ind4=find(data.Dduration>(150*60));
    data(ind4(:,1),:)=[];

    %Redo DiveNumber after dives removed
    m=size(data,1);
    data.DiveNumber(:)=1:m;

    writetable(data,strcat(strtok(filename,'.'),'_QC.csv'))
    clear data ind ind2 ind3 ind4 m j filename
end

%% TDR2 Full Resolution 
for i=1:size(TDR2DiveStatFiles)

    TOPPID=str2double(strtok(TDR2DiveStatFiles.filename(i),'_'));
    filename=strcat(TDR2DiveStatFiles.folder(TDR2DiveStatFiles.TOPPID==TOPPID),'\',...
        TDR2DiveStatFiles.filename(TDR2DiveStatFiles.TOPPID==TOPPID));
    %load DiveStat file
    data=readtable(filename,'NumHeaderLines',25);
    %locate all dives with PDI's of 0 (Dive A).
    ind=find(data.PDI==0);
    if ~isempty(ind)
        %Merge Dive A with subsequent dive (Dive B): Use descent values
        %from Dive A; combine durations, bottom times, and foraging
        %metrics; use max depth, ascent values, and IDZ from Dive B.
        %Recalculate efficiency using new values.
        for j=1:size(ind,1)
            data.Maxdepth(ind(j,1))=data.Maxdepth(ind(j,1)+1);
            data.Dduration(ind(j,1))=data.Dduration(ind(j,1))+data.Dduration(ind(j,1)+1);
            data.Botttime(ind(j,1))=data.Botttime(ind(j,1))+data.Botttime(ind(j,1)+1);
            data.AscTime(ind(j,1))=data.AscTime(ind(j,1)+1);
            data.AscRate(ind(j,1))=data.AscRate(ind(j,1)+1);
            data.PDI(ind(j,1))=data.PDI(ind(j,1)+1);
            data.DWigglesDesc(ind(j,1))=data.DWigglesDesc(ind(j,1))+data.DWigglesDesc(ind(j,1)+1);
            data.DWigglesBott(ind(j,1))=data.DWigglesBott(ind(j,1))+data.DWigglesBott(ind(j,1)+1);
            data.DWigglesAsc(ind(j,1))=data.DWigglesAsc(ind(j,1))+data.DWigglesAsc(ind(j,1)+1);
            data.TotVertDistBot(ind(j,1))=data.TotVertDistBot(ind(j,1))+data.TotVertDistBot(ind(j,1)+1);
            data.BottRange(ind(j,1))=data.BottRange(ind(j,1))+data.BottRange(ind(j,1)+1);
            data.Efficiency(ind(j,1))=data.Efficiency(ind(j,1)+1);
            data.IDZ(ind(j,1))=data.IDZ(ind(j,1)+1);
        end
        %Remove Dive B
        data(ind(:,1)+1,:)=[];
    end
    %Remove dives with ascent rate over 3m/s
    ind2=find(data.AscRate>3);
    data(ind2(:,1),:)=[];
    %Remove dives with descent rate over 3m/s
    ind3=find(data.DescRate>3);
    data(ind3(:,1),:)=[];
    %Remove dives with duration over 150min
    ind4=find(data.Dduration>(150*60));
    data(ind4(:,1),:)=[];

    %Redo DiveNumber after dives removed
    m=size(data,1);
    data.DiveNumber(:)=1:m;

    writetable(data,strcat(strtok(filename,'.'),'_QC.csv'))
    clear data ind ind2 ind3 ind4 m j filename
end

%% TDR3 Full Resolution 
for i=1:size(TDR3DiveStatFiles)
    TOPPID=str2double(strtok(TDR3DiveStatFiles.filename(i),'_'));
    filename=strcat(TDR3DiveStatFiles.folder(TDR3DiveStatFiles.TOPPID==TOPPID),'\',...
        TDR3DiveStatFiles.filename(TDR3DiveStatFiles.TOPPID==TOPPID));
    %load DiveStat file
    data=readtable(filename,'NumHeaderLines',25);
    %locate all dives with PDI's of 0 (Dive A).
    ind=find(data.PDI==0);
    if ~isempty(ind)
        %Merge Dive A with subsequent dive (Dive B): Use descent values
        %from Dive A; combine durations, bottom times, and foraging
        %metrics; use max depth, ascent values, and IDZ from Dive B.
        %Recalculate efficiency using new values.
        for j=1:size(ind,1)
            data.Maxdepth(ind(j,1))=data.Maxdepth(ind(j,1)+1);
            data.Dduration(ind(j,1))=data.Dduration(ind(j,1))+data.Dduration(ind(j,1)+1);
            data.Botttime(ind(j,1))=data.Botttime(ind(j,1))+data.Botttime(ind(j,1)+1);
            data.AscTime(ind(j,1))=data.AscTime(ind(j,1)+1);
            data.AscRate(ind(j,1))=data.AscRate(ind(j,1)+1);
            data.PDI(ind(j,1))=data.PDI(ind(j,1)+1);
            data.DWigglesDesc(ind(j,1))=data.DWigglesDesc(ind(j,1))+data.DWigglesDesc(ind(j,1)+1);
            data.DWigglesBott(ind(j,1))=data.DWigglesBott(ind(j,1))+data.DWigglesBott(ind(j,1)+1);
            data.DWigglesAsc(ind(j,1))=data.DWigglesAsc(ind(j,1))+data.DWigglesAsc(ind(j,1)+1);
            data.TotVertDistBot(ind(j,1))=data.TotVertDistBot(ind(j,1))+data.TotVertDistBot(ind(j,1)+1);
            data.BottRange(ind(j,1))=data.BottRange(ind(j,1))+data.BottRange(ind(j,1)+1);
            data.Efficiency(ind(j,1))=data.Efficiency(ind(j,1)+1);
            data.IDZ(ind(j,1))=data.IDZ(ind(j,1)+1);
        end
        %Remove Dive B
        data(ind(:,1)+1,:)=[];
    end
    %Remove dives with ascent rate over 3m/s
    ind2=find(data.AscRate>3);
    data(ind2(:,1),:)=[];
    %Remove dives with descent rate over 3m/s
    ind3=find(data.DescRate>3);
    data(ind3(:,1),:)=[];
    %Remove dives with duration over 150min
    ind4=find(data.Dduration>(150*60));
    data(ind4(:,1),:)=[];

    %Redo DiveNumber after dives removed
    m=size(data,1);
    data.DiveNumber(:)=1:m;

    writetable(data,strcat(strtok(filename,'.'),'_QC.csv'))
    clear data ind ind2 ind3 ind4
end

%% TDR1 Subsampled record
for i=1:size(TDRSubDiveStatFiles)
    TOPPID=str2double(strtok(TDRSubDiveStatFiles.filename(i),'_'));
    filename=strcat(TDRSubDiveStatFiles.folder(TDRSubDiveStatFiles.TOPPID==TOPPID),'\',...
        TDRSubDiveStatFiles.filename(TDRSubDiveStatFiles.TOPPID==TOPPID));
    %load DiveStat file
    data=readtable(filename,'NumHeaderLines',25);
    %locate all dives with PDI's of 0 (Dive A).
    ind=find(data.PDI==0);
    if ~isempty(ind)
        %Merge Dive A with subsequent dive (Dive B): Use descent values
        %from Dive A; combine durations, bottom times, and foraging
        %metrics; use max depth, ascent values, and IDZ from Dive B.
        %Recalculate efficiency using new values.
        for j=1:size(ind,1)
            data.Maxdepth(ind(j,1))=data.Maxdepth(ind(j,1)+1);
            data.Dduration(ind(j,1))=data.Dduration(ind(j,1))+data.Dduration(ind(j,1)+1);
            data.Botttime(ind(j,1))=data.Botttime(ind(j,1))+data.Botttime(ind(j,1)+1);
            data.AscTime(ind(j,1))=data.AscTime(ind(j,1)+1);
            data.AscRate(ind(j,1))=data.AscRate(ind(j,1)+1);
            data.PDI(ind(j,1))=data.PDI(ind(j,1)+1);
            data.DWigglesDesc(ind(j,1))=data.DWigglesDesc(ind(j,1))+data.DWigglesDesc(ind(j,1)+1);
            data.DWigglesBott(ind(j,1))=data.DWigglesBott(ind(j,1))+data.DWigglesBott(ind(j,1)+1);
            data.DWigglesAsc(ind(j,1))=data.DWigglesAsc(ind(j,1))+data.DWigglesAsc(ind(j,1)+1);
            data.TotVertDistBot(ind(j,1))=data.TotVertDistBot(ind(j,1))+data.TotVertDistBot(ind(j,1)+1);
            data.BottRange(ind(j,1))=data.BottRange(ind(j,1))+data.BottRange(ind(j,1)+1);
            data.Efficiency(ind(j,1))=data.Efficiency(ind(j,1)+1);
            data.IDZ(ind(j,1))=data.IDZ(ind(j,1)+1);
        end
        %Remove Dive B
        data(ind(:,1)+1,:)=[];
    end
    %Remove dives with ascent rate over 3m/s
    ind2=find(data.AscRate>3);
    data(ind2(:,1),:)=[];
    %Remove dives with descent rate over 3m/s
    ind3=find(data.DescRate>3);
    data(ind3(:,1),:)=[];
    %Remove dives with duration over 150min
    ind4=find(data.Dduration>(150*60));
    data(ind4(:,1),:)=[];

    %Redo DiveNumber after dives removed
    m=size(data,1);
    data.DiveNumber(:)=1:m;

    writetable(data,strcat(strtok(filename,'.'),'_QC.csv'))
    clear data ind ind2 ind3 ind4 filename
end

%% TDR2 Subsampled record
for i=1:size(TDR2SubDiveStatFiles)
   TOPPID=str2double(strtok(TDR2SubDiveStatFiles.filename(i),'_'));
    filename=strcat(TDR2SubDiveStatFiles.folder(TDR2SubDiveStatFiles.TOPPID==TOPPID),'\',...
        TDR2SubDiveStatFiles.filename(TDR2SubDiveStatFiles.TOPPID==TOPPID));
    %load DiveStat file
    data=readtable(filename,'NumHeaderLines',25);
    %locate all dives with PDI's of 0 (Dive A).
    ind=find(data.PDI==0);
    if ~isempty(ind)
        %Merge Dive A with subsequent dive (Dive B): Use descent values
        %from Dive A; combine durations, bottom times, and foraging
        %metrics; use max depth, ascent values, and IDZ from Dive B.
        %Recalculate efficiency using new values.
        for j=1:size(ind,1)
            data.Maxdepth(ind(j,1))=data.Maxdepth(ind(j,1)+1);
            data.Dduration(ind(j,1))=data.Dduration(ind(j,1))+data.Dduration(ind(j,1)+1);
            data.Botttime(ind(j,1))=data.Botttime(ind(j,1))+data.Botttime(ind(j,1)+1);
            data.AscTime(ind(j,1))=data.AscTime(ind(j,1)+1);
            data.AscRate(ind(j,1))=data.AscRate(ind(j,1)+1);
            data.PDI(ind(j,1))=data.PDI(ind(j,1)+1);
            data.DWigglesDesc(ind(j,1))=data.DWigglesDesc(ind(j,1))+data.DWigglesDesc(ind(j,1)+1);
            data.DWigglesBott(ind(j,1))=data.DWigglesBott(ind(j,1))+data.DWigglesBott(ind(j,1)+1);
            data.DWigglesAsc(ind(j,1))=data.DWigglesAsc(ind(j,1))+data.DWigglesAsc(ind(j,1)+1);
            data.TotVertDistBot(ind(j,1))=data.TotVertDistBot(ind(j,1))+data.TotVertDistBot(ind(j,1)+1);
            data.BottRange(ind(j,1))=data.BottRange(ind(j,1))+data.BottRange(ind(j,1)+1);
            data.Efficiency(ind(j,1))=data.Efficiency(ind(j,1)+1);
            data.IDZ(ind(j,1))=data.IDZ(ind(j,1)+1);
        end
        %Remove Dive B
        data(ind(:,1)+1,:)=[];
    end
    %Remove dives with ascent rate over 3m/s
    ind2=find(data.AscRate>3);
    data(ind2(:,1),:)=[];
    %Remove dives with descent rate over 3m/s
    ind3=find(data.DescRate>3);
    data(ind3(:,1),:)=[];
    %Remove dives with duration over 150min
    ind4=find(data.Dduration>(150*60));
    data(ind4(:,1),:)=[];

    %Redo DiveNumber after dives removed
    m=size(data,1);
    data.DiveNumber(:)=1:m;

    writetable(data,strcat(strtok(filename,'.'),'_QC.csv'))
    clear data ind ind2 ind3 ind4 filename
end

%% TDR3 Subsampled record
for i=1:size(TDR3SubDiveStatFiles)
   TOPPID=str2double(strtok(TDR3SubDiveStatFiles.filename(i),'_'));
    filename=strcat(TDR3SubDiveStatFiles.folder(TDR3SubDiveStatFiles.TOPPID==TOPPID),'\',...
        TDR3SubDiveStatFiles.filename(TDR3SubDiveStatFiles.TOPPID==TOPPID));
    %load DiveStat file
    data=readtable(filename,'NumHeaderLines',25);
    %locate all dives with PDI's of 0 (Dive A).
    ind=find(data.PDI==0);
    if ~isempty(ind)
        %Merge Dive A with subsequent dive (Dive B): Use descent values
        %from Dive A; combine durations, bottom times, and foraging
        %metrics; use max depth, ascent values, and IDZ from Dive B.
        %Recalculate efficiency using new values.
        for j=1:size(ind,1)
            data.Maxdepth(ind(j,1))=data.Maxdepth(ind(j,1)+1);
            data.Dduration(ind(j,1))=data.Dduration(ind(j,1))+data.Dduration(ind(j,1)+1);
            data.Botttime(ind(j,1))=data.Botttime(ind(j,1))+data.Botttime(ind(j,1)+1);
            data.AscTime(ind(j,1))=data.AscTime(ind(j,1)+1);
            data.AscRate(ind(j,1))=data.AscRate(ind(j,1)+1);
            data.PDI(ind(j,1))=data.PDI(ind(j,1)+1);
            data.DWigglesDesc(ind(j,1))=data.DWigglesDesc(ind(j,1))+data.DWigglesDesc(ind(j,1)+1);
            data.DWigglesBott(ind(j,1))=data.DWigglesBott(ind(j,1))+data.DWigglesBott(ind(j,1)+1);
            data.DWigglesAsc(ind(j,1))=data.DWigglesAsc(ind(j,1))+data.DWigglesAsc(ind(j,1)+1);
            data.TotVertDistBot(ind(j,1))=data.TotVertDistBot(ind(j,1))+data.TotVertDistBot(ind(j,1)+1);
            data.BottRange(ind(j,1))=data.BottRange(ind(j,1))+data.BottRange(ind(j,1)+1);
            data.Efficiency(ind(j,1))=data.Efficiency(ind(j,1)+1);
            data.IDZ(ind(j,1))=data.IDZ(ind(j,1)+1);
        end
        %Remove Dive B
        data(ind(:,1)+1,:)=[];
    end
    %Remove dives with ascent rate over 3m/s
    ind2=find(data.AscRate>3);
    data(ind2(:,1),:)=[];
    %Remove dives with descent rate over 3m/s
    ind3=find(data.DescRate>3);
    data(ind3(:,1),:)=[];
    %Remove dives with duration over 150min
    ind4=find(data.Dduration>(150*60));
    data(ind4(:,1),:)=[];

    %Redo DiveNumber after dives removed
    m=size(data,1);
    data.DiveNumber(:)=1:m;

    writetable(data,strcat(strtok(filename,'.'),'_QC.csv'))
    clear data ind ind2 ind3 ind4 filename
end
