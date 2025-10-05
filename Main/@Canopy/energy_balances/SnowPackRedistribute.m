function [albedo,lastSnow,pack_temp,surfCC,packCC] = ...
         SnowPackRedistribute(lastSnow, swq, depth, oldAlbedo, ...
                              isMelting, snowfall)

%% Description
% Computes the cold content (CC) and mass transferring between the surface and pack layer.
% Initializes albedo of the surface and temperature of the pack.

%% update snow age of the surface
hasSnowFall = snowfall > 0;
lastSnow(hasSnowFall) = 0;
lastSnow(~hasSnowFall) = lastSnow(~hasSnowFall) + 1;

%% calculate the albedo of the surface
% Assumes you have: snow.coldcontent, dt properly defined outside
% If not available, this call needs to be fixed accordingly
albedo = snow_albedo(snowfall, swq, depth, ...
                     oldAlbedo, snow.coldcontent, dt, ...
                     lastSnow, isMelting);

% Placeholder for variables that should be calculated in your function
pack_temp = 0;
surfCC = 0;
packCC = 0;

end
