function plotPolarAnimation(data, NameValueArgs)
% PLOTPOLARANIMATION plots a temperature timeseries as an animated polar line
% graph of yearly temperatures with one frame per year. Lines are colour
% coded blue-white-red from cooler to hotter temperatures normalised
% against the average temperature in the range 1971-2000 as https://showyourstripes.info/faq
% 
% plotPolarAnimation(data) plots the timeseries in data
% plotPolarAnimation(data, "cityName", "Boston") plots and saves a gif as
% "temperature_polar_plot_Boston.gif"
% plotPolarAnimation(data, "saveGif", false) plots without saving image
% file
% plotPolarAnimation(data, "filename", "example.gif") plots and saves the
% image as "example.gif"
% 
% Inputs
% data (table) - table containing a timeseries of temperature data with
% columns: date, tmin, tmax
% 
% Name-Value arguments
% "cityName" - string or char array containing a name of the city the data
% is for
% "saveGif" - logical specifying whether or not to save the gif file.
% "filename" - specify the full file path for the gif to be saved at, if a
% "cityName" is specified, this will be used to set the filename in
% preference over "filename"
% 
% 

arguments
    data table
    NameValueArgs.cityName {mustBeText} = ""
    NameValueArgs.saveGif logical = true
    NameValueArgs.filename {mustBeText} = "temperature_polar_plot.gif"
end

    tt = table2timetable(data);
    tt = retime(tt, 'monthly', 'mean');
    
    ax = polaraxes();
    
    monthNames = month(datetime(1, 1:12, 1), 's');
    
    
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
    months = [1:1:12];
    monthly_mean = table(months', avg_temp', 'VariableNames', ["Month", "Avg_Temp"]);
    
    % Gif writing parameters
    write_gif = NameValueArgs.saveGif;
    start_new_image_file = true;
    gif_delay_time = 0.04;
    if ~strcmp("", NameValueArgs.cityName)
        cityName = char(NameValueArgs.cityName);
        filename = strcat("temperature_polar_plot_",  cityName(~isspace(cityName)),".gif");
    else
        filename = NameValueArgs.filename;
    end
    
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
end