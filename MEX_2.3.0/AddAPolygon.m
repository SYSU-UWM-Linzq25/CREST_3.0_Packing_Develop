function AddAPolygon(fileName,xLoc,yLoc,varargin)
wktPolygon='POLYGON((';
for i=1:length(xLoc)
    wktPolygon=[wktPolygon,num2str(xLoc(i)),' ',num2str(yLoc(i)),','];
end
wktPolygon=[wktPolygon,num2str(xLoc(1)),' ',num2str(yLoc(1)),'))'];
AddAPolygonFrmWkt(fileName,wktPolygon,varargin{:});
end