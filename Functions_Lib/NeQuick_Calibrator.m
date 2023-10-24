function vtec=NeQuick_Calibrator(stec,lon,lat,ele,azi,dt)

% this function uses nequick to "calibrate" and verticalize the gflc of
% phase measurements. To do so, it assign zero gflc to the point of max
% elevation. then it calculates value of stec with nequick and finilly it
% verticalize. This should allow a low degree of mapping function error
try 
init_dir=pwd;

Hipp=250;
Re=6371;
sat_height=20000;

idx_max_ele=find(ele==max(ele));
idx_max_ele=idx_max_ele(1); %avoid issues due to multiple time samples with same elevation

%calculate satellite position in lla
psi=90-ele(idx_max_ele)-asind((Re/(Re+sat_height))*cosd(ele(idx_max_ele)));
lat_sat=asind(sind(lat(idx_max_ele)).*cosd(psi)+cosd(lat(idx_max_ele)).*sind(psi).*cosd(azi(idx_max_ele)));
lon_sat=lon(idx_max_ele)+asind(sind(psi).*sind(azi(idx_max_ele))./cosd(lat_sat));

%calculate station position in lla
psi=90-ele(idx_max_ele)-asind(cosd(ele(idx_max_ele)));
lat_stat=asind(sind(lat(idx_max_ele)).*cosd(psi)+cosd(lat(idx_max_ele)).*sind(psi).*cosd(azi(idx_max_ele)));
lon_stat=lon(idx_max_ele)+asind(sind(psi).*sind(azi(idx_max_ele))./cosd(lat_sat));

sstec=stec-stec(idx_max_ele);

yy = year(dt(idx_max_ele));
mm = month(dt(idx_max_ele));
hr = hour(dt(idx_max_ele));

% Change directory to run nequick
cd C:\Users\MarcoGuerra\Documents\MATLAB\Softwares\NeQuick

bias = NeQuick2(lat_stat,lon_stat,0,lat_sat,lon_sat,20000, yy-2000, mm,1,hr,1,10,1)*0.1; %calculate stec with nequick given stat and satellite coordaintes in lla format

% move back to initial dir
cd(init_dir);

vtec=(sstec+bias).*cos(asin(6371/(6371+Hipp)*cosd(ele)));
vtec=smoothdata(vtec,20);

catch
    stec(:)=nan;
    vtec=stec;
end
end