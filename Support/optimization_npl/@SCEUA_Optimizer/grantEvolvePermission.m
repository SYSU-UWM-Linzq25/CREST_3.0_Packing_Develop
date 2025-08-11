function  grantEvolvePermission(this,nspl,npg,nps,cf,cx,igs,core)
    filePar=this.genParName(core,true);
           parFileName1=filePar;
          parFileName1(end-2:end)='ifi';

    fid=fopen(parFileName1,'w');
    %% write parameters of simplex and complex
    fprintf(fid,'%8.6f,%8.6f, %8.6f \n',nspl,npg,nps);
    %% write keywords
    fprintf(fid,'%s, ',this.keywordsAct{1:end-1});
    fprintf(fid,'%s\n ',this.keywordsAct{end});
    %% write upper and lower limits of model parameters
    fprintf(fid,'%8.6f, ',this.lBound(1:end-1));
    fprintf(fid,'%8.6f\n',this.lBound(end));
    fprintf(fid,'%8.6f, ',this.uBound(1:end-1));
    fprintf(fid,'%8.6f\n',this.uBound(end));
    %% write function value
    fprintf(fid,'%8.6f, ',cf(1:end-1));
    fprintf(fid,'%8.6f\n',cf(end));
    %% write parameter values
    for i=1:nspl
        fprintf(fid,'%8.6f, ',cx(i,1:end-1));
        fprintf(fid,'%8.6f\n ',cx(i,end));
    end
    fclose(fid);

            movefile(parFileName1,filePar,'f');

    this.lsWorkers(core)=igs;
    disp(['Sub-pop ' num2str(igs) ' is submited to core ' num2str(core)]);
end