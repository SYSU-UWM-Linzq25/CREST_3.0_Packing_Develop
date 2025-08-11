function CalNextTime(obj,coeM,expM,coeR,coeS,hasRiverInterflow)
speedVegLocalNext=0.5;
%calculate the runoff speed in overland
speed=obj.Initialize();
obj.nextTimeS=obj.Initialize();
speed(obj.basinMask)=coeM(obj.basinMask)*speedVegLocalNext.*obj.slope(obj.basinMask).^expM(obj.basinMask);
speed(obj.stream)=speed(obj.stream).*coeR(obj.stream);
obj.nextTimeS(obj.basinMask)=obj.nextLen(obj.basinMask)./speed(obj.basinMask)/3600*obj.rTimeUnit;%Unit=meter/second?
obj.nextTimeI=obj.Initialize();
obj.nextTimeI(obj.basinMask)=obj.nextTimeS(obj.basinMask)./coeS(obj.basinMask);
if ~hasRiverInterflow
    obj.nextTimeI(obj.stream)=obj.nextTimeS(obj.stream);
end
end