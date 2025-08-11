function CalSlopeTiger(obj)
%GM=1.364364;% mean height difference
[rows,columns]=size(obj.DEM);
index=obj.InRectangle(obj.nextRow,obj.nextCol);
index=logical(index.*obj.basinMask);
obj.slope=obj.Initialize();

demNext=obj.Initialize();
demNext(index)=obj.DEM(sub2ind([rows,columns],obj.nextRow(index),obj.nextCol(index)));            
demNext(isnan(demNext))=-9999;
indexValid=logical((obj.DEM>demNext).*obj.basinMask);
indexInvalid=logical((~indexValid).*obj.basinMask);
obj.slope(indexValid)=(obj.DEM(indexValid)-demNext(indexValid))./obj.nextLen(indexValid);
obj.slope(indexInvalid)=obj.GM./obj.nextLen(indexInvalid);
end