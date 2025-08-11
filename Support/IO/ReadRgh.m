function varargout = ReadRgh(file,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
data=xlsread(file);
n=length(varargin);
varargout=cell(n,1);
for i=1:length(varargin)    
    varargout{i}=data(:,varargin{i});
end

end

