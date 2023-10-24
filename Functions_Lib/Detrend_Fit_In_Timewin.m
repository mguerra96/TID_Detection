function [C, output]=Detrend_Fit_In_Timewin(C,time_win,time_of_interest)

%this fucntion takes as input time of interest and time window and applies
%detrending accordingly. If the amount of station for given prn that show
%dtec lower than minamp is lower than 4 ==> the prn is discarded

min_amp=0.25; %amplitude treshold > if amplitude is lower than this discard arc

unrealistic_amp_treshold=4; %if max amp is higher delete arc

C=C(C.dt>=time_of_interest-time_win & C.dt<=time_of_interest,:); %Keep only data belonging to given time window

counts=groupcounts(C,'id'); %count elements of each arc in given time win
counts=counts(counts.GroupCount<=round(seconds(time_win)/30*0.8),:);
C(ismember(C.id,counts.id),:)=[];   %keep only arcs where amount of samples is equal to 0.8 x time win

func=@(x) My_Detrending(x,time_win,min_amp,unrealistic_amp_treshold); %initialize mydetrending function
Output=rowfun(func,C,'InputVariables','vtec','groupingvariables','id','OutputVariableNames','dtec'); %apply mydetrending fucntion to arc database
C.dtec=Output.dtec;
C(isnan(C.dtec),:)=[]; %checks that more than 3 stat for prn are showing dtec higher than treshold

counts=groupcounts(groupcounts(C,{'id','prn'}),'prn');
counts=counts(counts.GroupCount<3,:);
C(ismember(C.prn,counts.prn),:)=[];

func=@(x,y,z) New_SineFit(x,y,z,time_win); 
output=rowfun(func,C,'InputVariables',{'dt','dtec','prn'},'GroupingVariables','id','OutputVariableNames',{'off','amp','per','phase','prn','ae','rmse','rsquare'}); %apply sine fitting to arcs of dtec to extract main period
output=output(output.rmse<=0.05 & output.rsquare>=0.75,:);
C=C(ismember(C.id,output.id),:);

counts=groupcounts(groupcounts(C,{'id','prn'}),'prn');
counts=counts(counts.GroupCount<3,:);
C(ismember(C.prn,counts.prn),:)=[];
output(ismember(output.prn,counts.prn),:)=[];

end
