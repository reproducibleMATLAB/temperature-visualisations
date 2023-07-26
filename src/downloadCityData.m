function downloadCityData(NameValueArgs)
%DOWNLOADCITYDATA Downloads a data file over HTTP. By default a file from the dataset:
% "Compiled historical daily temperature and precipitation data for
% selected 210 U.S. cities" at https://kilthub.cmu.edu/articles/dataset/Compiled_daily_temperature_and_precipitation_data_for_the_U_S_cities/7890488
% 
% downloadCityData("city", "Boston") downloads the temperature timeseries
% data for Boston from the dataset.
% downloadCityData("city", "Boston", "data_dir", fullfile(pwd, "data"))
% downloads the data to the location fullfile(pwd, "data") (this is also
% the default location)
% downloadCityData("city", "Boston", "city_info_file", "city_info.csv")
% uses the file city_info.csv which relates the city names to their
% download URLS, if this file is not provided, the file is downloaded from
% the dataset first.
% 
% 

arguments
    NameValueArgs.city string {mustBeTextScalar} = "Milton"
    NameValueArgs.data_dir {mustBeFolder} = fullfile(pwd, "data")
    NameValueArgs.city_info_file = fullfile(pwd, "data", "city_info.csv")
    NameValueArgs.timeout {mustBeInteger, mustBePositive} = 30
end

    websave_options = weboptions("Timeout", NameValueArgs.timeout);
    
    
    % First use the Figshare API to get a list of all the files in the dataset.
    import matlab.net.*
    import matlab.net.http.*
    r = RequestMessage;
    uri = URI('https://api.figshare.com/v2/articles/7890488/files');
    resp = send(r,uri);
    
    if resp.StatusCode ~= 200
        error("Figshare API request failed, with status %s: %s", resp.StatusCode, resp.StatusLine.StatusCode)
    end
    
    dataset_info = resp.Body.Data;
    
    if ~isempty(NameValueArgs.city_info_file)
        city_info_table = readtable(NameValueArgs.city_info_file);
    else
        city_info_filename = fullfile(NameValueArgs.data_dir,'city_info.csv');
        websave(city_info_filename, "https://ndownloader.figshare.com/files/32874371", websave_options);
        city_info_table = readtable(city_info_filename);
    end
    
    
    % Get the elements of the city info table which correspond to the city of interest
    city_info = city_info_table(strcmpi(city_info_table.Name, NameValueArgs.city), :);
    
    if size(city_info, 1) < 1
        error("City ""%s"" not found in dataset", NameValueArgs.city)
    end
    
    local_file_path = fullfile(NameValueArgs.data_dir, strcat(NameValueArgs.city, ".csv"));
        
    city_dataset = dataset_info(strcmpi({dataset_info.name}, strcat(city_info.ID(1), ".csv")));
        
    fprintf("Downloading %s to %s\n", city_dataset.name, local_file_path);
    
    websave(local_file_path, city_dataset.download_url, websave_options);


end

