function value=readLine(gfileID,keyword,commentSymbol,type)
value=-1;
while value==-1
    tline = fgetl(gfileID);
    if strcmp(tline(1),commentSymbol)==1
        continue;
    end
    strArr = regexp(tline,commentSymbol,'split');
    strContent=strArr{1};
    strContent=strtrim(strContent);
    if ~isempty(regexpi(strContent, keyword,'ONCE'))
        strValue=regexp(strContent,'=','split');
        switch type
            case 'double'
                value=str2double(strValue{2});
            case 'string'
                value=strrep(strValue{2},'"','');
                value=strtrim(value);
            case 'boolean'
                value=GlobalParameters.yesno2boolean(strtrim(strValue{2}));
        end
    else
        %warning('warning: content disorder');
    end
end
end