%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bestx,bestf,BESTX,BESTF] = sceuaMultiTask(this)
% This is the subroutine implementing the SCE algorithm, 
% written by Q.Duan, 9/2004
% modified by X.Shen 5/2014 to implement parallel computation
%% input parameters
% func: function handle or an array of function handles. 
%       the number of func indicates the number of parallel tasks, n performed
%       in this algorithm.It is recommended to be the number of
%       processors (cores) but can be larger.
%       the func must be able to handle multi-set of input arguments when n>1, which
%       means it's a wrapper of the actual function. This wrapper partition
%       the input parameter groups into single ones and calls the actual function using every 
%       set in a non-parallel loop

% LIST OF LOCAL VARIABLES
%    x(.,.) = coordinates of points in the population
%    xf(.) = function values of x(.,.)
%    xx(.) = coordinates of a single point in x
%    cx(.,.) = coordinates of points in a complex
%    cf(.) = function values of cx(.,.)
%    s(.,.) = coordinates of points in the current simplex
%    sf(.) = function values of s(.,.)
%    bestx(.) = best point at current shuffling loop
%    bestf = function value of bestx(.)
%    worstx(.) = worst point at current shuffling loop
%    worstf = function value of worstx(.)
%    xnstd(.) = standard deviation of parameters in the population
%    gnrng = normalized geometri%mean of parameter ranges
%    lcs(.) = indices locating position of s(.,.) in x(.,.)
%    bound(.) = bound on ith variable being optimized
%    ngs1 = number of complexes in current population
%    ngs2 = number of complexes in last population
%    iseed1 = current random seed
%    criter(.) = vector containing the best criterion values of the last
%                10 shuffling loops

% global BESTX BESTF ICALL PX PF
% Initialize SCE parameters:
nopt=length(this.x0);
npg=2*nopt+1;
%test only
% npg=2;
nps=nopt+1;
nspl=npg;
mings=this.nGroup;
npt=npg*this.nGroup;

bound = this.uBound-this.lBound;

% Create an initial population to fill array x(npt,nopt):
rand('seed',this.iseed);
x=repmat(this.lBound,[npt,1])+rand(npt,nopt).*repmat(bound,[npt,1]);

if this.iniflg==1; x(1,:)=this.x0; end

icall=size(x,1);
%% evaulate the initialized solution 
% the x parameters are divided in to n groups where n is the number of func
% get several simulator object copies
%!!!!!
xf=zeros(size(x,1),1);
% dEnd=false;

if exist(this.getProgressFileName(),'file')==2
    [nloop,x,xf,criter]=this.readProg(nopt);
    nTrial=length(xf)*(nloop+1);
else
    criter=[];
    nloop=-1;
    nTrial=0;
end
if nloop<0
    for ix =1:size(x,1)
    %submit ix th simulation on free slot/worker
        [cfreeSlot,resGen]=this.getOneSlot(false);
        disp(this.lsWorkers);
        % retrieve result
        if resGen
            ixf=this.readRes(cfreeSlot);
            % arrange result
            xf(this.lsWorkers(cfreeSlot),:)=ixf;
        end
            % submit
        this.grantPermission(cfreeSlot,ix,x(ix,:));
        disp(this.lsWorkers);
    end
    %finalize initial submition
    for ic=1:this.nParal
        while this.lsWorkers(ic)>0
            % retrieve result
            fileRes=this.genResName(ic,false);
            if exist(fileRes,'file')==2
                ixf=this.readRes(ic);
                xf(this.lsWorkers(ic),:)=ixf;
                this.lsWorkers(ic)=-1;
            end
            pause(0.2);
        end
        
    end
    %!!!!!
    nTrial=npt;
    % xf=[-0.52714,-18.5727,-10.1421,-13.6337,-4.3374,-4.5486,-15.3763,-13.5832];
    f0=xf(1);
    % Sort the population in order of increasing function values;
    [xf,idx]=sort(xf);
    x=x(idx,:);
    this.writeProg(0,x,xf);
    nloop=0;
end


% Record the best and worst points;
bestx=x(1,:); bestf=xf(1);
worstx=x(npt,:); worstf=xf(npt);
BESTF=bestf; BESTX=bestx;

% Compute the standard deviation for each parameter
xnstd=std(x);
% Computes the normalized geometric range of the parameters
gnrng=exp(mean(log((max(x)-min(x))./bound)));
% Check for convergency;
if nTrial >= this.maxn
    disp('*** OPTIMIZATION SEARCH TERMINATED BECAUSE THE LIMIT');
    disp('ON THE MAXIMUM NUMBER OF TRIALS ');
    disp(this.maxn);
    disp('HAS BEEN EXCEEDED.  SEARCH WAS STOPPED AT TRIAL NUMBER:');
    disp(nTrial);
    disp('OF THE INITIAL LOOP!');
end

if gnrng < this.peps
    disp('THE POPULATION HAS CONVERGED TO A PRESPECIFIED SMALL PARAMETER SPACE');
end

% Begin evolution loops:
if nloop<=0
    nloop = 0;
end

criter_change=1e+5;
k1=1:npg;
K2=repmat((k1-1)*this.nGroup,[this.nGroup,1])+repmat((1:this.nGroup)',[1,npg]);

% modified, to copy the object once
while nTrial<this.maxn && gnrng>this.peps && criter_change>this.percento
    this.SCE_UA_Dislay(nloop,nTrial,bestf,bestx,worstf,worstx);
    nloop=nloop+1;
    % Loop on complexes (sub-populations);
    for igs = 1: this.nGroup   
         [cfreeSlot,resGen]=this.getOneSlot(true);
         % retrieve result
         if resGen
             [icf,icx]=this.readEvolveRes(cfreeSlot,nspl);
             % arrange result
             ik2=K2(this.lsWorkers(cfreeSlot),:);
             x(ik2,:) = icx;
             xf(ik2) = icf;
         end
         % submit
         k2=K2(igs,:);
         cx = x(k2,:);
         cf = xf(k2);
         % Evolve sub-population igs for nspl steps:
         %EvolveComplex(obj,nspl,npg,nps,bl,bu,cf,cx)
         this.grantEvolvePermission(nspl,npg,nps,cf,cx,igs,cfreeSlot);
        % End of Loop on Complex Evolution;
    end
    
     %finalize initial submition
     for ic=1:this.nParal
         fileRes=this.genResName(ic,true);
         while this.lsWorkers(ic)>0
             % retrieve result
             if exist (fileRes,'file')==2
                 [icf,icx]=this.readEvolveRes(ic,nspl);
                 % arrange result
                 k2=K2(this.lsWorkers(ic),:);
                 disp(['r=',num2str(size(icx,1)),'c=',num2str(size(icx,2)),'r suppose to be ' size(k2,1) ]);
                 x(k2,:) = icx;
                 xf(k2) = icf;
                 this.lsWorkers(ic)=-1;
             end
             pause(0.2);
        end
    end
                                  
    % Shuffled the complexes;
    [xf,idx] = sort(xf); x=x(idx,:);
    % save the current evolution
    
    PX=x; PF=xf;
    
    % Record the best and worst points;
    bestx=x(1,:); bestf=xf(1);
    worstx=x(npt,:); worstf=xf(npt);
    BESTX=[BESTX;bestx]; BESTF=[BESTF;bestf];
    criter=[criter,bestf];
    this.writeProg(nloop,x,xf,criter);
    % Compute the standard deviation for each parameter
    xnstd=std(x);

    % Computes the normalized geometric range of the parameters
    gnrng=exp(mean(log((max(x)-min(x))./bound)));
    
    this.optX=bestx;this.optF=bestf;
 
    % Check for convergency
    if nTrial >= this.maxn
        disp('*** OPTIMIZATION SEARCH TERMINATED BECAUSE THE LIMIT');
        disp(['ON THE MAXIMUM NUMBER OF TRIALS ' num2str(this.maxn) ' HAS BEEN EXCEEDED!']);
        for ic=1:this.nParal
              this.finalizeEvolve(ic);
        end
    end

    if gnrng < this.peps
        disp('THE POPULATION HAS CONVERGED TO A PRESPECIFIED SMALL PARAMETER SPACE');
        for ic=1:this.nParal
            this.finalizeEvolve(ic);
        end
    else
        disp(strcat('gnrng=',num2str(gnrng)))
    end
    
    if (nloop >= this.kstop)
        criter_change=abs(criter(nloop)-criter(nloop-this.kstop+1));
        criter_change=criter_change/mean(abs(criter(nloop-this.kstop+1:nloop)));
        if criter_change < this.percento
            disp(['THE BEST POINT HAS IMPROVED IN LAST ' num2str(this.kstop) ' LOOPS BY ', ...
                  'LESS THAN THE THRESHOLD ' num2str(this.percento)]);
            disp('CONVERGENCY HAS ACHIEVED BASED ON OBJECTIVE FUNCTION CRITERIA!!!')
            for ic=1:this.nParal
                    this.finalizeEvolve(ic);
            end
        else
            disp(criter)
        end
    end 
    % End of the Outer Loops
end
disp(['SEARCH WAS STOPPED AT TRIAL NUMBER: ' num2str(nTrial)]);
disp(['NORMALIZED GEOMETRIC RANGE = ' num2str(gnrng)]);
disp(['THE BEST POINT HAS IMPROVED IN LAST ' num2str(this.kstop) ' LOOPS BY ', ...
       num2str(criter_change) '%']);

% END of Subroutine sceua
return;