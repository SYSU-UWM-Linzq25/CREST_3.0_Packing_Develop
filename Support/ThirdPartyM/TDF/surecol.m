function c=surecol(data),
%Assures that data is column vector
[m,n]=size(data);
if n>m,
   c=data';
else
   c=data;
end


   