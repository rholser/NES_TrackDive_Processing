Process elephant seal tracking data (Argos and GPS) for inclusion in Matfiles.
Code written by Theresa Keates, last updated April 2022.

Step 0: Collect all your tracking data. See Metadata readme (information also in Step 1 script).
-----------------------------------------
Step 1: prep_argos_and_gps_for_foieGras.m 

This imports all Argos and GPS csv files, trims locations before and after the deployment based on startstop.csv, and formats it for input to foieGras. 

It separates the Argos/GPS locations based on PTT and then identifies if there are multiple deployments of the same tag if there is a time gap of >20 days. 
This should catch tags turned and put out the next season, but if you are doing translocations or something else that has very short turnarounds, adjust this/proceed with caution.

It assigns an end point to the track at the colony specified in the startstop.csv IF the is not a gap more than 14 days long (to avoid drawing a straight line back to the colony that is largely meaningless). This can be changed to fit your needs.

(Optional) Makes a file TOPPIDchecklist.mat with information on your tracks in a table with three columns: TOPPID (all TOPPIDs in the startstop.csv you gave it), Status, and Complete. If tracking data for a TOPPID has been identified, the “Status” becomes “run.” It determines whether your track is complete by comparing the last location to the end time from startstop.csv. If there’s a gap less than 10 days, it called the track “Complete,” otherwise either “Incomplete, Returned Home” if the seal came back (based on return exiting in startstop.csv) or “Incomplete, Did Not Return Home” if there is no return date/location in startstop.csv. It will also flag tracks with fewer than 10 locations as “Very Little Data” – because unfortunately this happens sometimes.

Note: This script identifies many different input formats, as they have changed over the years, but this will likely not be future proof forever. All you should need to change if it doesn’t work is to tell it what the names of the columns are in which your data are stored in your input csv files.
-----------------------------------------
Step 2: run_foieGras_for_Matfiles.R

This imports the csvs generated by the matlab script. It applies a land filter using bathymetry data (a netCDF file called usgsCeSS111_074f_a9d5_7b24.nc which must be in your working directory, dataset ID usgsCeSS111 from ERDDAP). 

It then runs foieGras, a continuous time sate-space model incorporating location error estimates to filter the tracking data and interpolate to regular time intervals. The time interval is set to 1 hour and the speed filter (to throw out locations that suggest a seal is travelling faster than this) is set to 3 m/s. These can easily be changed within the call to foieGras. 
Your output file will have interpolated locations and error estimates (x.se and y.se, in units of km). 

This script will also generate pdf files of a figure plotting your input location data and your foieGras output. Highly recommend doing a visual QC, because you’ll be able to see if, for example, there were very few locations resulting in foieGras oversmoothing the track (this would also result in high x.se and y.se).

References for foieGras:
(also write in a paper which version you used; version 0.7-7.9276 was used in 2022 for *TV4alpha.mat files):
Jonsen, I.D., McMahon, C.R., Patterson, T.A., Auger-Méthé, M., Harcourt, R., Hindell, M.A., Bestley, S., 2019. Movement responses to environment: fast inference of variation among southern elephant seals with a mixed effects model. Ecology 100, 1–8. doi:10.1002/ecy.2566
Jonsen, I.D., Patterson, T.A., Costa, D.P., Doherty, P.D., Godley, B.J., Grecian, W.J., Guinet, C., Hoenner, X., Kienle, S.S., Robinson, P.W., Votier, S.C., Witt, M.J., Hindell, M.A., Harcourt, R.G., McMahon, C.R., 2020. A continuous-time state-space model for rapid quality-control of Argos locations from animal-borne tags. Mov. Ecol. 8. doi:10.1186/s40462-020-00217-7


Note on troubleshooting: issues running foieGras are almost always date related. This is the line turning your input dates into POSIXct opjects: trackdata$date=as.POSIXct(argosdata$Date,tz="GMT",format='%d-%b-%Y %H:%M:%S').
Weird stuff sometimes happens when the csv created by the Matlab script is opened by Excel (especially if you open in Excel and then save changes) or in R, so the script is written to identify what R reads your dates in as. The two formats I have encountered are '%d-%b-%Y %H:%M:%S'and '%m/%d/%Y %H:%M' so it distinguishes between those two. There may be others, so the format the as.POSIXct function is fed may need to be modified.

If you run into trouble downloading foieGras, Google "foieGras Github" and the page should give you the most updated code to download.