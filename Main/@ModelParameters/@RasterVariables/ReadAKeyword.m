function value=ReadAKeyword(gfileID,keyword,commentSymbol)
value=-1;
while value==-1
    tline = fgetl(gfileID);
    if strcmp(tline(1),commentSymbol)==1
        continue;
    end
    strArr = regexp(tline,commentSymbol,'split');
    strContent=strArr{1};
    strValue=regexp(strContent,'=','split');
    strContent=strtrim(strValue{1});
    if strcmpi(strContent, keyword)
        value=strtrim(strValue{2});
        if strcmp('"',value(1)) && strcmp('"',value(end))
            value(1)=[];
            value(end)=[];
        end
    end
end
frewind(gfileID);
end