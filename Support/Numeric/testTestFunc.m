function v=testTestFunc(func,varargin)
%func=strcat(func,'');
f=str2func(func);
%k=varargin{1};
%k1=varargin{2};
%f=@(x,y)testFunc(x,y,k,k1);
v=f(varargin{:});
end