function SaveEmissivity(dir,band,freq,corlType,inc,varargin)
[file,sheet]=GenType(dir,'em',band,freq,corlType,inc);
n=length(varargin);
nPar=length(varargin{n/2+1});
data=zeros(nPar,n/2);
st=cell(nPar+1,n/2);
st(1,:)=varargin(1:n/2);
for i=n/2+1:n
    data(:,i-n/2)=varargin{i};
end
data=num2cell(data);
st(2:end,:)=data;
xlswrite(strcat(file,'.xlsx'),st,sheet);
end