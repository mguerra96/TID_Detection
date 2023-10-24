function C_tw=Moving_Win_TID_Detection(C,time_of_interest,plot_or_not,legend_or_not)

time_wins=[duration(minutes(10)) duration(minutes(20)) duration(minutes(30)):duration(minutes(15)):duration(minutes(90))];

C_tw=cell(size(time_wins,2),2); %create cell where to store output of sinefit and detrending for different timewindows

for time_win_idx=1:length(time_wins)
    [C_tw{time_win_idx,1},C_tw{time_win_idx,2}]=Detrend_Fit_In_Timewin(C,time_wins(time_win_idx),time_of_interest); %create 2 cell: 1 containing data in given timewindow and 1 with outputs of sinefittting
end

Plot_Fit_In_TimeWin(C_tw,plot_or_not,legend_or_not) %plot arcs and sinefit to evaluate goodness of fit visually

end