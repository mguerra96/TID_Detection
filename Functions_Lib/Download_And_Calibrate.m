function C=Download_And_Calibrate(year,doy,Need2Calibrate,stat2keep,stat_sel)

init_dir=pwd;

if Need2Calibrate==0

    % DIRECTORIES OF FILES NECESSSARY FOR CALIBRATION
    db_main_dir='C:\Users\MarcoGuerra\Documents\PYTHON\TEC-calibration-new_input_ingest_modip_mod\RINEX_FILES';
    db_dir=[db_main_dir '\obs_files'];
    brdc_dir=[db_main_dir '\nav_files'];
    output_dir=[db_main_dir '\csv_outputs'];

    % CREATION OF DATABASE AND STATION SELECTION THROUGH KMEANS (EUREF NETWORK)
    fprintf('Dowloading EUREF data...\n')
    EUREF_DB_Creator_STAT_Sel(doy,year,stat2keep,db_dir,stat_sel) %CREATE DATABASE OF STATIONS FROM EUREF FTP SERVER
    fprintf('Dowloading BRDC file...\n')
    BRDC_Grabber(doy,year,brdc_dir) %GRAB BRDC FOR UEREF FTP SERVER


    %% CALIBRATION

    %SETTING PYTHON CALIBRATION PATH
    pyExec = 'C:\Users\MarcoGuerra\anaconda3\envs\calibration\python';
    pyRoot = fileparts(pyExec);
    p = getenv('PATH');
    p = strsplit(p, ';');
    addToPath = {
        pyRoot
        fullfile(pyRoot, 'Library', 'mingw-w64', 'bin')
        fullfile(pyRoot, 'Library', 'usr', 'bin')
        fullfile(pyRoot, 'Library', 'bin')
        fullfile(pyRoot, 'Scripts')
        fullfile(pyRoot, 'bin')
        };
    p = [addToPath(:); p(:)];
    p = unique(p, 'stable');
    p = strjoin(p, ';');
    setenv('PATH', p);

    cd C:\Users\MarcoGuerra\Documents\PYTHON\TEC-calibration-new_input_ingest_modip_mod
    fprintf('Reading RINEX files and calculating IPPs...\n')
    tic
    [~ , ~]=system('python main_mio.py');
    toc
    cd(db_dir)
    delete('*')
    cd(init_dir);

    %% READING CALIBRATION OUTPUT AND CREATING ARC DATABASE

    C=read_PIDCAL(30,output_dir);
    save(['C:\Users\MarcoGuerra\Documents\MATLAB\TID_Detection\C_Backups\C_' num2str(year) '_' num2str(doy,'%03d') '.mat'],'C')

else
    fprintf('Data matrix already available\n')
    load(['C:\Users\MarcoGuerra\Documents\MATLAB\TID_Detection\C_Backups\C_' num2str(year) '_' num2str(doy,'%03d') '.mat'])
end

end