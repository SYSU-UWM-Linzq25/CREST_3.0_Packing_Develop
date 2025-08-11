t=clock;
flops(0)
quadval=quad('exp',0,10); % or quadval=quad8(etc.); etc.
fprintf('Value of integral %14.9f\n',quadval);
fprintf('\ntime= %4.2f secs flops=%6.0f\n',etime(clock,t),flops);