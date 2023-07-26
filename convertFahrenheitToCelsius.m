function [temp_c] = convertFahrenheitToCelsius(temp_f)
%FAHRENHEIT_TO_CELSIUS Converts a value in fahrenheit to celsius

% temp_f can be a numeric value or numeric vector

arguments
    temp_f {mustBeNumeric}
end

temp_c = (temp_f - 32) * 5/9;

end

