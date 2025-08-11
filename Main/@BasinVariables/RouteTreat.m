function [toRowA,toColA,toPerA,toRowB,toColB,toPerB,...
        RPassedRow,RPassedCol,RStartedRow,RStartedCol]=RouteTreat(obj,timeStep,nextTimeX,RSitesRow,RSitesCol)
% A:    the furthest cell water can reach from the current cell within one timestep
% B:    the next cell of A
% PerA: time fraction of 1-PerB
% PerB: time fraction of (dt-t(current to A))/t(A to B)
% RPassedRow,RPassedCol: Runoff evoked from
% (RRstartedRow,RStartedCol) and entirely passed by (RPassedRow,RPassedCol) 
toRowA=obj.Initialize();
toColA=obj.Initialize();
toPerA=obj.Initialize();
toRowB=obj.Initialize();
toColB=obj.Initialize();
toPerB=obj.Initialize();
RPassedRow=[];
RPassedCol=[];
RStartedRow=[];
RStartedCol=[];
siteInd=sub2ind(size(obj.basinMask),RSitesRow,RSitesCol);

[rows,columns]=size(obj.DEM);
[C,R]=meshgrid(1:columns,1:rows);
% initilaize the cell to its start point
toRowB(obj.basinMask)=R(obj.basinMask);
toColB(obj.basinMask)=C(obj.basinMask);
toPerB(obj.basinMask)=0;
index=toPerB<timeStep;
bSetOff=false;
while any(index(:))  
    %extract values from object properties
    rowB=toRowB(index);
    colB=toColB(index);
    perB=toPerB(index);
    rowA=rowB;
    colA=colB;

    % fill the updated value back to A matrices
    toPerA(index)=perB;
    toRowA(index)=rowA;
    toColA(index)=colA;
    % iteration mainbody
    % search for passed by cells [new runoff]
%                 indA=sub2ind([rows,columns],rowA,colA);
    [indA,indexIn]=obj.sub2indInBasin(rowA,colA);
    if bSetOff
        RStart=R(index);
        CStart=C(index);
        Lia=ismember(indA,siteInd);
        RStartedRow=[RStartedRow;RStart(Lia)];
        RStartedCol=[RStartedCol;CStart(Lia)];
        RPassedRow=[RPassedRow;rowA(Lia)];
        RPassedCol=[RPassedCol;colA(Lia)];
    end
    % cells outside of the basin
%                 indexIn=obj.InRectangle(rowA,colA);
%                 indexIn=logical(indexIn.*(obj.basinMask(indA)));
    % set NaN and Inf to cells outside of the basin
    rowB(~indexIn)=NaN;
    colB(~indexIn)=NaN;
    perB(~indexIn)=Inf;
    % move to the next to cells inside of the basin
    rowB(indexIn)=obj.nextRow(indA(indexIn));
    colB(indexIn)=obj.nextCol(indA(indexIn));
    perB(indexIn)=perB(indexIn)+nextTimeX(indA(indexIn));
    % fill value back to the original matrices B matrices
    toRowB(index)=rowB;
    toColB(index)=colB;
    toPerB(index)=perB;
    % eliminate the finished indices
    index(index)=toPerB(index)<timeStep;
    bSetOff=true;
end
toPerB(obj.basinMask)=(timeStep-toPerA(obj.basinMask))./...
    (toPerB(obj.basinMask)-toPerA(obj.basinMask));
toPerA(obj.basinMask)=1-toPerB(obj.basinMask);
end