function crestStartMemLogger(logfile, periodSec)
% Starts an OS-level background sampler that records memory usage into CSV.
% Compatible with minimal Linux environments.

    if nargin < 2 || isempty(periodSec)
        periodSec = 5;
    end
    periodSec = max(1, round(periodSec));

    logdir = fileparts(logfile);
    if ~isempty(logdir) && exist(logdir, 'dir') ~= 7
        mkdir(logdir);
    end

    % Write header if file is missing or empty
    needHeader = true;
    if exist(logfile, 'file') == 2
        info = dir(logfile);
        if ~isempty(info) && info.bytes > 0
            needHeader = false;
        end
    end
    fid = fopen(logfile, 'a');
    if fid < 0
        error('crestStartMemLogger: cannot open logfile: %s', logfile);
    end
    if needHeader
        fprintf(fid, 'timestamp,VmRSS_MB,VmHWM_MB,VmSize_MB\n');
    end
    fclose(fid);

    mpid = feature('getpid');
    pidfile = [logfile, '.pid'];

    % Stop previous sampler
    if exist(pidfile, 'file') == 2
        oldpid = str2double(strtrim(fileread(pidfile)));
        if ~isnan(oldpid) && oldpid > 0
            system(sprintf('kill %d >/dev/null 2>&1', oldpid));
        end
        delete(pidfile);
    end

    % Use safe shell-compatible command
    logCmd = sprintf([ ...
        '(while kill -0 %d 2>/dev/null; do ' ...
        'ts=$(date "+%%F %%T"); ' ...
        'vals=$(awk ''BEGIN{rss=0;hwm=0;vms=0} ' ...
            '$1=="VmRSS:"{rss=$2} $1=="VmHWM:"{hwm=$2} $1=="VmSize:"{vms=$2} ' ...
            'END{printf "%%.1f,%%.1f,%%.1f",rss/1024,hwm/1024,vms/1024}'' ' ...
            '/proc/%d/status); ' ...
        'echo "$ts,$vals" >> "%s"; sleep %d; done) ' ...
        '> /dev/null 2>&1 & echo $! > "%s"'], ...
        mpid, mpid, logfile, periodSec, pidfile);

    [rc, msg] = system(logCmd);
    if rc ~= 0
        error('crestStartMemLogger: failed to start sampler: %s', msg);
    end

    % Track pidfile for stop
    try
        key = 'CrestMemLoggerPidFiles';
        lst = {};
        if isappdata(0, key)
            lst = getappdata(0, key);
        end
        if ~iscell(lst), lst = {}; end
        if ~any(strcmp(lst, pidfile))
            lst{end+1} = pidfile; %#ok<AGROW>
        end
        setappdata(0, key, lst);
    catch
    end
end
