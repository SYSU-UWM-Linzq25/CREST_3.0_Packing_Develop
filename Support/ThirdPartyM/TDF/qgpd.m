function c=qgpd(q,xi,mu,beta),
%Inverse CDF for GPD
%
%        USAGE:  c=qgpd(p,xi,mu,beta)
%
%            p: Cumulative probability
%xi, mu, beta : Parameters
%            c: Quantile
if nargin==2,
    mu=0;
    beta=1;
end
if nargin ==3,
    beta=1;
end
if nargin <2,
    disp('q and xi inputs should be supplied');
    return
end
c=mu + (beta/xi) * ((1 - q).^( - xi) - 1) ;   
