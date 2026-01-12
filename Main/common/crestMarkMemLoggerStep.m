function crestMarkMemLoggerStep(stepName)
% Mark a named step into the memory log file (must be called after crestStartMemLogger)

    if nargin < 1 || isempty(stepName)
        stepName = 'Unknown';
    end

    % 获取当前 logger 使用的 pidfile 列表
    key = 'CrestMemLoggerPidFiles';
    if ~isappdata(0, key)
        warning('No active memory logger found. Did you call crestStartMemLogger()?');
        return;
    end
    lst = getappdata(0, key);
    if ~iscell(lst) || isempty(lst)
        warning('No active memory logger found.');
        return;
    end

    % 默认使用最后一个 logger 的文件（通常只会启动一个）
    pidfile = lst{end};
    logfile = erase(pidfile, '.pid');
    if exist(logfile, 'file') ~= 2
        warning('Log file not found: %s', logfile);
        return;
    end

    % 追加一个注释行作为步骤标记
    fid = fopen(logfile, 'a');
    if fid < 0
        warning('Cannot write to log file: %s', logfile);
        return;
    end
    fprintf(fid, '# STEP: %s [%s]\n', stepName, datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    fclose(fid);
end
