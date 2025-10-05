classdef Cover<handle
% object of this class stores parameters for a cover type
    properties (Access=public)
       %% constant attributes
        % Vegetation class identification number
        index;
        iOrder;
        %Flag to indicate whether or not the current vegetation type has an overstory 
            % (TRUE for overstory present [e.g. trees], FALSE for overstory not present [e.g. grass])
        isOverstory;
        isBare;
        % architectural resistance of vegetation type
        rarc;
        % minimum stomatal resistance of vegetation type (~100 s/m)
        rmin;
        % ratio of total tree height that is trunk (no branches). The default value has been 0.2
        trunk_ratio=0.2;
        % minimum incoming shortwave radiation at which there will be transpiration. 
            % For trees this is about 30 W/m^2, for crops about 100 W/m^2.
        RGL;
        % radiation attenuation factor. Normally set to 0.5, though may need to be adjusted for high latitudes.
        rad_atten;
        % wind speed attenuation through the overstory. The default value has been 0.5.
        wind_atten;
        %wind_h, this attribute should be read from forcing. Therefore, it will be removed after the test
        wind_h;
       %% monthly variant properties
        % shortwave albedo
        albedo;
        % vegetation height
        height;
        displacement;
        % vegetation roughness length (typically 0.123 * vegetation height)
        roughness;
        % root depth
        root_depths;
        % root fraction
        root_frac;
    end
    methods(Access=public)
        function this=Cover(index)
            if nargin==1
                this.index=index;
            end
        end
    end
    methods(Static=true)
        covers=ReadVegLib(libPath,nCover);
        order=GetOrder(covers,uc);
    end
end