function model_settings()
%% defines some model setting variables that rarely needs to be modified
global prec_adj fileSto
prec_adj=false;% true: use a user supplied function to adjust precipitation
fileSto='d';% 'm' | 'd' | 'H' =montly| daily | houly
end
