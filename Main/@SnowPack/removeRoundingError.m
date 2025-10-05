function removeRoundingError(this,th)
%% remove ignorable snow pack
ignorable=abs(this.swqTotal)<th;
this.swqTotal(ignorable)=0;
this.W(ignorable)=0;
this.WPack(ignorable)=0;
this.CCSurf(ignorable)=0;
this.CCPack(ignorable)=0;
%% remove ignorable surface water
ignorable=abs(this.W)<th;
this.W(ignorable)=0;
%% remove ignorable pack water
ignorable=abs(this.WPack)<th;
this.WPack(ignorable)=0;
%% update the snow status
this.hasSnow=this.swqTotal>0;
end