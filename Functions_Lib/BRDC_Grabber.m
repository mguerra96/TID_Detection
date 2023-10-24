function BRDC_Grabber(doy,year,brdc_dir)

% this fucntion connects to EUREF FTP and download the BRDC file for the
% given day and it saves it in the brdc_dir

init_dir=pwd;

year=num2str(year);
doy=num2str(doy);

if length(doy)==1
    doy=['00' doy];
elseif length(doy)==2
    doy=['0' doy];
end

db_dir=brdc_dir;

if ~exist(db_dir)
    mkdir(db_dir)
end

aux_ftp=ftp('www.epncb.oma.be');
cd(aux_ftp,['pub/obs/BRDC/' year ]);
brdc2get=dir(aux_ftp);

for i=1:length(brdc2get)
    if contains(brdc2get(i).name,[year doy])
        mget(aux_ftp,brdc2get(i).name,db_dir);
        break
    end
end

close(aux_ftp)
cd(pwd)

end

