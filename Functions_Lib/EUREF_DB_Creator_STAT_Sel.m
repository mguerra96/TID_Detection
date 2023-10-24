function EUREF_DB_Creator_STAT_Sel(doy,year,stat2keep,db_dir,stat_sel)

% This function connects to euref ftp and downloads stations listed in
% stat_sel. After that, it unzips and selects an amount equal to stat2keep
% to keep and use for following studies

init_dir=pwd;

year=num2str(year);
doy=num2str(doy,'%03d');


if ~exist(db_dir)
    mkdir(db_dir)
end

%

aux_ftp=ftp('www.epncb.oma.be');
cd(aux_ftp,['pub/obs/' year '/' doy]);
files2get=dir(aux_ftp);


parfor files2get_idx=1:length(files2get)
    if sum(contains(stat_sel.Name,files2get(files2get_idx).name(1:4)))~=0
        mget(aux_ftp,files2get(files2get_idx).name,db_dir);
    end
end

close(aux_ftp)

copyfile('C:\Users\MarcoGuerra\Documents\MATLAB\Softwares\7za.exe', db_dir)

err_flag=0;

copyfile('C:\Users\MarcoGuerra\Documents\MATLAB\Softwares\crx2rnx.exe',db_dir)
cd(db_dir)

% delete([db_dir '\*gz']); %MOST OF RINEX V3 ARE IN THE DB AS WELL IN V2 - THUS NO NEED TO PROCESS

files2dezip=[dir([db_dir '\*.Z']) ; dir([db_dir '\*.gz'])];

parfor i=1:length(files2dezip)
    try
        [~,~]=system(['7za e ' files2dezip(i).name]);  %Unzipping
    end
end

delete([db_dir '\*.z']);
delete([db_dir '\*gz']);

delete('.\7za.exe')

files2dehata=[dir([db_dir '\*.*D']) ; dir([db_dir '\*.crx'])];

parfor i=1:length(files2dehata)
    try
        [~,~]=system(['CRX2RNX ' files2dehata(i).name]); %dehatanaka
    end
end

delete('.\crx2rnx.exe')  %cleaning obs directory
delete([db_dir '\*.*d']);
delete([db_dir '\*.*crx']);

file_template2=['*.' year(3:4) 'O'];
file_template3='*.rnx';

warning off

% STEP 1 : reading receiver ECEF xyz and converting to Lat,Long to allow spatial selection

filesv2=dir([db_dir '\' file_template2]); %.**o files directory
filesv3=dir([db_dir '\' file_template3]);
files=[filesv2 ; filesv3];

wgs84 = wgs84Ellipsoid('meter');
wgs84_km = wgs84Ellipsoid('kilometer');  % creation of reference ellipsoid for coordinate conversion

Station=table;
station_list=cell(length(files),1);

for i=1:length(files)
    
    station_list{i,1}=files(i).name(1:4);
    Station.Name(i,1)=string(files(i).name);
    
    Pos_rec=find_recPos([db_dir  '\' files(i).name]);
    
    [lat,lon,~]=ecef2geodetic(wgs84,Pos_rec(1),Pos_rec(2),Pos_rec(3));
    Station.Latitude(i,1)=lat;
    Station.Longitude(i,1)=lon;
    
end

Station(isnan(Station.Latitude),:)=[];

%%
%STEP 2 : receiver selection thorugh K-Means clustering

[~ , c_low]=kmeans([Station.Longitude,Station.Latitude],stat2keep,'Replicates',1000,'MaxIter',1000,'Start','sample');

idx_low=dsearchn([Station.Longitude,Station.Latitude],c_low);

Station.Keep33(idx_low)=1;

for idx_station=1:height(Station)
    if Station(idx_station,:).Keep33==0
        delete([char(Station(idx_station,:).Name) '*'])
    end
end

filenames=[dir([db_dir '\*.*O']) ; dir([db_dir '\*.rnx'])];

listnames=[];

for i=1:length(filenames)
    listnames=[listnames ; string(filenames(i).name(1:4))];
end

[~ , i, ~] = unique(listnames,'first');
indexToDupes = find(not(ismember(1:numel(listnames),i)));

for i=1:length(indexToDupes)
    delete(filenames(indexToDupes(i)).name);  %delete duplicate files where same station has both rinex v2 and v3
end

cd(init_dir)

end