function [Ygeo,Xgeo]=RowCol2Proj(geoTrans,row,col)
%% GDAL MEX Utility (v1.0) by Shen,Xinyi
%   contact: Xinyi.Shen@uconn.edu,Feb, 2015
%   (row,col)->(Ygeo,Xgeo) 
%% input parameter:
% geoTrans vector(6) geoTransformation coefficients defined in GDAL rather
% than in matlab
% (row,col): matlab (1,1) based row(s) and column(s) of a pixel(s).
% (Xgeo,Ygeo): geolocation of the CENTER(S) of the given pixels.
%% verification
% according to GDAL (http://www.gdal.org/gdal_datamodel.html), geoTrans is defined as 
% Xgeo = GT(0) + Xpixel*GT(1) + Yline*GT(2)
% Ygeo = GT(3) + Xpixel*GT(4) + Yline*GT(5)
% In case of north up images, 
% the GT(2) and GT(4) coefficients are zero, and the GT(1) is pixel width, and GT(5) is pixel height.
% The (GT(0),GT(3)) position is the top left corner of the top left pixel of the raster.
% Note that the pixel/line coordinates in the above are from (0.0,0.0) at the top left corner of the top left pixel to (width_in_pixels,height_in_pixels) at the bottom right corner of the bottom right pixel. The pixel/line location of the center of the top left pixel would therefore be (0.5,0.5).
% Considering (row,col) system in matlab is (1,1) based,
% Xgeo(Center)=XGeo(1)+0.5*GT(2)+0.5*GT(3)
             %=GT(1) + (col-1)*GT(2)+(row-1)*GT(3)+0.5*GT(2)+0.5*GT(3)
             %=GT(1)+col*GT(2)+row*GT(3)-0.5*[GT(2)+GT3]
% Similarly, Ygeo(Center)=GT(4)+col*GT(5)+row*GT(6)-0.5*[GT(5)+GT(6)]
Xgeo = geoTrans(1) + geoTrans(2) * col + geoTrans(3) * row-(geoTrans(2)+geoTrans(3))/2;  
Ygeo = geoTrans(4) + geoTrans(5) * col + geoTrans(6) * row-(geoTrans(5)+geoTrans(6))/2; 
end