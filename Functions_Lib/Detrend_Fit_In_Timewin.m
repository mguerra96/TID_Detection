function [C, output]=Detrend_Fit_In_Timewin(C,time_win,time_of_interest)

warning off

%this fucntion takes as input time of interest and time window and applies
%detrending accordingly. If the amount of station for given prn that show
%dtec lower than minamp is lower than 4 ==> the prn is discarded

min_amp=0.25; %amplitude treshold > if amplitude is lower than this discard arc

unrealistic_amp_treshold=4; %if max amp is higher delete arc

extend_or_not=0; %0 for no extension of signal, 1 for extension

C=C(C.dt>=time_of_interest-time_win & C.dt<=time_of_interest,:); %Keep only data belonging to given time window

counts=groupcounts(C,'id'); %count elements of each arc in given time win
counts=counts(counts.GroupCount<=round(seconds(time_win)/30*0.8),:);
C(ismember(C.id,counts.id),:)=[];   %keep only arcs where amount of samples is equal to 0.8 x time win

func=@(x) My_Detrending(x,time_win,min_amp,unrealistic_amp_treshold,extend_or_not); %initialize mydetrending function
Output=rowfun(func,C,'InputVariables','vtec','groupingvariables','id','OutputVariableNames','dtec'); %apply mydetrending fucntion to arc database
C.dtec=Output.dtec;
C(isnan(C.dtec),:)=[]; %checks that more than 3 stat for prn are showing dtec higher than treshold

%check amount of wavy arcs per prn, and remove prn that show less than 4
%wavy arcs
counts=groupcounts(groupcounts(C,{'id','prn'}),'prn');
counts=counts(counts.GroupCount<4,:);
C(ismember(C.prn,counts.prn),:)=[];

func=@(x,y,z) New_SineFit(x,y,z,time_win);
output=rowfun(func,C,'InputVariables',{'dt','dtec','prn'},'GroupingVariables','id','OutputVariableNames',{'off','amp','per','phase','prn','ae','rmse','rsquare','real_amp'}); %apply sine fitting to arcs of dtec to extract main period

% check that at least 4 arcs per prn show good agreement between sinefit and
% detrended tec
output=output(output.rmse<=0.075 & output.rsquare>=0.666,:);
C=C(ismember(C.id,output.id),:);
counts=groupcounts(groupcounts(C,{'id','prn'}),'prn');
counts=counts(counts.GroupCount<4,:);
C(ismember(C.prn,counts.prn),:)=[];
output(ismember(output.prn,counts.prn),:)=[];

output=sortrows(output,'prn');

% % check that sine parameters are consisent between arcs (std of phase)
% %    REMOVED DUE TO DIFFICULTY IN PERIODICITY OF PHASE (ES -3 AND +3 ARE SIMILAR BUT HIGH STD)
% if ~isempty(output)
%     func=@(x) ones(length(x),1)*std(x);
%     phase_std=rowfun(func,output,'GroupingVariables','prn','InputVariables','phase','OutputVariableNames','std');
%     output.phase_std=phase_std.std;
%     output=output(output.phase_std<1,:);
%     C=C(ismember(C.prn,output.prn),:);
% end

%check that sine parameters are consisent between arcs (std of period)
if ~isempty(output)
    func=@(x) ones(length(x),1)*std(x);
    per_std=rowfun(func,output,'GroupingVariables','prn','InputVariables','per','OutputVariableNames','std');
    output.per_std=per_std.std;
    output=output(output.per_std<seconds(time_win)/25,:);
    C=C(ismember(C.prn,output.prn),:);
end

end
