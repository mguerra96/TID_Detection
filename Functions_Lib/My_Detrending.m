function dtec=My_Detrending(vtec,time_win,min_amp,max_amp)

%this fucntion detrends arcs of vtec. an expansion is added to reduce
%boundary effects with Antisymmetric padding (whole point)
%to detrend an highpass filter set with treshold equal to 0.8 of time
%window is applied 
%smoothing is also applied to reduce high frequencies

extension_L=length(vtec); 
vtec=My_Sig_Extension(vtec,{'asymw'},extension_L); %signal extension

dtec=highpass(vtec,1/seconds(time_win*0.8),1/30); %apply highpass to remove trends (treshold set according to 0.8*time window)
dtec=smoothdata(dtec,'gaussian',round(seconds(time_win)/30*0.2)); %remove high-frequencies (treshold set according to 0.1*time window)
dtec=dtec(extension_L+1:end-extension_L)';

if (max(dtec)-min(dtec))<min_amp | (max(dtec)-min(dtec))>max_amp
    dtec(:)=nan;
end

end