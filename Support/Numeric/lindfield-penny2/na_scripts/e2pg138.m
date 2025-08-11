approx = plotapp('f306',-2,0.1,2);
% Use this approximation use fzero to find exact root
root=fzero('f306',approx(1),0.00005);
fprintf('Exact root is %8.5f\n',root);