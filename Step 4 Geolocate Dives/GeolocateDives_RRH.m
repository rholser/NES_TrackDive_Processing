%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Created by: Rachel Holser (rholser@ucsc.edu)
%Created on: 22-Aug-2022
%Last Updated: 30-Aug-2022
%
%Required functions:  yt_interpol_linear_2 (IKNOS toolbox)
%                     SolarAzEl
%                     (https://github.com/Chrismarsh/umbra/blob/master/matlab/SolarAzEl.m)
%
%Preparation:
%      Process and assemble all tracking and diving data (Steps 1-3)
%      Create metadata.mat (start/stop, foraging success, tag metadata)
%      Create All_Filenames.mat using CompileFilenames.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
load MetaData.mat
load All_Filenames.mat

%find indices of first and last deployments to be processed
files=dir('*_DiveStat.csv');
first=find(MetaDataAll.TOPPID==str2double(strtok(files(1).name,'_')));
last=find(MetaDataAll.TOPPID==str2double(strtok(files(end).name,'_')));
clear files
for i=first:last 
    
    disp([MetaDataAll.FieldID{i} '_' num2str(MetaDataAll.TOPPID(i))])
    
    %find filenames with the current TOPPID
    trackfile=TrackFoieGrasFiles.filename(TrackFoieGrasFiles.TOPPID==MetaDataAll.TOPPID(i));
    tdr1file=TDRDiveStatFiles.filename(TDRDiveStatFiles.TOPPID==MetaDataAll.TOPPID(i));
    tdr1subfile=TDRSubDiveStatFiles.filename(TDRSubDiveStatFiles.TOPPID==MetaDataAll.TOPPID(i));
    
    if ~isempty(trackfile)
        
        %Load foieGras processed track
        Track=readtable(trackfile);
        try
            Track=removevars(Track,{'Var1'});
        end
        %Rename columns for consistency
        Track.Properties.VariableNames = {'TOPPID','DateTime','Lon',...
            'Lat','x','y','x_se_km','y_se_km','u','v','u_se_km','v_se_km','s','s_se'};
        %Convery DateTime to JulDate
        Track.JulDate=datenum(Track.DateTime);
        
        %load DiveStat files and interpolate track to it
        if ~isempty(tdr1file)
            for j=1:size(tdr1file,1)
                %load dive statistics file
                Dive1Stat=readtable(tdr1file(j));
                %Lat/lon from linear interpolation of processed track based on time
                Dive1LatLon = yt_interpol_linear_2(table2array(Track(:,{'JulDate','Lat',...
                    'Lon'})),Dive1Stat.JulDate(:));
                %Add lat to dive statistics
                Dive1Stat.Lat=Dive1LatLon(:,2);
                %Add lon to dive statistics
                Dive1Stat.Lon=Dive1LatLon(:,3);
                %Lat/lon errors from linear interpolation of processed track based on time
                Dive1LatLonSE = yt_interpol_linear_2(table2array(Track(:,{'JulDate','y_se_km',...
                    'x_se_km'})),Dive1Stat.JulDate(:));
                %Add lat_se to dive statistics
                Dive1Stat.Lat_se_km=Dive1LatLonSE(:,2);
                %Add lon_se to dive statistics
                Dive1Stat.Lon_se_km=Dive1LatLonSE(:,3);
                %Calculate solar elevation from lat/lon/date/time of each
                %dive
                [Az El]=SolarAzEl(datestr(Dive1Stat.JulDate,'yyyy/mm/dd HH:MM:SS'),...
                    Dive1Stat.Lat,Dive1Stat.Lon,0);
                %Add solar elevation to dive statistics
                Dive1Stat.SolarEl=El;
                %Write dive statistics back to file
                writetable(Dive1Stat,tdr1file(j));
                clear Az El
            end
            clear j
        end
        
        %Repeat the above steps for subsampled TDR data files
        if ~isempty(tdr1subfile)
            for j=1:size(tdr1subfile,1)
                %load dive statistics file
                Dive1Stat=readtable(tdr1subfile(j));
                %Lat/lon from linear interpolation of processed track based on time
                Dive1LatLon = yt_interpol_linear_2(table2array(Track(:,{'JulDate','Lat',...
                    'Lon'})),Dive1Stat.JulDate(:));
                %Add lat to dive statistics
                Dive1Stat.Lat=Dive1LatLon(:,2);
                %Add lon to dive statistics
                Dive1Stat.Lon=Dive1LatLon(:,3);
                %Lat/lon errors from linear interpolation of processed track based on time
                Dive1LatLonSE = yt_interpol_linear_2(table2array(Track(:,{'JulDate','y_se_km',...
                    'x_se_km'})),Dive1Stat.JulDate(:));
                %Add lat_se to dive statistics
                Dive1Stat.Lat_se_km=Dive1LatLonSE(:,2);
                %Add lon_se to dive statistics
                Dive1Stat.Lon_se_km=Dive1LatLonSE(:,3);
                %Calculate solar elevation from lat/lon/date/time of each
                %dive
                [Az El]=SolarAzEl(datestr(Dive1Stat.JulDate,'yyyy/mm/dd HH:MM:SS'),...
                    Dive1Stat.Lat,Dive1Stat.Lon,0);
                %Add solar elevation to dive statistics
                Dive1Stat.SolarEl=El;
                %Write dive statistics back to file
                writetable(Dive1Stat,tdr1subfile(j));
                clear Az El
            end
            clear j
        end
    end
    clear tdr1file tdr1subfile trackfile
end



            if ~isemtpy(tdr1Subfile)
                Dive1SubStat=readtable(tdr1Subfile);
                Dive1SubLatLon = yt_interpol_linear_2(table2array(Track(:,{'JulDate','Lat',...
                    'Lon'})),Dive1SubStat.JulDate(:));
                Dive1SubStat.Lat=Dive1SubLatLon(:,2);
                Dive1SubStat.Lon=Dive1SubLatLon(:,3);
                [Az El]=SolarAzEl(datestr(Dive1SubStat.JulDate,'yyyy/mm/dd HH:MM:SS'),...
                    Dive1SubStat.Lat,Dive1SubStat.Lon,0);
                Dive1SubStat.SolarEl=El;
                writematrix(Dive1SubStat,tdr1Subfile);
                clear Az El
            end
            
            if ~isemtpy(tdr2file)
                Dive2Stat=readtable(tdr2file);
                Dive2LatLon = yt_interpol_linear_2(table2array(Track(:,{'JulDate','Lat',...
                    'Lon'})),Dive2Stat.JulDate(:));
                Dive2Stat.Lat=Dive2LatLon(:,2);
                Dive2Stat.Lon=Dive2LatLon(:,3);
                [Az El]=SolarAzEl(datestr(Dive2Stat.JulDate,'yyyy/mm/dd HH:MM:SS'),...
                    Dive2Stat.Lat,Dive2Stat.Lon,0);
                Dive2Stat.SolarEl=El;
                writematrix(Dive2Stat,tdr2file);
                clear Az El
            end
            
            if ~isemtpy(tdr2Subfile)
                Dive2StatSub=readtable(tdr2Subfile);
                Dive2SubLatLon = yt_interpol_linear_2(table2array(Track(:,{'JulDate','Lat',...
                    'Lon'})),Dive2SubStat.JulDate(:));
                Dive2SubStat.Lat=Dive2SubLatLon(:,2);
                Dive2SubStat.Lon=Dive2SubLatLon(:,3);
                [Az El]=SolarAzEl(datestr(Dive2SubStat.JulDate,'yyyy/mm/dd HH:MM:SS'),...
                    Dive2SubStat.Lat,Dive2SubStat.Lon,0);
                Dive2SubStat.SolarEl=El;
                writematrix(Dive2SubStat,tdr2Subfile);
                clear Az El
            end
            
            if ~isemtpy(tdr3file)
                Dive3Stat=readtable(tdr3file);
                
                Dive3LatLon = yt_interpol_linear_2(table2array(Track(:,{'JulDate','Lat',...
                    'Lon'})),Dive3Stat.JulDate(:));
                Dive3Stat.Lat=Dive3LatLon(:,2);
                Dive3Stat.Lon=Dive3LatLon(:,3);
                [Az El]=SolarAzEl(datestr(Dive3Stat.JulDate,'yyyy/mm/dd HH:MM:SS'),...
                    Dive3Stat.Lat,Dive3Stat.Lon,0);
                Dive3Stat.SolarEl=El;
                writematrix(Dive3Stat,tdr3file);
                clear Az El
            end
            
            if ~isemtpy(tdr3Subfile)
                Dive3StatSub=readtable(tdr3Subfile);
                Dive3SubLatLon = yt_interpol_linear_2(table2array(Track(:,{'JulDate','Lat',...
                    'Lon'})),Dive3SubStat.JulDate(:));
                Dive3SubStat.Lat=Dive3SubLatLon(:,2);
                Dive3SubStat.Lon=Dive3SubLatLon(:,3);
                [Az El]=SolarAzEl(datestr(Dive3SubStat.JulDate,'yyyy/mm/dd HH:MM:SS'),...
                    Dive3SubStat.Lat,Dive3SubStat.Lon,0);
                Dive3SubStat.SolarEl=El;
                writematrix(Dive3SubStat,tdr3Subfile);
                clear Az El
            end
        %if there is no tracking data, create lat/lon/solarEl variables in TDR 
        %files and population with NaN
        else
            if ~isemtpy(tdr1file)
                Dive1Stat=readtable(tdr1file);
                Dive1Stat.Lat(:)=NaN;
                Dive1Stat.Lon(:)=NaN;
                Dive1Stat.SolarEl(:)=NaN;
                writematrix(Dive1Stat,tdr1file);
                
            end
            if ~isemtpy(tdr1Subfile)
                Dive1SubStat=readtable(tdr1Subfile);
                Dive1SubStat.Lat(:)=NaN;
                Dive1SubStat.Lon(:)=NaN;
                Dive1SubStat.SolarEl(:)=NaN;
                writematrix(Dive1SubStat,tdr1Subfile);
                
            end
            if ~isemtpy(tdr2file)
                Dive2Stat=readtable(tdr2file);
                Dive2Stat.Lat(:)=NaN;
                Dive2Stat.Lon(:)=NaN;
                Dive2Stat.SolarEl(:)=NaN;
                writematrix(Dive2Stat,tdr2file);
            end
            
            if ~isemtpy(tdr2Subfile)
                Dive2SubStat=readtable(tdr2Subfile);
                Dive2SubStat.Lat(:)=NaN;
                Dive2SubStat.Lon(:)=NaN;
                Dive2SubStat.SolarEl(:)=NaN;
                writematrix(Dive2SubStat,tdr2Subfile);
            end
            if ~isemtpy(tdr3file)
                Dive3Stat=readtable(tdr3file);
                Dive3Stat.Lat(:)=NaN;
                Dive3Stat.Lon(:)=NaN;
                Dive3Stat.SolarEl(:)=NaN;
                writematrix(Dive3Stat,tdr3file);
            end
            if ~isemtpy(tdr3Subfile)
                Dive3SubStat=readtable(tdr3Subfile);
                Dive3SubStat.Lat(:)=NaN;
                Dive3SubStat.Lon(:)=NaN;
                Dive3SubStat.SolarEl(:)=NaN;
                writematrix(Dive3SubStat,tdr3Subfile);
                
            end
        end
            
end
