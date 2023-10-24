function [off,amp,per,phase,prn,ae,rmse,rsquare]=New_SineFit(x,y,z,time_win)

%This function fit a sinusoidal to the given dtec arc, and calculates the
%rmse and absolute error between fit and real signal

warning off

%initiale model and set fit parameter boundaries and settings

mdl = fittype('off+amp*sin(2*pi*x/per+phase)','indep','x');
fit_opt=fitoptions(mdl);
fit_opt.Lower=[0.1 -0.05 seconds(time_win)*0.4 -inf];
fit_opt.Upper=[5 0.05 seconds(time_win)*0.9 +inf];
fit_opt.MaxFunEvals=1e5;
fit_opt.MaxIter=1e5;

%fit model to data

[fitted_mdl,gof] = fit(seconds(x-min(x)),y,mdl,fit_opt);


%preparing output

prn=z(1);

off=fitted_mdl.off;
amp=fitted_mdl.amp;
per=fitted_mdl.per;
phase=fitted_mdl.phase;

ae=mean(abs(fitted_mdl(seconds(x-min(x)))-y));
rmse=gof.rmse;
rsquare=gof.rsquare;
end

