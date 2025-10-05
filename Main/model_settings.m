function model_settings(timescale)
%% defines some model setting variables that rarely needs to be modified
global prec_adj fileSto
prec_adj=false;% true: use a user supplied function to adjust precipitation
fileSto='d';% 'm' | 'd' | 'H' =montly| daily | houly

% modify by Linzq25 - Oct 5th,2025
if nargin > 0 && ~isempty(timescale)
    % check if legal input
    valid_scales = {'m','d','H'};
    if ismember(timescale, valid_scales)
        if ~strcmp(fileSto, timescale)
            warning('Input timescale ("%s") overrides default setting ("%s").', timescale, fileSto);
            fileSto = timescale;
        end
    else
        warning('Invalid input timescale "%s". Must be one of: m, d, H. Default ("%s") retained.', timescale, fileSto);
    end
end

end