clear;clc

data = read_temperature_file(fullfile("data", "milton_MA.csv"));
tt = table2timetable(data);
tt = retime(tt, 'monthly', 'mean');

%%

close all
ax = polaraxes();

monthNames = month(datetime(1, 1:12, 1), 's');

%%

cmap = flip(colormap(turbo(size(tt, 1))), 1);

alpha_reduction_factor = 0.98;
plotted_lines = [];
line_new_alpha = 1;

% calculate the average temperature per calendar month over the whole timeseries
avg_temp = [];
for m = 1:12
    month_temps = tt(tt.date.Month==m, :).tmax;
    avg_temp(m) = mean(month_temps, 'omitnan');
end
month = [1:1:12];
monthly_mean = table(month', avg_temp', 'VariableNames', ["Month", "Avg_Temp"]);

% Gif writing parameters
write_gif = true;
start_new_image_file = true;
filename = "temperature_polar_plot.gif";
gif_delay_time = 0.04;

for i=2:size(tt, 1)
    date = tt.date(i);
    temperature = tt.tmax(i);
    
    % If the temmperature is a nan, skip this iteration of the loop
    if isnan(temperature)
        continue
    end

    temperature_last_month = tt.tmax(i-1);
    daysIntoYear = floor(days(date - datetime(date.Year, 1, 1)));
    angle = daysIntoYear * (2*pi/yeardays(date.Year));

    prev_date = tt.date(i-1);
    prev_daysIntoYear = floor(days(prev_date - datetime(prev_date.Year, 1, 1)));
    prev_angle = prev_daysIntoYear * (2*pi/yeardays(prev_date.Year));
    
    % select monthly average temperature for date's calendar month
    month_avg = monthly_mean(monthly_mean.Month==date.Month, :).Avg_Temp;
    
    if temperature >= month_avg
        linecolor = 'r';
    else
        linecolor = 'b';
    end

    p=polarplot([prev_angle angle], [temperature_last_month temperature], "-", "Color", linecolor, "LineWidth", 1); hold on
    p.Color = [p.Color 1];
    addprop(p, "alpha");
    p.alpha = 1;
    
    for j = 1:size(plotted_lines, 1)
        line_old_alpha = plotted_lines(j).alpha;
        line_new_alpha = line_old_alpha * alpha_reduction_factor;
        plotted_lines(j).Color = [plotted_lines(j).Color line_new_alpha];
        plotted_lines(j).alpha = line_new_alpha;
    end
    plotted_lines = [plotted_lines; p];
    
    ax.ThetaZeroLocation = 'top';
    ax.ThetaDir = 'clockwise';
    ax.ThetaTickLabel = monthNames;
    ax.RLim = [min(tt.tmax) max(tt.tmax)];

    title(string(date.Year));
    
    drawnow

    if write_gif
        frame = getframe(1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
    
        if start_new_image_file
            recycle("on")
            delete(filename)
            imwrite(imind,cm,filename,'gif', 'Loopcount',inf, "DelayTime", gif_delay_time);
            start_new_image_file = false;
        else
            imwrite(imind,cm,filename,'gif','WriteMode','append', "DelayTime", gif_delay_time);
        end
    end

end