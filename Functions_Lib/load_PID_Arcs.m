function C_new=load_PID_Arcs(files,i,t_res)
%this fucntion reads the output files of the pietro calibration and checks
%for the arcs continuity, if data gaps are present it will delete them. at
%the same time it identifies single arcs for those prn that are seen twice
%in a single day


tab=readtable([files(i).folder '\' files(i).name],'FileType','text');
tab(isnan(tab.geo_free_code_lev),:)=[];

tab.prn(:)=nan;
tab.sv=cell2mat(tab.sv);

tab.prn(contains(string(tab.sv),'G'))=str2num(tab.sv(contains(string(tab.sv),'G'),2:end));
tab.prn(contains(string(tab.sv),'R'))=str2num(tab.sv(contains(string(tab.sv),'R'),2:end))+37;
tab.prn(contains(string(tab.sv),'E'))=str2num(tab.sv(contains(string(tab.sv),'E'),2:end))+74;
tab.sv=[];
tab.altIPP=[];
tab.TEC=[];
tab.VTEC=[];
tab(tab.elev<=10,:)=[];
tab.Var1=[];

tab.Properties.VariableNames={'dt','azi','ele','lat','lon','gflc','prn'};
%TAKE CARE OF CONTROLLING arc.dt datetime() TO AVOID TIME ERRORS
tab.stat(:)=string(files(i).name(1:4));
tab.dt=dateshift(tab.dt,'start','minute')+seconds(round(second(tab.dt),1));
tab.sod=hour(tab.dt)*3600+minute(tab.dt)*60+second(tab.dt);
C_new=[];
cont=0;

for iPRN=unique(tab.prn)'

    arc=tab(tab.prn==iPRN,:);

    aux_diff=diff(arc.sod);
    if t_res==1
        aux_diff1=find(aux_diff>20);
    else
        aux_diff1=find(aux_diff>120); %check for data gaps
    end

    if length(aux_diff1)>2 %if more than two long data gaps are present, delete arc
        arc=[];
    elseif length(aux_diff1)==1
        aux_idx=aux_diff1; %assign arc ids to different arcs
        arc.arc_id=zeros(size(arc,1),1);
        arc.arc_id(1:aux_idx)=1;
        arc.arc_id(arc.arc_id==0)=2;

        if height(arc(arc.arc_id==2,:))<120 %check that single arcs are long enough
            arc=arc(1:aux_idx,:);
        elseif height(arc(arc.arc_id==1,:))<120
            arc=arc(aux_idx+1:end,:);
        end
        if length(unique(arc.arc_id))==1
            arc.arc_id(:)=1;
        end

    elseif length(aux_diff1)==2
        arc.arc_id=zeros(size(arc,1),1);
        arc.arc_id(1:aux_diff1(1))=1;
        arc.arc_id(aux_diff1(2)+1:end)=3;
        arc.arc_id(arc.arc_id==0)=2;

        if height(arc(arc.arc_id==3,:))<120
            arc(arc.arc_id==3,:).arc_id(:)=0;
        end
        if height(arc(arc.arc_id==2,:))<120
            arc(arc.arc_id==2,:).arc_id(:)=0;
        end
        if height(arc(arc.arc_id==1,:))<240
            arc(arc.arc_id==1,:).arc_id(:)=0;
        end

        arc(arc.arc_id==0,:)=[];

    else
        arc.arc_id=ones(size(arc,1),1);
    end

    if ~isempty(arc)
        ids=unique(arc.arc_id);

        for t=1:length(ids)
            gelbi=ids(t);
            arc_t=arc(arc.arc_id==gelbi,:);
            arc_t.id=arc_t.arc_id+cont;
            cont=cont+max(arc_t.arc_id);
            if size(arc_t,1)<900/t_res
                continue
            end

            C_new=[C_new ; arc_t]; %add all arcs to same table

        end
    end
end
end