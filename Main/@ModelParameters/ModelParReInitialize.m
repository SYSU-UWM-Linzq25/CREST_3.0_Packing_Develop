function ModelParReInitialize(this,x0,calibKeywords)
if  nargin==3%
    %% currently, only the routing task needs calibration
%     this.calibIndices=ones(length(calibKeywords),1);   
    for i=1:length(calibKeywords)
        keyword=calibKeywords{i};
        this.calibIndices(i)=find(strcmp(keyword,this.keywordSC));
    end
    this.scaleSC(this.calibIndices)=x0;
end
for i=1:this.nModelParSC
    cmdAmp=strcat('this.',this.parSC{i},...
        '(this.basinMask)=this.',this.parSC{i},...
        '0(this.basinMask)*this.scaleSC(i);');
    cmdAmp2=['indNan=isnan(this.',this.parSC{i},')&this.basinMask;'];
    cmdAmp3=['this.',this.parSC{i},'(indNan)=min(min(this.',this.parSC{i},'));'];
    eval(cmdAmp);
    eval(cmdAmp2);
    eval(cmdAmp3);
end
end