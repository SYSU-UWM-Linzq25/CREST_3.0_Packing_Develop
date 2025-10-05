function TestServer(i)
var=i;
c=clock;
pause(60);
dn=datenum(c(1),c(2),c(3),c(4),c(5),c(6));
ds=datestr(dn);
disp(ds);
save(['./var' num2str(i) '.mat'],'var')
end