%output=ChangeFormat_DA_V4_2(filename,Start,End,TOPPID)
%
%Function to prepare csv file, fix errors, and run dive analysis on TDR data. Truncates data to startstop 
% for non-Little Leonardo data
%
%Created by: Rachel Holser (rholser@ucsc.edu), rewritten from P.Robinson's 2009 script.
%
%Requires IKNOS toolbox
%Requires functions: iknos_da
%                    DA_data_compiler_V4
%                    yt_findclosest_RRH
%                    resolution_DepthRes
%
%Version 4.2: incorportates new SMRU tdr_clean files and uses datetime
%             rather than datenum wherever possible
%
% Update Log:
% 05-Dec-2022 - modified by Arina Favilla to (1) update zoc approach to account for large zero offset
%               and (2) fix Kami timestamp:
%               added elseif statements to Step 1
%               added line to Step 3.1
%               added Step 3.3
%               added code to Kami if statement in Step 4
%               modified Step 8 to round DepthRes
%               added Step 8.1
%               edited Step 9
% 10-Dec-2022 - Add datetime conversions for different instrument types
% 17-Dec-2022 - Changed depth res method to use resolution_DepthRes
% 21-Dec-2022 - Modified minsurface in Step 8.1 to account for instances where WC tag
%               records -80m during surface interval when dry
% 22-Dec-2022 - Minor changes to final figure
% 23-Dec-2022 - Added exceptions to Step 8.1
% 28-Dec-2022 - Added date conversion to Step 2.2 and Step 3
%               Added NaT and duplicate time filter to Step 6
%               Added TOPPID exceptions to Step 8.1
% 02-Jan-2023 - Changed name

function change_format_DA_V4_2(filename,Start,End,TOPPID)
%% Step 1: load csv of TDR data
    data=readtable(filename,'HeaderLines',0,'ReadVariableNames',true);
    
    %Test for normal headers.  If Depth header is missing, re-imports file with no headers and assigns them.
    if isempty(find(strcmp('Depth', data.Properties.VariableNames))>0)
        data=readtable(filename,'HeaderLines',0,'ReadVariableNames',false);
        data.Properties.VariableNames(1)={'Time'};
        data.Properties.VariableNames(2)={'Depth'};
        data(1,:)=[]; %remove top row - often has faulty time format when no headers
    end
    % Combine date and time columns for Kami tag
    if size(strfind(filename,'Kami'),1)>0
        [y,m,d]=ymd(data.Date);
        [H,M,S]=hms(data.Time);
        data.Time=datetime(y,m,d,H,M,S);
        data=removevars(data,'Date');
        clear y m d H M S
    end

%% Step 2: remove rows with depth issues
    %Step 2.1: remove rows with NaNs (often present in row with duplicate time stamp)
    data(isnan(data.Depth),:)=[];
    
    %Step 2.2: deal with 2000+m spikes.
    % For TOPPID 2015003, simply remove spikes - visual inspection indicates remaining record is reliable.
    if TOPPID==2015003
        data(data.Depth>2000,:)=[];
    % For all others, pull rows with depths greater than 2000m into separate data structure, convert timestamp 
    % to serial date, and check against Start and End date to see if spike occur during time at sea.
    else
        bad_data=data(data.Depth>2000,:);
        %Convert and check dates in bad_data
        try
            bad_data.Time=datetime(bad_data.Time,'InputFormat','dd/MM/yyyy HH:mm:ss');
        end
        try
            bad_data.Time=datetime(bad_data.Time,'InputFormat','HH:mm:ss dd-MMM-yyyy');
        end
        try
            bad_data.Time=bad_data.Date+bad_data.Time;
        end
        bad_data.Start=bad_data.Time-Start;
        bad_data.End=End-bad_data.Time;
        %Indices within data
        bad_data.Ind(:)=0;
        bad_data.Ind=find(data.Depth>2000);
        %Index to indicate within time at sea (0 if not, 1 if yes)
        bad_data.Ind2(:)=0;
        bad_data.Ind2(bad_data.Start>0 & bad_data.End>0)=1;
        %Find earliest incident of spiking
        Cut_Ind=min(bad_data.Ind(bad_data.Ind2==1));
        %Truncate data to first spike
        data(Cut_Ind:end,:)=[];
    end
    
    %Step 2.3: Detect and remove lines with other unrealistically large depth jumps, which may indicates a tag 
    % reset with bad datetime that will not convert correctly
    ind_bad1=find(abs(diff(data.Depth))>30); %depth jumps more than 30m
    ind_bad1(:)=ind_bad1(:)+1;
    data(ind_bad1,:)=[];

%% Step 3: date conversions
    %Step 3.1: Conver to datetime then parse out time into separate columns using datevec
    try
        data.Time=datetime(data.Time,'InputFormat','dd/MM/yyyy HH:mm:ss');
    end
    try
        data.Time=datetime(data.Time,'InputFormat','HH:mm:ss dd-MMM-yyyy');
    end
    try
        data.Time=datetime(data.Time,'InputFormat','dd-MMM-yyyy HH:mm:ss');
    end
    try
        data.Time=data.Date+data.Time;
    end
    
    [data.Year, data.Month, data.Day, data.Hour, data.Min, data.Sec]...
        =datevec(data.Time);
    data.Sec=round(data.Sec);
    
    %Step 3.2: Adjustments for specific TDR records based on TOPPID and tag type.
    % Truncate records when visual inspection indicates sensor failures began
    if TOPPID==2010077 && contains(filename,'Archive.csv')%recording began to fail on Nov 7 2010
        Cut=datetime(2010,11,07);
        data(data.Time>Cut,:)=[];
    elseif TOPPID==2010081 && contains(filename,'Archive.csv')%record began to fail on Oct 8 2010
        Cut=datetime(2010,10,07);
        data(data.Time>Cut,:)=[];
    elseif TOPPID==2012039 && contains(filename,'Archive.csv')%record began to fail on Sep 5 2012
        Cut=datetime(2012,09,05);
        data(data.Time>Cut,:)=[];
    end
    % Year correction for CTD tag records with incorrect year in recorded timestamps (day, month, and time 
    % all correct)
    if TOPPID==2017024 && contains(filename,'tdr_clean.csv')%recording starts in 2013 instead of 2017
        data.Year=data.Year+4;
        data.Time=data.Time+calyears(4);
    elseif TOPPID==2017025 && contains(filename,'tdr_clean.csv')%recording starts in 2013 instead of 2017
        data.Year=data.Year+4;
        data.Time=data.Time+calyears(4);
    elseif TOPPID==2017026 && contains(filename,'tdr_clean.csv')%recording starts in 2013 instead of 2017
        data.Year=data.Year+4;
        data.Time=data.Time+calyears(4);
    elseif TOPPID==2017028 && contains(filename,'tdr_clean.csv')%recording starts in 2016 instead of 2017
        data.Year=data.Year+1;
        data.Time=data.Time+calyears(1);
    elseif TOPPID==2018028 && contains(filename,'tdr_clean.csv')%recording starts in 2013 instead of 2018
        data.Year=data.Year+5;
        data.Time=data.Time+calyears(5);
    elseif TOPPID==2018030 && contains(filename,'tdr_clean.csv')%recording starts in 2017 instead of 2018
        data.Year=data.Year+1;
        data.Time=data.Time+calyears(1);
    elseif TOPPID==2018034 && contains(filename,'tdr_clean.csv')%recording starts in 2017 instead of 2018
        data.Year=data.Year+1;
        data.Time=data.Time+calyears(1);
    elseif TOPPID==2019010 && contains(filename,'tdr_clean.csv')%recording starts in 2017 instead of 2018
        data.Year=data.Year+4;
        data.Time=data.Time+calyears(4);
    end
    
    %Step 3.3: save UTC offset and compression factor to Kami records (applied in Step 4)
    if size(strfind(filename,'Kami'),1)>0
        if TOPPID==2011017
            offset = hours(7)+minutes(58)+seconds(57);
            compress = minutes(2)+seconds(10);
            Cut=datetime(2011,4,7,4,25,55)+offset;
        elseif TOPPID==2011018
            offset = hours(7)+minutes(59)+seconds(2);
            compress = minutes(2)+seconds(27);
            Cut=0;
        elseif TOPPID==2011019
            offset = hours(7)+minutes(59)+seconds(54);
            compress = minutes(3)+seconds(6);
            Cut=0;
        elseif TOPPID==2011020
            offset = hours(7)+minutes(59)+seconds(11);
            compress = minutes(4)+seconds(26);
            Cut=0;
        elseif TOPPID==2012006
            offset = hours(8)+minutes(0)+seconds(34);
            compress = minutes(3)+seconds(21);
            Cut=0;
        elseif TOPPID==2012012
            offset = hours(7)+minutes(50)+seconds(22);
            compress = minutes(1)+seconds(45);
            Cut=datetime(2012,3,8,23,5,35)+offset;
        elseif TOPPID==2012014
            offset = hours(8)+minutes(1)+seconds(55);
            compress = minutes(2)+seconds(28);
            Cut=0;
        elseif TOPPID==2012037
            offset = hours(5)+minutes(41)+seconds(32);
            compress = minutes(4)+seconds(2);
            Cut=datetime(2012,9,23,22,46,57);
        elseif TOPPID==2012038
            offset = hours(5)+minutes(41)+seconds(0);
            compress = minutes(5)+seconds(57);
            Cut=datetime(2012,9,20,12,11,15)+offset;
        elseif TOPPID==2013005
            offset = hours(8)+minutes(0)+seconds(38);
            compress = minutes(1)+seconds(48);
            Cut=0;
        elseif TOPPID==2013006
            offset = hours(8)+minutes(0)+seconds(30);
            compress = seconds(10);
            Cut=0;
        elseif TOPPID==2013008
            offset = hours(8)+minutes(0)+seconds(56);
            compress = minutes(3)+seconds(10);
            Cut=0;
        elseif TOPPID==2013009
            offset = hours(8)+minutes(1)+seconds(3);
            compress = minutes(2)+seconds(46);
            Cut=0;
        elseif TOPPID==2013011
            offset = hours(8)+minutes(0)+seconds(14);
            compress = minutes(2)+seconds(45);
            Cut=0;
        elseif TOPPID==2013014
            offset = hours(7)+minutes(52)+seconds(16);
            compress = minutes(1)+seconds(24);
            Cut=0;
        elseif TOPPID==2013015
            offset = hours(8)+minutes(0)+seconds(16);
            compress = minutes(3)+seconds(21);
            Cut=0;
        elseif TOPPID==2013029
            offset = hours(5)+minutes(41)+seconds(43);
            compress = minutes(6)+seconds(0);
            Cut=datetime(2013,10,29,9,55,30)+offset;
        elseif TOPPID==2013030
            offset = hours(6)+minutes(59)+seconds(45);
            compress = minutes(7)+seconds(20);
            Cut=datetime(2013,12,25,13,22,55)+offset;
        elseif TOPPID==2013031
            offset = hours(6)+minutes(59)+seconds(39);
            compress = minutes(9)+seconds(45);
            Cut=datetime(2013,12,26,15,00,55)+offset;
        elseif TOPPID==2013032
            offset = hours(6)+minutes(59)+seconds(0);
            compress = minutes(17)+seconds(29);
            Cut=datetime(2013,12,26,15,00,55)+offset;
        elseif TOPPID==2013033
            offset = hours(6)+minutes(59)+seconds(20);
            compress = minutes(10)+seconds(30);
            Cut=datetime(2013,12,30,10,5,0)+offset;
        elseif TOPPID==2014011
            offset = hours(7)+minutes(41)+seconds(2);
            compress = minutes(2)+seconds(32);
            Cut=0;
        elseif TOPPID==2014013
            offset = hours(8)+minutes(0)+seconds(28);
            compress = minutes(4)+seconds(46);
            Cut=0;
        elseif TOPPID==2014015
            offset = hours(8)+minutes(30)+seconds(35);
            compress = minutes(2)+seconds(28);
            Cut=0;
        elseif TOPPID==2014018
            offset = hours(8)+minutes(0)+seconds(20);
            compress = minutes(4)+seconds(15);
            Cut=0;
        elseif TOPPID==2015001
            offset = hours(8)+minutes(0)+seconds(25);
            compress = seconds(22);
            Cut=0;
        elseif TOPPID==2015003
            offset = hours(7)+minutes(45)+seconds(47);
            compress = minutes(3)+seconds(29);
            Cut=0;
        elseif TOPPID==2015009
            offset = hours(8)+minutes(0)+seconds(31);
            compress = minutes(4)+seconds(15);
            Cut=0;
        elseif TOPPID==2015010
            offset = hours(8)+minutes(0)+seconds(28);
            compress = minutes(4)+seconds(1);
            Cut=0;
        elseif TOPPID==2016004
            offset = hours(8)+minutes(2)+seconds(10);
            compress = minutes(2)+seconds(57);
            Cut=0;
        elseif TOPPID==2016011
            offset = hours(8)+minutes(0)+seconds(50);
            compress = minutes(2)+seconds(25);
            Cut=0;
        elseif TOPPID==2017002
            offset = hours(8)+minutes(0)+seconds(27);
            compress = minutes(3)+seconds(58);
            Cut=0;
        elseif TOPPID==2017004
            offset = hours(8)+minutes(0)+seconds(23);
            compress = minutes(3)+seconds(24);
            Cut=0;
        else
            offset=0;
            compress=0;
            Cut=0;
        end
    end

%% Step 4: truncate record to start and end time for TDRs that are not from Stroke accelerometers

    % Step 4.1 for Kami TDRs: apply offset, truncate record, and apply compression factor
    if size(strfind(filename,'Kami'),1)>0
        if isduration(offset)
            data.Time=data.Time+offset;
            [data.Year, data.Month, data.Day, data.Hour, data.Min, data.Sec]...
                =datevec(data.Time);
            data.Sec=round(data.Sec); % some seconds > 59 so next lines fix the issue
            % nextmin=find(data.Sec>59);
            if sum(data.Sec>59)>0
                data.Time=datetime(data.Year, data.Month, data.Day, data.Hour, data.Min, data.Sec);
                [data.Year, data.Month, data.Day, data.Hour, data.Min, data.Sec]...
                    =datevec(data.Time);
            end
        end
    
        if isdatetime(Cut) % QC to make sure this works
            data(data.Time>Cut,:)=[];
            [~,ind1]=min(abs(data.Time-Start));
            [~,ind2]=min(abs(data.Time-End));
            data=data(ind1:ind2,:);
        else
            [~,ind1]=min(abs(data.Time-Start));
            [~,ind2]=min(abs(data.Time-End));
            data=data(ind1:ind2,:);
        end
    
        if isduration(compress)
            record_length=seconds(data.Time(end)-data.Time(1));
            record_frac=seconds(data.Time(:)-data.Time(1));
            data.Time=data.Time-seconds((seconds(compress)*record_frac)/record_length);
            [data.Year, data.Month, data.Day, data.Hour, data.Min, data.Sec]...
                =datevec(data.Time);
            data.Sec=round(data.Sec); % some seconds > 59 so next lines fix the issue
            if sum(data.Sec>59)>0
                data.Time=datetime(data.Year, data.Month, data.Day, data.Hour, data.Min, data.Sec);
                [data.Year, data.Month, data.Day, data.Hour, data.Min, data.Sec]...
                    =datevec(data.Time);
            end
        end
        %Step 4.2 for Stroke TDRs: do nothing
    elseif size(strfind(filename,'Stroke'),1)>0
    
        %Step 4.3 for other TDRs: truncate record to start and end
    else
        [~,ind1]=min(abs(data.Time-Start));
        [~,ind2]=min(abs(data.Time-End));
        data=data(ind1:ind2,:);
    end

%% Step 5: calculate sampling rate
    SamplingDiff=diff(data.Time);
    SamplingRate=seconds(round(mode(SamplingDiff)));

%% Step 6: Remove data with bad times (zero or negative sampling rates or NaT)
%NOTE: This will only remove SINGLE bad lines and will not deal with full time shifts.
    OffTime_ind=find(SamplingDiff<=0);
    OffTime_ind(:)=OffTime_ind(:)+1;
    data(OffTime_ind,:)=[];
    
    NaTTime_ind=find(isnat(data.Time));
    data(NaTTime_ind,:)=[];

%% Step 7: generate variable string for iknos da and write to new .csv.
    if size(strfind(filename,'-out-Archive'),1)>0
        [data_DA,DAstring]=DA_data_compiler_V4(data);
        writematrix(data_DA,[strtok(filename,'-') '_DAprep_full.csv']);
        fid=fopen([strtok(filename,'-') '_DAString.txt'],'wt');
        fprintf(fid,DAstring);
        fclose(fid);
    else
        [data_DA,DAstring]=DA_data_compiler_V4(data);
        writematrix(data_DA,[strtok(filename,'.') '_DAprep_full.csv']);
        fid=fopen([strtok(filename,'.') '_DAString.txt'],'wt');
        fprintf(fid,DAstring);
        fclose(fid);
    end

%% Step 8: Depth resolution and MinMax detection
    DepthRes=resolution_DepthRes(data.Depth);

    %Step 8.1: detect if dive surface intervals have offset >10m. Some individual TOPPIDs have been 
    % manually asigned due to weird surface data found during visual inspection.
    running_surface = movmin(data.Depth,hours(2),'SamplePoints',data.Time);
    [f,xi]=ecdf(running_surface); %figure; ecdf(running_surface,'Bounds','on');
    if size(xi,2)<3 && size(strfind(filename,'_tdr_clean'),1)>0
        minsurface=0; % SMRU tags
    elseif TOPPID==2013032 && size(strfind(filename,'-out-Archive'),1)>0 % has weird surface data
        minsurface=0; % set manually through visual inspection
    elseif TOPPID==2006052 && size(strfind(filename,'-out-Archive'),1)>0 % has weird surface data
        minsurface=0; % set manually through visual inspection
    elseif TOPPID==2013036 && size(strfind(filename,'-out-Archive'),1)>0 % has weird surface data
        minsurface=0; % set manually through visual inspection
    elseif abs(xi(3)-xi(2))>10 % if there's a large jump, might be due to surface spikes
        minsurface=xi(3);
    else
        minsurface=interp1(f,xi,0.05);
    end

%% Step 9: Run IKNOS DA - new ZocMinMax with DEFAULT ZOC params
    if minsurface<-10
        if size(strfind(filename,'-out-Archive'),1)>0
            iknos_da([strtok(filename,'-') '_DAprep_full.csv'],DAstring,...
                32/SamplingRate,15/DepthRes,20,'wantfile_yes','ZocWindow',2,...
                'ZocWidthForMode',15,'ZocSurfWidth',10,'ZocDiveSurf',15,...
                'ZocMinMax',[minsurface-10,2200]);
        else
            iknos_da([strtok(filename,'.') '_DAprep_full.csv'],DAstring,...
                32/SamplingRate,15/DepthRes,20,'wantfile_yes','ZocWindow',2,...
                'ZocWidthForMode',15,'ZocSurfWidth',10,'ZocDiveSurf',15,...
                'ZocMinMax',[minsurface-10,2200]);
        end
    else
        if size(strfind(filename,'-out-Archive'),1)>0
            iknos_da([strtok(filename,'-') '_DAprep_full.csv'],DAstring,...
                32/SamplingRate,15/DepthRes,20,'wantfile_yes','ZocWindow',2,...
                'ZocWidthForMode',15,'ZocSurfWidth',10,'ZocDiveSurf',15,'ZocMinMax',[-10,2200]);
        else
            iknos_da([strtok(filename,'.') '_DAprep_full.csv'],DAstring,...
                32/SamplingRate,15/DepthRes,20,'wantfile_yes','ZocWindow',2,...
                'ZocWidthForMode',15,'ZocSurfWidth',10,'ZocDiveSurf',15,'ZocMinMax',[-10,2200]);
        end
    end

%% Step 10: Plot and save QC figs

    % Load rawzoc data and divestat files
    if size(strfind(filename,'-out-Archive'),1)>0
        rawzocdatafile=dir([strtok(filename,'-') '_DAprep_full_iknos_rawzoc_data.csv']);
        rawzocdata=readtable(rawzocdatafile.name,'HeaderLines',26,'ReadVariableNames',true);
        rawzocdata.Time=datetime(rawzocdata.time,'ConvertFrom','datenum');
    
        DiveStatfile=dir([strtok(filename,'-') '_DAprep_full_iknos_DiveStat.csv']);
        DiveStat=readtable(DiveStatfile.name,'HeaderLines',26,'ReadVariableNames',true);
        DiveStat.Time=datetime(DiveStat.Year,DiveStat.Month,DiveStat.Day,DiveStat.Hour,DiveStat.Min,DiveStat.Sec);
    else
        rawzocdatafile=dir([strtok(filename,'.') '_DAprep_full_iknos_rawzoc_data.csv']);
        rawzocdata=readtable(rawzocdatafile.name,'HeaderLines',26,'ReadVariableNames',true);
        rawzocdata.Time=datetime(rawzocdata.time,'ConvertFrom','datenum');
    
        DiveStatfile=dir([strtok(filename,'.') '_DAprep_full_iknos_DiveStat.csv']);
        DiveStat=readtable(DiveStatfile.name,'HeaderLines',26,'ReadVariableNames',true);
        DiveStat.Time=datetime(DiveStat.Year,DiveStat.Month,DiveStat.Day,DiveStat.Hour,DiveStat.Min,DiveStat.Sec);
    end
    
    %plot raw and zoc'd data and indicate all dive start and ends from divestat
    figure(1);
    plot(rawzocdata.Time,rawzocdata.depth);
    hold on; set(gca,'YDir','reverse');
    plot(rawzocdata.Time,rawzocdata.CorrectedDepth,'b');
    scatter(DiveStat.Time,zeros(size(DiveStat,1),1),[],'go');
    scatter(DiveStat.Time+seconds(DiveStat.Dduration),zeros(size(DiveStat,1),1),[],'ro');
    text(DiveStat.Time,DiveStat.Maxdepth,num2str(DiveStat.DiveNumber),'Color','b');
    legend({'raw','zoc','Start dive','End dive'});
    title(['Raw vs ZOC: ' num2str(TOPPID)]);
    if size(strfind(filename,'-out-Archive'),1)>0
        savefig([strtok(filename,'-') '_Raw_ZOC.fig']);
    else
        savefig([strtok(filename,'.') '_Raw_ZOC.fig']);
    end
    close;
    
    clear bad_data Cut_Ind ind_bad1 ind1 ind2 OffTime_ind NaTTime_ind offset compress Cut minsurface
end
