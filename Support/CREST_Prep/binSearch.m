function [N,found]=binSearch(A,b,func,fmt)
Nmax=size(A,1);
Nmin=1;
found=false;
while ~(found || Nmax<=Nmin+1)%binary search
    N=floor((Nmax+Nmin)/2);
    if nargin==3
        funcVal=func(A(N,:));
    else
        funcVal=func(A(N,:),fmt);
    end
    if funcVal==b
        found=true;
    elseif funcVal<b
        Nmin=N;
    elseif funcVal>b
        Nmax=N;
    end
end
if ~found % if the searching date is missing, set the 
    N=Nmin;
end
end