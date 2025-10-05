function SaveModelStates(this,strDateCur)
%% Saves model state variables for resuming the routing at the given time
iSS0=this.SS0;
iSI0=this.SI0;
% ipW0=this.W0./WM*100;
% save(strDateCur,'iSS0','iSI0','ipW0');
save(strDateCur,'iSS0','iSI0');
clear iSS0 iSI0 %iW0
disp('Saved status variable for routing.');
end