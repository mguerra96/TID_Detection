function Plot_Fit_In_TimeWin(C_tw,plot_or_not)

%this function plots dtecs arcs along with the fitted sinusoidal

if plot_or_not
    for C_tw_idx=1:size(C_tw,1)
        if size(C_tw{C_tw_idx,2},1)==0 %skip prn showing no wavy arcs for given time window
            continue
        end
        figure('units','normalized','outerposition',[0 0 1 1])
        tiledlayout('flow')
        for iprn=unique(C_tw{C_tw_idx,2}.prn)'   
            nexttile

            title(['PRN' num2str(iprn) ' - ' char(max(C_tw{C_tw_idx,1}(C_tw{C_tw_idx,1}.prn==iprn,:).dt)-min(C_tw{C_tw_idx,1}(C_tw{C_tw_idx,1}.prn==iprn,:).dt))])
            hold on
            c=hsv(length(unique(C_tw{C_tw_idx,1}(C_tw{C_tw_idx,1}.prn==iprn,:).id)));

            for iID=C_tw{C_tw_idx,2}(C_tw{C_tw_idx,2}.prn==iprn,:).id'
                grid on
                %plot arcs for given PRN 
                plot(C_tw{C_tw_idx,1}(C_tw{C_tw_idx,1}.prn==iprn & C_tw{C_tw_idx,1}.id==iID,:).dt,C_tw{C_tw_idx,1}(C_tw{C_tw_idx,1}.prn==iprn & C_tw{C_tw_idx,1}.id==iID,:).dtec,'color',c(iID==C_tw{C_tw_idx,2}(C_tw{C_tw_idx,2}.prn==iprn,:).id,:)*0.8,'LineWidth',1,'DisplayName',['R^2:' num2str(C_tw{C_tw_idx,2}(C_tw{C_tw_idx,2}.prn==iprn & C_tw{C_tw_idx,2}.id==iID,:).rsquare,'%.3f') ' - RMSE:' num2str(C_tw{C_tw_idx,2}(C_tw{C_tw_idx,2}.prn==iprn & C_tw{C_tw_idx,2}.id==iID,:).rmse,'%.3f')])
                %calculate sinusoidal in time points of arc
                x=seconds(C_tw{C_tw_idx,1}(C_tw{C_tw_idx,1}.prn==iprn & C_tw{C_tw_idx,1}.id==iID,:).dt-min(C_tw{C_tw_idx,1}(C_tw{C_tw_idx,1}.prn==iprn & C_tw{C_tw_idx,1}.id==iID,:).dt));
                off=C_tw{C_tw_idx,2}(C_tw{C_tw_idx,2}.prn==iprn & C_tw{C_tw_idx,2}.id==iID,:).off;
                amp=C_tw{C_tw_idx,2}(C_tw{C_tw_idx,2}.prn==iprn & C_tw{C_tw_idx,2}.id==iID,:).amp;
                period=C_tw{C_tw_idx,2}(C_tw{C_tw_idx,2}.prn==iprn & C_tw{C_tw_idx,2}.id==iID,:).per;
                phase=C_tw{C_tw_idx,2}(C_tw{C_tw_idx,2}.prn==iprn & C_tw{C_tw_idx,2}.id==iID,:).phase;
                y=off+amp*sin(2*pi*x/period+phase);
                %plot sinusoidal with same color 
                plot(min(C_tw{C_tw_idx,1}(C_tw{C_tw_idx,1}.prn==iprn & C_tw{C_tw_idx,1}.id==iID,:).dt)+duration(seconds(x)),y,'Color',c(iID==C_tw{C_tw_idx,2}(C_tw{C_tw_idx,2}.prn==iprn,:).id,:)*0.75,'LineWidth',1,'LineStyle','--','DisplayName',['T:' num2str(round(C_tw{C_tw_idx,2}(C_tw{C_tw_idx,2}.prn==iprn & C_tw{C_tw_idx,2}.id==iID,:).per/60)) 'min'])
                legend('location', 'best');
            end
        end
    end
end

end


