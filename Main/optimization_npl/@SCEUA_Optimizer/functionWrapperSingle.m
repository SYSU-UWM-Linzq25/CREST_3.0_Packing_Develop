function Fval=functionWrapperSingle(objOpt,fh,objSim,args)
%% make one call within one task
[NSCE,tElapse]=fh(objSim,args,objOpt.keywordsAct);
disp(num2str(NSCE));
Fval=1-NSCE;
objOpt.LogToFile(NSCE,tElapse,args);
end