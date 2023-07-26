function [temp_c] = convertFahrenheitToCelsius(temp_f)
%FAHRENHEIT_TO_CELSIUS Converts a value in fahrenheit to celsius

% c = convertFahrenheitToCelsius(f) takes the numeric value or numeric
% vector `f` in Fahrenheit and returns `c` in Celsius.

arguments
    temp_f {mustBeNumeric}
end

temp_c = (temp_f - 32) * 5/9;

end

