%Rachel Holser (rholser@ucsc.edu)
%Last Updated: 2022-07-08

clear
files=dir('*.txt');
MetaData=readtable('KamiIndex.csv');

for i=1:size(files,1)
    %Import dive data
    import=readtable(files(i).name,'HeaderLines',7);
    
    %TOPPID from filename
    TOPPID=str2num(strtok(files(i).name,'_'));
    %Import start date from KamiIndex.csv and calculate Date/Time for each
    %depth
    StartTime=MetaData.StartTime(MetaData.TOPPID==TOPPID);
    StartDate=MetaData.StartDate(MetaData.TOPPID==TOPPID);
    StartJulDate=datenum(StartDate)+days(StartTime);
    EndJulDate=StartJulDate+((size(import,1)-1)*5)/86400;
    import.JulDates=transpose(StartJulDate:(5/86400):EndJulDate);
    import.Date=datestr(import.JulDates,'dd-mmm-yyyy');
    import.Time=datestr(import.JulDates,'HH:MM:SS');
    %combine into table for export
    Data=table(import.Date,import.Time,import.DEPTH);
    Data.Properties.VariableNames={'Date','Time','Depth'};
    %save as csv
    filename=strcat(strtok(files(i).name,'Depth'),'tdr.csv');
    writetable(Data,filename)
end