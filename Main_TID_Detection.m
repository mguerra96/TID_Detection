clear
close all
clc

%% DATABASE CREATION

% LOAD LIST OF STATIONS OF INTEREST
load stat_sel.mat

% AMOUNT OF STATIONS TO CONSIDER OF THE GIVEN NETWORK
stat2keep=5;

% DATETIME TO STUDY AND TIME TO STUDY

time_of_interest=18;

year=2017;
month=9;
day=8;

doy=date2doy(datenum([num2str(month) '/' num2str(day) '/' num2str(year)]));
time_of_interest=datetime(year,month,day,floor(time_of_interest),mod(time_of_interest,1)*60,0);

%% READ RINEX FILES, COMPUTE GFLC, FIND IPPS AND PREPARE ARC DB

Need2Calibrate=exist(['C:\Users\MarcoGuerra\Documents\MATLAB\TID_Detection\C_Backups\C_' num2str(year) '_' num2str(doy,'%03d') '.mat'],'file');

tic
C=Download_And_Calibrate(year,doy,Need2Calibrate,stat2keep,stat_sel);
toc


%% VERTICALIZATION WITH NEQUICK AND DETRENDING

fprintf('Verticalizing arcs...\n')

C=C(C.ele>=20,:);
Output=rowfun(@NeQuick_Calibrator,C,"GroupingVariables","id","OutputVariableNames",{'vtec'},"InputVariables",{'gflc','lon','lat','ele','azi','dt'});
C.vtec=Output.vtec;
toc


%% TID DETECTION IN MOVING WINDOW

fprintf('Detrending and extracting parameters...\n')

C_tw=Moving_Win_TID_Detection(C,time_of_interest,1,0);
toc

