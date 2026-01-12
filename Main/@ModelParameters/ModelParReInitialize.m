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
    varName = this.parSC{i};
    % Judge which mask to use
    if isequal(size(this.(varName)), size(this.tileMask))
        maskName = 'tileMask';
    elseif isequal(size(this.(varName)), size(this.basinMask))
        maskName = 'basinMask';
    else
        error(['[ERROR] Variable ', varName, ' does not match tileMask or basinMask in size.']);
    end

    cmdAmp  = strcat('this.', varName, '(this.', maskName, ') = this.', ...
                     varName, '0(this.', maskName, ') * this.scaleSC(i);');
    cmdAmp2 = strcat('indNan = isnan(this.', varName, ') & this.', maskName, ';');
    cmdAmp3 = strcat('this.', varName, '(indNan) = min(min(this.', varName, '));');
    eval(cmdAmp);
    eval(cmdAmp2);
    eval(cmdAmp3);
end
end