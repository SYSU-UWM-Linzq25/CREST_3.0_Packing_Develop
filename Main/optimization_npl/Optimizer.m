classdef Optimizer<handle
    properties
       % n is the number of unknowns 
       % m is the number of maximum allowable parallel runs.
       % m=1 at squential runs
       optX;      % optimal X by optimization
       optF;      % optimal function by optimization
       lBound;    % lower boundary of the unknowns. n-by-1
       uBound;    % upper boundary of the unnnowns. n-by-1
       x0;        % initial guess of the unknowns. n-by-1
       logFile;
    end
    methods
        function obj=Optimizer(logF,lb,ub,xInit)
            obj.logFile=logF;
            obj.lBound=lb;
            obj.uBound=ub;
            if nargin>2
                obj.x0=xInit;
            end
        end
    end
    methods(Abstract)
        optimize(obj);
        LogHead(obj);
    end
end