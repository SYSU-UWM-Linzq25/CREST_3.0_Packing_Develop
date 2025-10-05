function [mask,Dgrid,outlet_row,outlet_col,user_outlet_row,user_outlet_col,rel_err,new_est_darea] = extractbasin(facc,fdir,row,col,cellsize,facOffset,tolerance,max_radius)
%Function that identify drainage of given location (outlet) from a region
%Version 1.0 - July, 2014
%Written by Humberto Vergara - humber@ou.edu
%Hydrometeorology and Remote-Sensing (HyDROS) Laboratory - http://hydro.ou.edu
%Advanced Radar Research Center (ARRC) - http://arrc.ou.edu
%The University of Oklahoma - http://ou.edu
%
%Input Arguments:
%
%facc - flow accumulation grid
%
%fdir - flow direction grid
%
%outlet - struct variable with fields: longitude and latitude in
%decimal degrees: e.g. outlet.longitude = -80; outlet.latitude = 34;
%
%basin_area - True drainage area of the outlet in sq-km. This is used to
%find out where the outlet should be based on flow accumulation.
%
%mapinfo - Struct variable with projection information. Get this variable
%using "geotiffinfo": e.g. mapinfo = geotiffinfo('bogfdir.tif');
%
%tolerance - Error tolerance in % for the identification of outlet pixel based
%on the true area.
%
%max_radius - Maximum radius to search for outlet pixel in meters.
%% Locate correct outlet from approximate given location
% lon = outlet.longitude;
% lat = outlet.latitude;
basin_area = [];
% if (strcmp(mapinfo.SpatialRef.CoordinateSystemType, 'geographic') == 0)
    %Re-project outlet coordinates
%     [x, y] = projfwd(mapinfo, lat, lon);
%     [row,col] = map2pix(mapinfo.SpatialRef,x,y);
%     cellsize = mapinfo.PixelScale(1);
% else
%     [row, col] = latlon2pix(mapinfo.RefMatrix,lat,lon);
%     cellsize = deg2km(mapinfo.PixelScale(1))*1000;
% end  

%Estimate pixel location from coordinates
new_row = round(row); new_col = round(col);
user_outlet_row = round(row); user_outlet_col = round(col);

%Estimate drainage area of user-provided outlet location
%Use pixel size (assumed in meters for now)
est_darea = (facc(new_row,new_col)-facOffset)*((cellsize/1000)^2);

%Given Drainage Area in km^2
if (isempty(basin_area) == 0)
    darea = basin_area;
    %Compute the relative difference between given drainage area and
    %estimated drainage area to determined if outlet is located correctly
    rel_err = abs((darea - est_darea)/darea)*100;
    new_est_darea = est_darea;
else
    darea = [];
    new_est_darea = est_darea;
    rel_err = 0;
end

radius_distance = 1; %In pixels
while (rel_err > tolerance)
    %Look in vecinity
    search_pixels_rows = user_outlet_row-radius_distance:user_outlet_row+radius_distance;
    search_pixels_cols = user_outlet_col-radius_distance:user_outlet_col+radius_distance;
    %ignore out of bounds pixels
    search_pixels_rows = search_pixels_rows(search_pixels_rows>0);
    search_pixels_cols = search_pixels_cols(search_pixels_cols>0);
    max_row = max(search_pixels_rows);
    max_col = max(search_pixels_cols);
    %Check for mas allowed radius search
    if (radius_distance*(cellsize/1000) > (max_radius/1000) || max_row > size(facc,1) || max_col > size(facc,2))
        %if the maximum radius search is exceeded, force choosing the
        %closest grid and issue a warning.
        fprintf('\n\nWARNING: Could not find an accurate location within allowed domain for outlet at:\nlat: %g lon: %g with known drainage area %g km^2',lat,lon,darea);
        fprintf('\nForcing location at row: %g col: %g with drainage area %g km^2 and %g percent error.\n\n', new_row, new_col, new_est_darea, rel_err);
        break;
    end

    radius_search = facc(search_pixels_rows,search_pixels_cols).*((cellsize/1000)^2);
    radius_search_diff = abs(radius_search - darea);
    [new_i,new_j] = find(radius_search_diff == min(radius_search_diff(:)));
    new_row = (new_i-radius_distance-1) + user_outlet_row; 
    new_col = (new_j-radius_distance-1) + user_outlet_col;
    new_row = new_row(1);
    new_col = new_col(1);
    %Get new drainage area in km2
    new_est_darea = facc(new_row,new_col)*((cellsize/1000)^2);

    %Re-compute relative difference
    rel_err = abs((darea - new_est_darea)/darea)*100;
    %Increase radius of search
    radius_distance = radius_distance + 1;
end

%Set the specified outlet coordinates
outlet_row = new_row;
outlet_col = new_col;
new_est_darea = facc(outlet_row,outlet_col)*((cellsize/1000)^2);
%% Track cells draining to outlet

%Create length grid (meters)
hlen = nan(size(fdir));
hlen(isnan(fdir) == 0) = cellsize*sqrt(2);
hlen(fdir == 1 | fdir == 4 | fdir == 16 | fdir == 64) = cellsize;

% MASK
%Pre-allocate variables
mask = zeros(size(fdir));
Lgrid = nan(size(facc));
Dgrid = nan(size(facc));
drain_group = [];
new_drain_group = [];
new_level_length = [];
level_length = [];

%Include catchment outlet in mask
mask(outlet_row,outlet_col) = 1;

%How many grids need to be accounted for?
n_contributing_cells = facc(outlet_row,outlet_col);

%Flow direction key convention (toward pixel of interest)
%Order here strictly tied to variable "surroundings" defined below
fdircodes = [2, 4, 8, 16, 32, 64, 128, 1];

%Specify the indices of surrounding cells
%The following order of pixels is strictly tied to the flow direction
%convention variable "fdircodes" defined above
surroundings = [new_row-1,new_col-1; %fdir key: 2
                new_row-1,new_col; %fdir key: 4
                new_row-1,new_col+1; %fdir key: 8
                new_row,new_col+1; %fdir key: 16
                new_row+1,new_col+1; %fdir key: 32
                new_row+1,new_col; %fdir key: 64
                new_row+1,new_col-1; %fdir key: 128
                new_row,new_col-1]; %fdir key: 1

%Ignore out of bounds grids
[surr_r] = find(min(surroundings,[],2) > 0 & surroundings(:,1) <= size(fdir,1) & surroundings(:,2) <= size(fdir,2));
surroundings = surroundings(surr_r,:);
fdircodes_surr = fdircodes(surr_r);

%Select only contributing cells from surroundings
%Total of cells accounted for at this point
n_accounted_cells = 0;
cont = 0;
dist_level = 1;
for neig = 1:size(surroundings,1)
    if (fdir(surroundings(neig,1),surroundings(neig,2)) == fdircodes_surr(neig))
        cont = cont + 1;
        n_accounted_cells = n_accounted_cells + 1;
        drain_group(cont,:) = surroundings(neig,:);
        level_length(cont) = hlen(surroundings(neig,1),surroundings(neig,2));
        mask(surroundings(neig,1),surroundings(neig,2)) = 1;
        Lgrid(surroundings(neig,1),surroundings(neig,2)) = dist_level;
        Dgrid(surroundings(neig,1),surroundings(neig,2)) = hlen(surroundings(neig,1),surroundings(neig,2));
    end
end

%Loop through cells until all contributing grids are accounted for
while (n_accounted_cells < n_contributing_cells-facOffset)
    cont = 0;
    %Increase distance level
    dist_level = dist_level + 1;
    for cells = 1:size(drain_group,1)
        new_row = drain_group(cells,1);
        new_col = drain_group(cells,2);
        %Specify the indices of surrounding cells
        %The following order of pixels is strictly tied to the flow direction
        %convention variable "fdircodes" defined above
        surroundings = [new_row-1,new_col-1; %fdir key: 2(2)
                        new_row-1,new_col; %fdir key: 4(1)
                        new_row-1,new_col+1; %fdir key: 8(8)
                        new_row,new_col+1; %fdir key: 16(7)
                        new_row+1,new_col+1; %fdir key: 32(6)
                        new_row+1,new_col; %fdir key: 64(5)
                        new_row+1,new_col-1; %fdir key: 128(4)
                        new_row,new_col-1]; %fdir key: 1(3)

        %Ignore out of bounds grids
        [surr_r] = find(min(surroundings,[],2) > 0 & surroundings(:,1) <= size(fdir,1) & surroundings(:,2) <= size(fdir,2));
        surroundings = surroundings(surr_r,:);
        fdircodes_surr = fdircodes(surr_r);

        %Select only contributing cells from surroundings
        for neig = 1:size(surroundings,1)
            if (fdir(surroundings(neig,1),surroundings(neig,2)) == fdircodes_surr(neig))
                cont = cont + 1;
                n_accounted_cells = n_accounted_cells + 1;
                new_drain_group(cont,:) = surroundings(neig,:);
                mask(surroundings(neig,1),surroundings(neig,2)) = 1;
                Lgrid(surroundings(neig,1),surroundings(neig,2)) = dist_level;
                Dgrid(surroundings(neig,1),surroundings(neig,2)) = hlen(surroundings(neig,1),surroundings(neig,2)) + level_length(cells);
                new_level_length(cont) = Dgrid(surroundings(neig,1),surroundings(neig,2));
            end
        end
    end
    %Update group of outlets
    drain_group = new_drain_group;
    level_length = new_level_length;
    new_drain_group = [];
    new_level_length = [];        
end
end