%output=change_format_DA2_RRH_TV4_2(filename,Start,End,TOPPID)
%
%
%Created by: Rachel Holser (rholser@ucsc.edu), rewritten from P.Robinson's 2009 script. 
%Last updated: 22-Oct-2022

%Function to prepare csv file, fix errors, and run dive analysis on TDR
%data.

%Truncates data to startstop for non-Little Leonardo data

%Requires IKNOS toolbox
%Requires functions: yt_iknos_da_RRH
%                    DA_data_compiler_RRH
%                    yt_findclosest_RRH

%Version 4.2: incorportates new SMRU tdr_clean files and uses datetime
%rather than datenum wherever possible
%
% Update: 10-Dec-2022
% Add datetime conversions for different instrument types

function output=change_format_DA2_RRH_TV4_2(filename,Start,End,TOPPID)
    %Step 1: load csv of TDR data
        data=readtable(filename,'HeaderLines',0,'ReadVariableNames',true);

        %Test for normal headers.  If Depth header is missing, re-imports file
        %with no headers and assigns them.
        %HeaderTest=find(strcmp('Depth', data.Properties.VariableNames)==1);
        if isempty(find(strcmp('Depth', data.Properties.VariableNames))>0)
            data=readtable(filename,'HeaderLines',0,'ReadVariableNames',false);
            data.Properties.VariableNames(1)={'Time'};
            data.Properties.VariableNames(2)={'Depth'};
            data(1,:)=[]; %remove top row - often has faulty time format when no headers
        end

    %Step 2: remove rows with depth issues
        %Step 2.1: remove rows with NaNs (often present in row with
        %duplicate time stamp)
        data(isnan(data.Depth),:)=[];
        
        %Step 2.2: deal with 2000+m spikes.  
            %For TOPPID 2015003, simply remove spikes - visual inspection 
                %indicates remaining record is reliable.
            %For all others, pull rows with depths greater than 2000m into separate
                %data structure, convert timestamp to serial date, and check against Start and
                %End date to see if spike occur during time at sea.
        if TOPPID==2015003
            data(data.Depth>2000,:)=[];
        else
            bad_data=data(data.Depth>2000,:);
            %Check dates
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
              
        %Step 2.3: Detect and remove lines with other unrealistically large 
        %depth jumps, which may indicates a tag reset with bad datetime that 
        %will not convert correctly
            ind_bad1=find(abs(diff(data.Depth))>30); %depth jumps more than 30m
            ind_bad1(:)=ind_bad1(:)+1;
            data(ind_bad1,:)=[];
    
    %Step 3: date conversions
    %Step 3.1: parse out time into separate columns using datevec
    try
        data.Time=datetime(data.Time,'InputFormat','HH:mm:ss dd-MMM-yyyy');
    end
    try
        data.Time=datetime(data.Time,'InputFormat','dd/MM/yyyy HH:mm:ss');
    end
    %try
    %    data.Time=data.Date+data.Time;
    %end

    [data.Year, data.Month, data.Day, data.Hour, data.Min, data.Sec]...
        =datevec(data.Time);

    data.Sec=round(data.Sec);
     
        %Step 3.2: Year correction for CTD tag records with incorrect year in
        %recorded timestamps (day, month, and time all correct)
        if ~isempty(strcmp('*Archive.csv', filename))
            if TOPPID==2010077 %recording began to fail on Nov 7 2010
                Cut=datetime(2010,11,07);
                data(data.Time>Cut,:)=[];  
            elseif TOPPID==2010081 %record began to fail on Oct 8 2010
                Cut=datetime(2010,10,07);
                data(data.Time>Cut,:)=[];
            elseif TOPPID==2012039 %record began to fail on Sep 5 2012
                Cut=datetime(2012,09,05);
                data(data.Time>Cut,:)=[];
            end
        else
            if TOPPID==2017024 %recording starts in 2013 instead of 2017
                data.Year=data.Year+4;
                data.Time=data.Time+years(4);
            elseif TOPPID==2017025 %recording starts in 2013 instead of 2017
                data.Year=data.Year+4;
                data.Time=data.time+years(4);
            elseif TOPPID==2017026 %recording starts in 2013 instead of 2017
                data.Year=data.Year+4;
                data.Time=data.time+years(4);
            elseif TOPPID==2017028 %recording starts in 2016 instead of 2017
                data.Year=data.Year+1;
                data.Time=data.time+years(1);
            elseif TOPPID==2018028 %recording starts in 2013 instead of 2018
                data.Year=data.Year+5;
                data.Time=data.time+years(5);
            elseif TOPPID==2018030 %recording starts in 2017 instead of 2018
                data.Year=data.Year+1;
                data.Time=data.time+years(1);
            elseif TOPPID==2018034 %recording starts in 2017 instead of 2018
                data.Year=data.Year+1;
                data.Time=data.time+years(1);
            elseif TOPPID==2019010 %recording starts in 2017 instead of 2018
                data.Year=data.Year+4;
                data.Time=data.time+years(4);
            end
        end
    
    %Step 4: truncate record to start and end time for TDRs that are not
        %from Kami or Stroke accelerometers
        if size(strfind(filename,'Kami'),1)>0
        elseif size(strfind(filename,'Stroke'),1)>0
        else
            [~,ind1]=min(abs(data.Time-Start));
            [~,ind2]=min(abs(data.Time-End));
            data=data(ind1:ind2,:);
        end

    %Step 5: calculate sampling rate
        SamplingDiff=diff(data.Time);
        SamplingRate=seconds(round(mode(SamplingDiff)));
    
    %Step 6: Remove data with negative sampling rates
        %NOTE: This will only remove SINGLE bad lines and will not deal with
        %full time shifts.
        OffTime_ind=find(SamplingDiff<0);
        OffTime_ind(:)=OffTime_ind(:)+1;
        data(OffTime_ind,:)=[];
    
    %Find section of dive record that has repeated itself....

    %Step 7: generate variable string for iknos da and write to new .csv.
        if size(strfind(filename,'-out-Archive'),1)>0
            [data_DA,DAstring]=DA_data_compiler_RRH_TV4(data);
            writematrix(data_DA,[strtok(filename,'-') '_DAprep_full.csv']);
            fid=fopen([strtok(filename,'-') '_DAString.txt'],'wt');
            fprintf(fid,DAstring);
            fclose(fid);
        else
            [data_DA,DAstring]=DA_data_compiler_RRH_TV4(data);
            writematrix(data_DA,[strtok(filename,'.') '_DAprep_full.csv']);
            fid=fopen([strtok(filename,'.') '_DAString.txt'],'wt');
            fprintf(fid,DAstring);
            fclose(fid);
        end

    %Step 8: Depth resolution detection
        DepthRes=unique(abs(diff(data.Depth)));
        if DepthRes(1,1)>0
            DepthRes=DepthRes(1,1);
        else
            DepthRes=DepthRes(2,1);
        end

    %Step 9: Run IKNOS DA    
        if size(strfind(filename,'-out-Archive'),1)>0
            yt_iknos_da_RRH([strtok(filename,'-') '_DAprep_full.csv'],DAstring,...
            32/SamplingRate,15/DepthRes,20,'wantfile_yes','ZocWindow',2,...
            'ZocWidthForMode',15/DepthRes,'ZocSurfWidth',10,'ZocDiveSurf',15,'ZocMinMax',[-10,2200]);
        else
            yt_iknos_da_RRH([strtok(filename,'.') '_DAprep_full.csv'],DAstring,...
            32/SamplingRate,15/DepthRes,20,'wantfile_yes','ZocWindow',2,...
            'ZocWidthForMode',15,'ZocSurfWidth',10,'ZocDiveSurf',15,'ZocMinMax',[-10,2200]);
        end
end
