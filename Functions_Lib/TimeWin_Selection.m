function [C_out,TID]= TimeWin_Selection(C_tw)

C_param=zeros(size(C_tw,1),3);

for i=1:size(C_param,1)
   C_param(i,1)=length(unique(C_tw{i,2}.prn));
   C_param(i,2)=mean(C_tw{i,2}.per);
   C_param(i,3)=std(C_tw{i,2}.per);
   C_param(i,4)=mean(C_tw{i,2}.real_amp);
   C_param(i,5)=std(C_tw{i,2}.real_amp);
end

idx_time_win=find(C_param(:,1)==max(C_param(:,1)));

if length(unique(idx_time_win))>1
    C_param=C_param(idx_time_win,:);
    idx=C_param(:,3)==min(C_param(:,3));
    idx_time_win=idx_time_win(idx);
end

if isempty(idx_time_win) || max(C_param(:,1))<4
    TID=[];
    C_out=[];
    return
end

C_out=C_tw(idx_time_win,:);

TID.period=round(mean(C_out{1,2}.per)/60);
TID.period_std=round(std(C_out{1,2}.per)/60);
TID.amp=mean(C_out{1,2}.real_amp);
TID.amp_std=std(C_out{1,2}.real_amp);
TID.prns=C_param(idx_time_win,1);

end

