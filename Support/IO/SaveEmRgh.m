function SaveEmRgh(file,sheet,solRghA,solRghB,s,Lc)
file=strcat(file,'.xls');
xlswrite(file,[solRghA,solRghB,s,Lc],sheet);
end