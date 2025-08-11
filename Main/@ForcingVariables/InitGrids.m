function InitGrids(this)
%             [rows,columns]=size(this.basinMask);
%             [this.col,this.row]=meshgrid(1:columns,1:rows);
%             this.row(~this.basinMask)=NaN;
%             this.col(~this.basinMask)=NaN;
%             this.lat=this.Initialize();
%             this.lon=this.Initialize();
%             [this.lat(this.basinMask),this.lon(this.basinMask)]=RowCol2Proj(this.geoTrans,this.row(this.basinMask),this.col(this.basinMask));
this.prec=this.Initialize();
this.shortwave=this.Initialize();
this.longwave=this.Initialize();
this.Tair=this.Initialize();
this.humidity=this.Initialize();
this.pres=this.Initialize();
this.wind=this.Initialize();
if strcmpi(this.typeWind,'UV')
    this.windU=this.Initialize();
    this.windV=this.Initialize();
end
% this.eAct=this.Initialize();
this.LAI=this.Initialize();
end