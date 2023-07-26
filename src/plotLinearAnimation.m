function plotLinearAnimation(data, NameValueArgs)
% PLOTLINEARANIMATION plots a temperature timeseries as an animated line
% graph of yearly temperatures with one frame per year. Lines are colour
% coded blue-white-red from cooler to hotter temperatures normalised
% against the average temperature in the range 1971-2000 as https://showyourstripes.info/faq
% 
% plotLinearAnimation(data) plots the timeseries in data
% plotLinearAnimation(data, "cityName", "Boston") plots and saves a gif as
% "temperature_linear_plot_Boston.gif"
% plotLinearAnimation(data, "saveGif", false) plots without saving image
% file
% plotLinearAnimation(data, "filename", "example.gif") plots and saves the
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
    NameValueArgs.filename {mustBeText} = "temperature_linear_plot.gif"
end

    data.tmid = (data.tmax(:)+data.tmin(:))/2;
    data = table2timetable(data);
    
    yearly_avg_temp = retime(data, 'yearly', 'mean');
    
    max_temp = max(yearly_avg_temp.tmid);
    min_temp = min(yearly_avg_temp.tmid);
    
    min_year = min(data.date.Year);
    max_year = max(data.date.Year);
    
    monthNames = month(datetime(1, 1:12, 1), 's');
    
    % colour scale is calibrated against the average temperature 1971-2000
    % see https://showyourstripes.info/faq
    averaging_timerange = timerange("1971-01-01","2000-12-31");
    tmid_mean_1971_2000 = mean(data(averaging_timerange, :).tmid);
    threshold = tmid_mean_1971_2000;
    
    % plotting parameters
    grayscale = 1;
    alpha_reduction_factor = 0.90;
    plotted_lines = [];
    
    % Gif writing parameters
    write_gif = NameValueArgs.saveGif;
    start_new_image_file = true;
    gif_delay_time = 0.1;
    if ~strcmp("", NameValueArgs.cityName)
        cityName = char(NameValueArgs.cityName);
        filename = strcat("temperature_linear_plot_",  cityName(~isspace(cityName)),".gif");
    else
        filename = NameValueArgs.filename;
    end
    
    for year=min_year:max_year
        year_data = data(data.date.Year == year, :);
        year_avg_temp = yearly_avg_temp(yearly_avg_temp.date.Year==year, :).tmid;
    
        if year_avg_temp == threshold
            color = grayscale*[1 1 1];
        elseif year_avg_temp > threshold
            color = [1 0 0] + grayscale*[0 1 1]*(1-(year_avg_temp - threshold)/(max_temp - threshold));
        else
            color = [0 0 1] + grayscale*[1 1 0]*(1-(threshold - year_avg_temp)/(threshold - min_temp));
        end
    
        % make all years the same for plotting so they fall in the same axis range, the choice of year here is arbitrary
        year_data.date.Year(:) = max_year;
        p = plot(gca, year_data.date,year_data.tmid, 'Color', color, 'LineWidth',1); hold on
        xtickformat("MM")
        set(gca, 'XTickLabel', monthNames);
        set(gca, 'ylim', [-30 40]);
        set(gca,'color',[0 0 0]);
        ylabel("Temperature (^{\circ}C)")
        if ~exist("year_label", "var")
            year_label = text(10, 35, string(year),'FontSize',14, 'Color', 'w');
        else
            year_label.String = string(year);
        end
    
        p.Color = [p.Color 1];
        % store the alpha (transparency) value in a new property of the line
        % class, this is unused by the plotting, just used for keeping track of
        % line alpha values
        addprop(p, "alpha");
        p.alpha = 1;
        
        for j = 1:size(plotted_lines, 1)
            line_old_alpha = plotted_lines(j).alpha; % get a line's previous alpha
            line_new_alpha = line_old_alpha * alpha_reduction_factor; % calculate its new value of alpha
            plotted_lines(j).Color = [plotted_lines(j).Color line_new_alpha]; % set its alpha value
            plotted_lines(j).alpha = line_new_alpha; % store its alpha value
        end
        plotted_lines = [plotted_lines; p];
    
        drawnow
    
        if write_gif
            frame = getframe(1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
        
            if start_new_image_file
                recycle("on")
                delete(filename)
                imwrite(imind,cm,filename,'gif', 'Loopcount',1, "DelayTime", gif_delay_time);
                start_new_image_file = false;
            else
                imwrite(imind,cm,filename,'gif','WriteMode','append', "DelayTime", gif_delay_time);
            end
        end
    
    end

end