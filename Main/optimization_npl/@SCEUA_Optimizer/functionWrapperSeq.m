function Fval=functionWrapperSeq(objOpt,varargin)
fh=varargin{1};
objSim=varargin{2};
args=varargin{3};
[NSCE,tElapse]=fh(objSim,args,objOpt.keywordsAct);
Fval=1-NSCE;
obj.LogToFile(NSCE,tElapse,args);
end