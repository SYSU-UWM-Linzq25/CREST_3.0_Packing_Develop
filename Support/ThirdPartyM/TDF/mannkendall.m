function[value2,pvalue2]=mannkendall(datam,s,n);

% This one computes the
% seasonal Mann_kendall test and gives you the MK-test and its p-value
% (two-sided) as result. The input is a vector sorted by time (datam), there
% must be one observation per year and seasons, s stands for the number of
% seasons (e.g. 12 for monthly data) and n is the number of years in the dataset.

re=datam;
resp = reshape(re,s,n);
%resp=re;
p=1*s;
datamat = resp';   % combined data set
for j = 1 : p
   n1(1,j) = 0;
for i = 1 : n                           %Nonmissing observations
       if isnan(datamat(i,j))== 0
         n1(1,j) = n1(1,j) + 1;
       end
   end
end

for g = 1 : p
   for i = 1 : n
       rank(i,g) = n1(g) + 1;
       for j = 1 : n
         if isnan(datamat(i,g))== 0  & isnan(datamat(j,g))== 0
             a = sign(datamat(i,g)-datamat(j,g));
             rank(i,g)= rank(i,g) + a;              % compute rank
         end
       end
       rank(i,g) = rank(i,g)/2;
   end
end

for g = 1 :p
   mannk(g,1) =0;
   for i = 1 :n-1
       for j = i+1 :n
         if isnan(datamat(j,g))== 0 & isnan(datamat(i,g))== 0
             a = sign(datamat(j,g)-datamat(i,g));
         mannk(g,1) = mannk(g,1) + a; % compute Mann-Kendall stat.
         end
       end
   end
end
m = n*(n-1)/2;
for g = 1 : p
   jj = 0;
   for i = 1 :n-1
       for j = i+1 : n
         jj = jj+1;
         if isnan(datamat(i,g)) == 0 & isnan(datamat(j,g)) == 0
         rtemp(jj,g) = sign(datamat(j,g) - datamat(i,g));
      else rtemp(jj,g) = 0;
       end
   end
end
end

for g= 1:p-1
   for h = g+1 :p
       kmatrix(g,h) =0;
       for k1 = 1:m
         kmatrix(g,h) = kmatrix(g,h) + rtemp(k1,g)*rtemp(k1,h);
       end
       kmatrix(h,g) = kmatrix(g,h);
   end
end

for g = 1:p-1
for h = g+1 :p
     a = ( n1(1,g) + 1) * ( n1(1,h) + 1);
     covar(g,h) = kmatrix(g,h) - a * n;    % covariance
     for i = 1:n
         covar(g,h) = covar(g,h) + 4 * rank(i,g) * rank(i,h);
     end
       covar(g,h) = covar(g,h)/3;
       covar(h,g) = covar(g,h);
   end
end
for g= 1 :p
   covar(g,g) = n1(1,g)*(n1(1,g)-1) * (2*n1(1,g)+5)/18;
end
for g = 1 : p
   for j = 1 : n
       vec(j)=datamat(j,g);
   end
   for i = 1 :n-1
       tie = 1;
       for j= i +1 :n
         if isnan(vec(i)) == 0 & vec(j)== vec(i)
             tie = tie + 1;
         end                                    %tie correction
       end
       if tie > 1
         tiecorr = tie * (tie-1)*(2*tie +5);
         covar(g,g) = covar(g,g) - tiecorr / 18;
       end
   end
   end
  
for i = 1:1
   for j= 1 : s
       C(i,j)=1;
   end
end

% Seperate the univariate MK-stats according to expl and resp var
for i = 1 : s
   mannk1(i,1) = mannk(i,1);
end



% Compute seasonal Mann-Kendall-statistic for the resp var
seasmk1 = C*mannk1;

% Seperate Covar according to expl and resp var
for i = 1 : s
   for j = 1 : s
       covar11(i,j) = covar(i,j);
     end
end



% Compute the Variance-Covariance matrix for the resp var
gamma11 = C*covar11*C';

value2 = seasmk1/sqrt(gamma11);
if isreal(value2)
    pvalue2 = normcdf(value2);
else pvalue2=0.5;
end;
value2=real(value2);
%Test statistic
if pvalue2 > 0.5
    pvalue2 = 1-pvalue2;
end
pvalue2=pvalue2*2;