function C=read_PIDCAL(t_res,output_dir)

%this function read the outputs of the pietro calibration and identifies
%single arcs assigning to them an ID
files=dir([output_dir '\*.csv']);

C=[];

conta=0;
fprintf('Reading Calibrated FIles...\n')
for j=1:length(files)
    if files(j).bytes/1e3<2 
        continue                %skip empty files
    end
    fprintf('Step %d out of %d\n',[j length(files)])
    tC=load_PID_Arcs(files,j,t_res); %this is the function that loads the single file
    if isempty(tC)
        continue
    end
    tC2=[];
    for iids=unique(tC.id)'
        tarc=tC(tC.id==iids,:);
        if isempty(tarc)
            continue
        end
        times=table(transpose(tarc.dt(1):seconds(t_res):tarc.dt(end)));
        times.Properties.VariableNames={'dt'};
        tarc=outerjoin(tarc,times,'MergeKeys',true);
        stat=tarc.stat(1);
        tarc.stat=[];
        tarc=fillmissing(tarc,'pchip');  %fill missing values in arc timeseries
        tarc.stat(:)=stat;
        tC2=[tC2 ; tarc];
    end
    tC=[];
    tC2.id=tC2.id+conta;
    conta=max(tC2.id);

    C=[C;tC2];

end

C.sod=[];
C.arc_id=[];

delete([files(1).folder '\*']) %clean output directory

end