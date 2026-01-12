function crestStopMemLogger()
% Stop all OS-level memory samplers started by crestStartMemLogger()
% in this MATLAB session (kills PIDs listed in stored pidfiles).

    key = 'CrestMemLoggerPidFiles';
    if isappdata(0, key)
        lst = getappdata(0, key);
    else
        lst = {};
    end
    if ~iscell(lst)
        lst = {};
    end

    for i = 1:numel(lst)
        pidfile = lst{i};
        if exist(pidfile, 'file') == 2
            pid = str2double(strtrim(fileread(pidfile)));
            if ~isnan(pid) && pid > 0
                system(sprintf('kill %d >/dev/null 2>&1', pid));
            end
            delete(pidfile);
        end
    end

    % clear registry
    if isappdata(0, key)
        rmappdata(0, key);
    end
end
