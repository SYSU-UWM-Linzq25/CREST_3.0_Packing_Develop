function updateAge(this,new_snow)
increAge=(this.swqTotal>0) & (new_snow==0);
this.last_snow(increAge)=this.last_snow(increAge)+1;
this.last_snow(~increAge)=0;
end