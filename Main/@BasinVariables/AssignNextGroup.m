function AssignNextGroup(obj,doRouting)
%convert the grid resolution to meter
if obj.bGCS
    obj.LenSN=abs(obj.geoTrans(6))*110574.0;
%                 obj.LenSN=abs(obj.geo(1,2))*110574.0;
else
%                 obj.LenSN=abs(obj.geo(1,2));
    obj.LenSN=abs(obj.geoTrans(6));
end
[rows,columns]=size(obj.DEM);
if doRouting
    obj.nextRow=obj.Initialize();
    obj.nextCol=obj.Initialize();
    obj.nextLen=obj.Initialize();
end
obj.gridArea=obj.Initialize();
obj.LenEW=obj.Initialize();
obj.LenCross=obj.Initialize();
obj.lat=obj.Initialize();
r=1:rows;
c=1:columns;
[C,R]=meshgrid(c,r);
R=R(obj.basinMask);
C=C(obj.basinMask);
%calculate the area of each grid
if obj.bGCS
    [obj.lat(obj.basinMask),~]=RowCol2Proj(obj.geoTrans,R,C);
%                 [lat,~] = setltln(obj.DEM, obj.geo, R,C);
    obj.LenEW(obj.basinMask)=obj.LenSN*cosd(obj.lat(obj.basinMask));
else
    %% get the latitude of the grids
    obj.LenEW(obj.basinMask)=abs(obj.geoTrans(2));
end
obj.gridArea(obj.basinMask)=obj.LenSN*obj.LenEW(obj.basinMask)*1e-6; % Convert to km^2
if doRouting
    obj.LenCross(obj.basinMask)=sqrt(obj.LenEW(obj.basinMask).^2+obj.LenSN^2);
    % calculate the 
    dirIndices=2.^(0:7);
    dirR={'R','1+R','1+R','1+R','R','-1+R','-1+R','-1+R'};
    dirC={'1+C','1+C','C','-1+C','-1+C','-1+C',...
        'C','1+C'};
    dirL={'LenEW','LenCross','LenSN','LenCross',...
        'LenEW','LenCross','LenSN','LenCross'};
    fdr=obj.FDR(obj.basinMask);
    nData=length(fdr);
    nr=zeros(nData,1);
    nc=zeros(nData,1);
    nl=zeros(nData,1);
    for i=1:8
        indices=fdr==dirIndices(i);
        cmdR=strcat('nr(indices)=',dirR{i},'(indices);');
        cmdC=strcat('nc(indices)=',dirC{i},'(indices);');
        if isempty(strfind(dirL{i},'LenSN'))
            cmdL=strcat('len=obj.',dirL{i},'(obj.basinMask);',...
                'nl(indices)=len(indices);');
        else
            cmdL=strcat('nl(indices)=obj.',dirL{i},';');
        end
        eval(cmdR);
        eval(cmdC);
        eval(cmdL);
    end
    obj.nextRow(obj.basinMask)=nr;    
    obj.nextCol(obj.basinMask)=nc;
    obj.nextLen(obj.basinMask)=nl;
end
end