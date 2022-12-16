%Rachel Holser (rholser@ucsc.edu), based on P.Robinson's 2009 script
%Last Updated: 25-Jun-2021

% Function to subsample TDR data and run DA on the subsampled data.  
% Requires *pre_iknos_RRH.csv and *DAstring.csv files

function output = subsample_and_DA_RRH(filename,filenameDA)
    
    %Step 1: Pull in data and DAstring from text file saved from
    %change_format_DA_RRH.m
    data=csvread(filename);
    
    m=size(data,2);
    fid=fopen(filenameDA);
    if m==7
        preDAstring=textscan(fid,'%s %s %s %s %s %s %s');
        DAstring=[preDAstring{1},preDAstring{2},preDAstring{3},preDAstring{4},...
            preDAstring{5},preDAstring{6},preDAstring{7}];
    elseif m==8
        preDAstring=textscan(fid,'%s %s %s %s %s %s %s %s');
    elseif m==9
        preDAstring=textscan(fid,'%s %s %s %s %s %s %s %s %s');
    elseif m==10
        preDAstring=textscan(fid,'%s %s %s %s %s %s %s %s %s %s');
    end
    fclose(fid);
    DAstring=char(preDAstring{1});
    for j=2:m
        DAstring=[DAstring ' ' char(preDAstring{j})];
    end
    
    %Step 2: calculate sampling rate, choose subsample basaed on rate
    SubSample=1;
    SamplingInt=round(mode(diff(data(:,6))));
    if SamplingInt==1
        SubSample=8;
    elseif SamplingInt==2
        SubSample=4;
    elseif SamplingInt==4
        SubSample=2;
    end
    
    %Step 3: Subsample, save files, and re-run DA
    if SubSample==8 || SubSample==4 || SubSample==2
        data=data(1:SubSample:end,:);
        %data=[floor(datevec(data(:,2)+0.000001)) data(:,1) data(:,4:end)];
        writematrix(data,[filename(1:(end-8)) 'SubSample.csv']);

        %Automatic depth resolution detection
        filename2=dir([filename(1:14) '*full*DiveStat.csv']);
        DepthRes=csvread(filename2.name,30,0);
        DepthRes=unique(abs(diff(DepthRes(find(~isnan(DepthRes(:,9))),9))));
        DepthRes=DepthRes(2,1);

        %assumes depth resolution of 0.5m!!!
        yt_iknos_da_RRH([filename(1:(end-8)) 'SubSample.csv'],DAstring,4,...
            15/DepthRes,20,'wantfile_yes','ZocWindow',2,'ZocWidthForMode',...
            15,'ZocSurfWidth',10,'ZocDiveSurf',15);
    end
end