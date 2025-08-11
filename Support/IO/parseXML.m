function theStruct = parseXML(filename)
% PARSEXML Convert XML file to a MATLAB structure.
curFile = mfilename('fullpath');
[curDir,~,~]=fileparts(curFile);
[progDir,~,~]=fileparts(curDir);
addpath([progDir,'/MEX']);

try
   tree = xmlread(filename);
catch
   error('Failed to read XML file %s.',filename);
end

% Recurse over child nodes. This could run into problems 
% with very deeply nested trees.
try
   theStruct = parseChildNodes(tree);
catch ex
   error('Unable to parse XML file %s.',filename);
end

end
% ----- Local function PARSECHILDNODES -----
function [children,childrenType] = parseChildNodes(theNode)
% Recurse over node children.
if theNode.hasChildNodes
   childNodes = theNode.getChildNodes;
   numChildNodes = childNodes.getLength;
   allocCell = cell(1, numChildNodes);
   
   children = struct(             ...
      'Name', allocCell, 'Attributes', allocCell,    ...
      'Data', allocCell, 'Children', allocCell);

    count_ins=1;
    for count = 1:numChildNodes
        theChild = childNodes.item(count-1);
        if ~strcmpi(theChild.getNodeName,'#text') % ensure to add valid nodes
            try
                children(count_ins) = makeStructFromNode(theChild);
                count_ins=count_ins+1;
            catch ex
                disp('ambigous children, skipped');
            end
        end
    end
    children(count_ins:end)=[];
    childrenType='children';
else
    %% make it an attribute
    children = struct('Name', theNode.getNodeName, 'Value',char(theNode.getNodeValue));
    childrenType='attribute';
end
if isempty(children)
    theChild = childNodes.item(0);
    children = strtrim(char(theChild.getNodeValue));
    childrenType='data';
end
end
% ----- Local function MAKESTRUCTFROMNODE -----
function nodeStruct = makeStructFromNode(theNode)
% Create structure of node info.
attrib=parseAttributes(theNode);
[children,childrenType]=parseChildNodes(theNode);
if strcmpi(childrenType,'data') && (~isempty(attrib)) && isempty(attrib.Value)
    childrenType='attribute';
    switch(attrib.Type)
        case 'int'
            attrib.Value=int32(children);
        case 'str'
            polygon=parsePolygon(children);
            if isempty(polygon)
                attrib.Value=char(children);
            else
                attrib.Value=polygon;
            end
        case'date'
            dateFormat='yyyy-mm-ddTHH:MM:SS';
            attrib.Value=datestr(datenum(children,dateFormat));
        otherwise
            attrib.Value=char(children);
    end
    
    children=[];
end
switch(childrenType)
    case 'attribute'
        if (~isempty(children)) && (~isempty(children.Value))
            attrib=[attrib;children];
        end
        nodeStruct = struct(                        ...
           'Name', char(attrib.Name),       ...
           'Attributes', attrib,  ...
           'Data', '',                              ...
            'Children', []);
    case 'data'
        nodeStruct = struct(                        ...
           'Name', char(theNode.getNodeName),       ...
           'Attributes', attrib,  ...
           'Data', children,                              ...
           'Children', []);
    case 'children'
        nodeStruct = struct(                        ...
           'Name', char(theNode.getNodeName),       ...
           'Attributes', attrib,  ...
           'Data', '',                              ...
           'Children', children);
end
% if any(strcmp(methods(theNode), 'getData'))
%    nodeStruct.Data = char(theNode.getData); 
% else
%    nodeStruct.Data = '';
% end
end
% ----- Local function PARSEATTRIBUTES -----
function attributes = parseAttributes(theNode)
% Create attributes structure.

attributes = [];
if theNode.hasAttributes
   theAttributes = theNode.getAttributes;
   numAttributes = theAttributes.getLength;
   allocCell = cell(1, numAttributes);
   attributes = struct('Name', allocCell,'Type', allocCell,'Value', ...
                       allocCell);
   attrib = theAttributes.item(0);
   if numAttributes==1 && strcmpi(attrib.getName,'name')
       attributes.Name = char(attrib.getValue);
       attributes.Value= '';
       attributes.Type=char(theNode.getNodeName);
   else
       for count = 1:numAttributes
          attrib = theAttributes.item(count-1);
          attributes(count).Name = char(attrib.getName);
          attributes(count).Value = char(attrib.getValue);
          attributes(count).Type = char(theNode.getNodeName);
       end
   end
end
end

