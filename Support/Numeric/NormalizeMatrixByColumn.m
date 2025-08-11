function [M,maxv]=NormalizeMatrixByColumn(M)
%% normalize singular matrix by column before inversion and mulplication
% $M1(M2)^{-1}$
maxv=max(abs(M),[],1);
dom=repmat(maxv,[size(M,1),1]);
M=M./dom;
end