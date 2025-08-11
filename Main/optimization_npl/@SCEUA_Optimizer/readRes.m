function ixf=readRes(obj,slot)
fileRes=obj.genResName(slot,false);
fid = fopen(fileRes);
A=textscan(fid,'%f');
ixf=A{:};
fclose(fid);
delete(fileRes);
end