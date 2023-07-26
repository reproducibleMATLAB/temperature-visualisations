function plotStripes(data, NameValueArgs)


arguments
    data table
    NameValueArgs.plotBarHeights logical = false
end

    % add mean of tmax and tmin to table
    data.tmid = (data.tmax(:)+data.tmin(:))/2;
    tt = table2timetable(data);
    tt = retime(tt, 'yearly', 'mean');
    
    % colour scale is calibrated against the average temperature 1971-2000
    % see https://showyourstripes.info/faq
    averaging_timerange = timerange("1971-01-01","2000-12-31");
    tmid_mean_1971_2000 = mean(tt(averaging_timerange, :).tmid);
    tmin_mean_1971_2000 = mean(tt(averaging_timerange, :).tmin);
    tmax_mean_1971_2000 = mean(tt(averaging_timerange, :).tmax);

    figure;
    max_temp = max(tt.tmid);
    min_temp = min(tt.tmid);
    
    for i=1:size(tt, 1)
        temperature = tt.tmid(i);
        threshold = tmid_mean_1971_2000;
        
        if temperature == threshold
            color = 'w';
        elseif temperature > threshold
            color = [1 0 0] + [0 1 1]*(1-(temperature - threshold)/(max_temp - threshold));
        else
            color = [0 0 1] + [1 1 0]*(1-(threshold - temperature)/(threshold - min_temp));
        end
        
        if NameValueArgs.plotBarHeights
            height = temperature - threshold;
        else
            height = 1;
        end
    
        bar(tt.date.Year(i), height, 'FaceColor',color,'EdgeColor',color,'LineStyle',"none", 'BarWidth', 1);hold on
        set(gca,'XTickLabel',[]);
        set(gca,'YTickLabel',[]);
        set(gca,'XTick',[])
        set(gca,'YTick',[])
        set(gca, 'xlim',[min(tt.date.Year) max(tt.date.Year)])
        if NameValueArgs.plotBarHeights; set(gca,'color',[0 0 0]); end
    end
end