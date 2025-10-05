function CalSlope(obj,mode,rowOutlet,colOutlet)
obj.rowOutlet=rowOutlet;
obj.colOutlet=colOutlet;
obj.indexOutlet=sub2ind(size(obj.basinMask),obj.rowOutlet,obj.colOutlet);
[rows,columns]=size(obj.DEM);
index=obj.InRectangle(obj.nextRow,obj.nextCol);
index=logical(index.*obj.basinMask);

obj.slope=obj.Initialize();
demNext=obj.Initialize();
demNext(index)=obj.DEM(sub2ind([rows,columns],obj.nextRow(index),obj.nextCol(index)));
demNext(~index)=NaN;
indexValid=obj.DEM>demNext;
indexInvalid=logical((~indexValid).*obj.basinMask);

% calculate the slope in the normal definition by normal data
obj.slope(indexValid)=(obj.DEM(indexValid)-demNext(indexValid))./obj.nextLen(indexValid);

% calcualte the slope in an average meaning by abnormal data
%             obj.slope(indexInvalid)=obj.CalSlopeNoData(indexInvalid);
% use a general average in invalid area
obj.slope(indexInvalid)=obj.GM./obj.nextLen(indexInvalid);
switch mode
    case 'mean'
        obj.slope(obj.indexOutlet)=obj.GM./obj.nextLen(obj.indexOutlet);
    case 'real'
        obj.slope(obj.indexOutlet)=(obj.DEM(obj.indexOutlet)-obj.heightNextToOutlet)/obj.nextLen(obj.indexOutlet);
end
obj.slope(obj.slope<0)=-obj.slope(obj.slope<0);
obj.slope(abs(obj.slope)<1e-6)=1e-6;
end