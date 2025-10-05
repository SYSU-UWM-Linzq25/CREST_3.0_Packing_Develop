function bEvolveEnd=workEvolve(this,simulator,funcHandle)
while true
    if exist(this.fileevPar,'file')==2
        [nspl,npg,nps,bl,bu,cf,cx,keywords]=this.readevpar();
        %delete parameter file
        delete(this.fileevPar);
        %submit the simulation
        [cf,cx]=this.EvolveComplex(nspl,npg,nps,bl,bu,cf,cx,simulator,funcHandle,keywords);
        %write result:cf,cx
        this.outputEvolveres(cf,cx,nspl);
        bEvolveEnd=false;
        break;
    elseif exist(this.fileevExit,'file')==2% exist
        bEvolveEnd=true;
        break;
    end
end
end