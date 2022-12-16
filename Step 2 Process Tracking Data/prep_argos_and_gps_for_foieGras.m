%Create foieGras input from raw Argos and solved GPS data
%updated 6 OCtober 2022 by TRK
%change your directories before running! (i.e. all "cd" lines)

%incorporates Argos semi major and semi minor
%axes and ellipse orientations where available (Kalman filtered data)

%Identifies several different input data formats, however, there may well
%be more in the future...

%%Input data:

%Input Argos data must be called '*RawArgos.csv'
%This can be Argos download from SMRU MS Access files or
%Wildlife Computers data portal downloads (need file called RawArgos.csv to retain error ellipse data).

%GPS must be called '*SMRU_gps.csv' (from SMRU MS Access file) or '*FastGPS.csv' (WC downloaded).
%If none of these apply, it will also check existing (older) Matfiles for track_GPS_raw.

%%Output data:
%one csv per track with:
    %TOPPID
    %pttid
    %JulDate
    %Date
    %Latitude
    %Longitude
    %LocationClass
    %SemiMajorAxis
    %SemiMinorAxis
    %EllipseOrientation
    
%%Things this code does:

%Truncates location data based on startstop.csv file (i.e. locations before
%seal left shore and after she returned are omitted).
%If seal returned home but the tag stopped recording locations, an end
%point is assigned IF the data gap is not more than 14 days (to avoid
%drawing a meaningless straight line back home). Adjust this if desired.
    
%Creates "TOPPIDchecklist" to keep track of the tracks run. 
%This also classifies into: "Very Little Data" (<10 locations), "Incomplete, Did Not Return
%Home" (tag not recovered), "Incomplete, Returned Home" (tag recovered, but
%more than 10 days of data on return missing), or "Complete" (seal
%returned, data gap if any <10 days).
%Depending on your needs, adjust these criteria. Visual QC always
%recommended - the foieGras R code makes you some maps.

clear all
cd 'E:/Eseal Data Paper/All Raw Data'
argosfiles=dir('*RawArgos.csv');

cd 'E:/Eseal Data Paper'
startstop=readtable('startstop.csv');

TOPPIDchecklist=table(startstop.TOPPID,startstop.PTTID,'VariableNames',{'TOPPID','PTTID'});

for j=1:length(argosfiles)
cd 'E:/Eseal Data Paper/All Raw Data'
argosdata=readtable(argosfiles(j).name,'ReadVariableNames',true);

%identify format of input data

    %this is WC downloaded RawArgos data
    if strcmp(argosdata.Properties.VariableNames{1},'Prog')==1 & strcmp(argosdata.Properties.VariableNames{2},'PTT')==1
    clear pttid lat1 lon1 lat2 lon2 dates lq semimajor semiminor eor
    opts=detectImportOptions(argosfiles(j).name);
    opts = setvartype(opts,{'Class'},'char');
    argosdata=readtable(argosfiles(j).name,opts);

    %keep unique time/location combinations only (this is what WC retains in
    %their "Argos.csv" output - but that format currently does not retain error
    %information)
    [C,tokeep]=unique(table(argosdata.MsgDate,argosdata.Latitude,argosdata.Longitude),'rows');
    clear C

    argosdata=argosdata(tokeep,:);

    lat1=argosdata.Latitude;
    validlocs=find(~isnan(lat1));
    argosdata=argosdata(validlocs,:);
    pttid=argosdata.PTT;
    lon1=argosdata.Longitude;
    lat1=argosdata.Latitude;
    lat2=argosdata.Latitude2;
    lon2=argosdata.Longitude2;
    dates=datenum(strcat(datestr(argosdata.MsgDate), '-', datestr(argosdata.MsgTime,'HH:MM:SS')));
    lq=argosdata.Class;
    semimajor=argosdata.ErrorSemi_majorAxis;
    semiminor=argosdata.ErrorSemi_minorAxis;
    eor=argosdata.ErrorEllipseOrientation;

    end

    %this is SMRU data
    if strcmp(argosdata.Properties.VariableNames{1},'REF')==1 | strcmp(argosdata.Properties.VariableNames{1},'ref')==1 
    clear pttid lat1 lon1 lat2 lon2 dates lq semimajor semiminor eor    
    pttid=argosdata.PTT;
    dates=datenum(argosdata.D_DATE);
    lat1=argosdata.LAT;
    lon1=argosdata.LON;
    lat2=argosdata.ALT_LAT;
    lon2=argosdata.ALT_LON;
    lq=argosdata.LQ;
        if sum(strcmp(argosdata.Properties.VariableNames,'SEMI_MAJOR_AXIS'))==1
    semimajor=argosdata.SEMI_MAJOR_AXIS;
    semiminor=argosdata.SEMI_MINOR_AXIS;
    eor=argosdata.ELLIPSE_ORIENTATION;
        else
    semimajor=NaN([height(argosdata),1]);
    semiminor=NaN([height(argosdata),1]);
    eor=NaN([height(argosdata),1]);
        end

        lq1=lq;
    lq=cell(length(lq1),1);
    for i=1:length(lq1) %turn SMRU numerical location classes back into letters for foieGras
         if lq1(i)==-1
             lq{i,1}='A';
         elseif lq1(i)==-2
             lq{i,1}='B';
         elseif lq1(i)==-9
             lq{i,1}='Z';
         elseif lq1(i)==1
             lq{i,1}='1';
         elseif lq1(i)==0
             lq{i,1}='0';
         elseif lq1(i)==2
             lq{i,1}='2';
         elseif lq1(i)==3
             lq{i,1}='3';
         elseif isempty(lq1(i))==1
             lq{i,1}=NaN;
         end
    end
    end


    if strcmp(argosdata.Properties.VariableNames{1},'Program')==1    
    clear validlocs pttid lat1 lon1 lat2 lon2 dates lq semimajor semiminor eor    
    lat1=argosdata.Latitude;
    validlocs=find(~isnan(lat1));
    argosdata=argosdata(validlocs,:);
    pttid=argosdata.PTT;
    lat1=argosdata.Latitude;
    lon1=argosdata.Longitude;
    lat2=argosdata.LatitudeSolution2;
    lon2=argosdata.LongitudeSolution2;
    dates=datenum(argosdata.LocationDate);
    lq=argosdata.LocationClass;
    semimajor=argosdata.Semi_majorAxis;
    semiminor=argosdata.Semi_minorAxis;
    eor=argosdata.EllipseOrientation;

    end

    %not really sure what this format this is...ha
    if strcmp(argosdata.Properties.VariableNames{1},'DeployID')==1    
    clear pttid lat1 lon1 lat2 lon2 dates lq semimajor semiminor eor    
    %omit lines without valid locations
    argosdata=argosdata((~isnan(argosdata.Latitude)),:);
    pttid=argosdata.PlatformIDNo_;
    lat1=argosdata.Latitude;
    lon1=argosdata.Longitude;
    lat2=argosdata.Lat_Sol_2;
    lon2=argosdata.Long_2;
    dates=datenum(argosdata.Loc_Date);
    lq=argosdata.Loc_Quality;
    semimajor=argosdata.Semi_majorAxis;
    semiminor=argosdata.Semi_minorAxis;
    eor=argosdata.EllipseOrientation;
    end

    %this is argos/GPS data pulled from existing matfiles
    if strcmp(argosdata.Properties.VariableNames{1},'TOPPID')==1
     clear pttid lat1 lon1 lat2 lon2 dates lq semimajor semiminor eor    
    opts=detectImportOptions(argosfiles(j).name); %this likes to turn location classes into non-char which is bad, so reimport the data
    opts = setvartype(opts,{'LocationClass'},'char');
    argosdata=readtable(argosfiles(j).name,opts);
    %omit lines without valid locations
    argosdata=argosdata((~isnan(argosdata.Latitude)),:);
    pttid=argosdata.PTT;
    lat1=argosdata.Latitude;
    lon1=argosdata.Longitude;
    dates=argosdata.JulDate;
    lq=argosdata.LocationClass;
    semimajor=argosdata.SemiMajorAxis;
    semiminor=argosdata.SemiMinorAxis;
    eor=argosdata.EllipseOrientation;   
    end

locs1=table(NaN(length(lat1),1),pttid,dates,datestr(dates,'yyyy-mm-dd HH:MM:SS'),lat1,lon1,lq,semimajor,semiminor,eor,...
       'VariableNames',{'TOPPID','pttid','jdates','dates','lat1','lon1','lq','semimajor','semiminor','eor'});

   
uniqueptts=unique(pttid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%add GPS data if exists in folder
    for k=1:length(uniqueptts)
        gpslocs=table();
       %This is SMRU
         GPSfile=dir('*SMRU_gps.csv');
         if ~isempty(GPSfile)
             for m=1:length(GPSfile)
             SMRU_GPS=readtable(GPSfile(m).name);
                   if sum(ismember(unique(SMRU_GPS.PTT),uniqueptts(k)))>0  
                    GPSdata=SMRU_GPS(find(SMRU_GPS.PTT==uniqueptts(k)),:);
                    toppidg=NaN(height(GPSdata),1);
                    pttidg=repmat(uniqueptts(k),height(GPSdata),1);
                    datesg=GPSdata.D_DATE;
                    datesg=datenum(datesg);
                    lat1g=GPSdata.LAT;
                    lon1g=GPSdata.LON;
                    lc1g=repmat("G",height(GPSdata),1);

                    gpslocs=table(toppidg,pttidg,datesg,datestr(datesg,'yyyy-mm-dd HH:MM:SS'),lat1g,lon1g,lc1g,NaN(length(lat1g),1),...
          NaN(length(lat1g),1),NaN(length(lat1g),1),...
           'VariableNames',{'TOPPID','pttid','jdates','dates','lat1','lon1','lq','semimajor','semiminor','eor'});
                   end
                   clear GPSdata toppidg pttidg datesg lat1g lon1g lc1g
             end
         end

        %this is Wildlife Computers downloaded GPS        

       GPSfile=dir([num2str(uniqueptts(k)) '*FastGPS.csv']);
       if ~isempty(GPSfile)
           for x=1:length(GPSfile) %such as in case of WC downloads where were split between deployments but not identifiable based on filename alone
        GPSdata=readtable(GPSfile(x).name,'HeaderLines',3);
        toppidg=NaN(height(GPSdata),1);
        pttidg=repmat(pttid(1),height(GPSdata),1);
        datesg=(GPSdata.Day+GPSdata.Time);
        datesg=datenum(datesg);
        if abs(mean(datesg(1:10))-mean(locs1.jdates(1:10)))>60 %if the dates of the beginning of the gps data are more than two months away, wrong record
            continue
        end
        lat1g=GPSdata.Latitude;
        lon1g=GPSdata.Longitude;
        lc1g=repmat("G",height(GPSdata),1);

        gpslocs=table(toppidg,pttidg,datesg,datestr(datesg,'yyyy-mm-dd HH:MM:SS'),lat1g,lon1g,lc1g,NaN(length(lat1g),1),...
          NaN(length(lat1g),1),NaN(length(lat1g),1),...
           'VariableNames',{'TOPPID','pttid','jdates','dates','lat1','lon1','lq','semimajor','semiminor','eor'});
           end
       end
        clear GPSdata toppidg pttidg datesg lat1g lon1g lc1g
 

  %merge argos and gps from this ptt and sort by time
  argoslocs=locs1(find(locs1.pttid==uniqueptts(k)),:);
  if height(gpslocs)>0
      locs2=[argoslocs;gpslocs];
  elseif height(argoslocs)==0
      continue
  else
      locs2=argoslocs;    
  end
  locs=sortrows(locs2,3);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%match to deployment metadata in startstop file
   PTTID=uniqueptts(k);
   %use first several days of data to find deployment metadata, because sometimes a tag test (which
   %shouldn't be more than a few days) happens a long time defore a
   %deployment
   %Criterion here: data start needs to be within 30 days of departure
   daysofdata=unique(datenum(datestr(locs.dates,'yyyy-mm-dd')));
   %are there multiple deployments in this file?
   deltatimes=diff(daysofdata);
   cuts=find(deltatimes>20);
   %add first row of data as a "cut" in case the deployment starts right
   %away (no time diff). Add 1 to remaining ones to get beginning of next
   %chunk.
   cuts=[1;cuts+1];
   q=1;
   trackindex=[];
   for m=1:length(cuts)
   tindex1=find(startstop.PTTID==PTTID & abs(datenum(startstop.DepartDate)-daysofdata(cuts(m)))<=30);     
   if ~isempty(tindex1)
   trackindex(q,1)=tindex1; 
   q=q+1;
   end
   end
  
   if isempty(trackindex)==1 & ~isempty(find(startstop.PTTID==PTTID))
           fprintf('Error: No matching record in startstop file found. Time stamps could be off, could be a translocation...')
           continue
   end
   
   %for each track in the data (should hopefully be one):
   for p=1:length(trackindex)
     tindex=trackindex(p);

     TOPPID=startstop.TOPPID(tindex);  
   
       %last GPS check: in existing Matfiles
%        if height(gpslocs)==0
%        cd 'F:\TV3 Mat Files'
%        matfile=dir([num2str(TOPPID) '*TV3.mat']);
%        if ~isempty(matfile)
%            matfiledata=load(matfile.name);
%            if ~isempty(matfiledata.Track_GPS_Raw)  
%         toppidg=NaN(height(matfiledata.Track_GPS_Raw),1);
%         pttidg=repmat(uniqueptts(k),height(matfiledata.Track_GPS_Raw),1);
%         datesg=(matfiledata.Track_GPS_Raw.Day+matfiledata.Track_GPS_Raw.Time);
%         datesg=datenum(datesg);
%         lat1g=matfiledata.Track_GPS_Raw.Latitude;
%         lon1g=matfiledata.Track_GPS_Raw.Longitude;
%         lc1g=repmat("G",height(matfiledata.Track_GPS_Raw),1);
% 
%         gpslocs=table(toppidg,pttidg,datesg,datestr(datesg,'yyyy-mm-dd HH:MM:SS'),lat1g,lon1g,lc1g,NaN(length(lat1g),1),...
%           NaN(length(lat1g),1),NaN(length(lat1g),1),...
%            'VariableNames',{'TOPPID','pttid','jdates','dates','lat1','lon1','lq','semimajor','semiminor','eor'});
%         locs1=[locs;gpslocs];
%         locs=sortrows(locs1,3);
%            end
%        end
%         clear toppidg pttidg datesg lat1g lon1g lc1g matfiledata argoslocs gpslocs locs2
%        end
    
   
   %convert startstop info to matlab time
   StartTime=datenum(startstop.DepartDate(tindex));
   EndTime=datenum(startstop.ArriveDate(tindex));
   %truncate tracks according to startstop dates
   if isnan(EndTime)
     index=find(locs.pttid==PTTID & locs.jdates>=StartTime); 
   else
    index=find(locs.pttid==PTTID & locs.jdates>=StartTime & locs.jdates<=EndTime);
   end
 
   if isempty(index)
       continue
   end

   
   tracklocs=table(repmat(TOPPID,length(index),1),locs.pttid(index),locs.jdates(index),datestr(locs.jdates(index),'yyyy-mm-dd HH:MM:SS'),locs.lat1(index),locs.lon1(index),locs.lq(index),locs.semimajor(index),locs.semiminor(index),locs.eor(index),...
       'VariableNames',{'TOPPID','PTT','JulDate','Date','Latitude','Longitude','LocationClass','SemiMajorAxis','SemiMinorAxis','EllipseOrientation'});
   
   %determine if this track is complete by comparing last location to end
   %location, more than 10 days = incomplete

   row=find(TOPPIDchecklist.TOPPID==TOPPID);
   TOPPIDchecklist.Status(row)="run";
   if height(tracklocs)<10
     TOPPIDchecklist.Complete(row)="Very Little Data";
   elseif isnan(EndTime)
     TOPPIDchecklist.Complete(row)="Incomplete, Did Not Return Home";  
   elseif (EndTime-tracklocs.JulDate(end))>10
     TOPPIDchecklist.Complete(row)="Incomplete, Returned Home";
   else
     TOPPIDchecklist.Complete(row)="Complete";
   end
   
   %add end point to track if seal returned to colony and the data gap is less than 14 days
   EndLat=startstop.ArriveLat(tindex);
   EndLon=startstop.ArriveLon(tindex);
   
   x=height(tracklocs);
   if x<6
       continue
   end

   if ~isnan(EndLat) & ~isnan(EndLon) & (EndTime-tracklocs.JulDate(end))<5
       tracklocs.TOPPID(x+1)=TOPPID;
       tracklocs.PTT(x+1)=locs.pttid(1);
       tracklocs.JulDate(x+1)=EndTime;
       tracklocs.Latitude(x+1)=EndLat;
       tracklocs.Longitude(x+1)=EndLon;
       tracklocs.LocationClass(x+1)={"G"};
       tracklocs.SemiMajorAxis(x+1)=NaN;
       tracklocs.SemiMinorAxis(x+1)=NaN;
       tracklocs.EllipseOrientation(x+1)=NaN;
   end
   tracklocs.Date=datestr(tracklocs.JulDate);
   
   char=strcat(num2str(TOPPID),'_', num2str(PTTID));
   cd 'E:/Eseal Data Paper/All Pre foieGras'
   writetable(tracklocs,[char '_argos_raw_pre_foieGras.csv'])
   clear index StartTime EndTime EndLat EndLon tokeep tracklocs argoslocs gpslocs
   end
   end
   clear argosdata dates lat1 lat2 lc lc2 lon1 lon2 lq pttid trackindex uniqueptts PTTID validlocs TOPPID matrix locs1 locs gpslocs
  
end


%save('TrackRunningChecklist.mat','TOPPIDchecklist')