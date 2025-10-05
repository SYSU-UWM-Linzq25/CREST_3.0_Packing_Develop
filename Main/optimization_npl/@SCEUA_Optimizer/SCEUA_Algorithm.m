classdef SCEUA_Algorithm<handle
    methods(Static=true)
        [cf,cx,nCalls]=EvolveComplex(nspl,npg,nps,bl,bu,cf,cx,funcW,funcAct,optObj,simObj);
        [snew,fnew,nCalls]=cceua(s,sf,bl,bu,funcWrap,funcAct,optObj,simObj);
    end
end