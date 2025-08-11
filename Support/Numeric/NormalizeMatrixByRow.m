function [M,maxv]=NormalizeMatrixByRow(M)
%% normalize singular matrix before inversion and mulplication
% $(M1)^{-1}M2$
maxv=max(abs(M),[],2);
denom1=repmat(maxv,[1,size(M,2)]);
M=M./denom1;
end