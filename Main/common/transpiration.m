function layerTrans=transpiration(dt,transFrac,W,Wcr,Wwp,ice,root,r0c,rarc,RGL,...
                       netShort,netRad,elevation,Tair,VPD,LAI,RaC)
% soil water in (mm) from the top to the penultimate layer
[nCells,nLayers]=size(W);
%% layers 1-nLayer-1 and nLayer are grouped into two conceptual layers
WTop=sum(W(:,1:end-1)-ice(:,1:end-1),2);
WcrTop=sum(Wcr(:,1:end-1),2);
WBtm=W(:,end)-ice(:,end);

%% CASE 1: Moisture in both layers exceeds Wcr, or Moisture in
%    layer with more than half of the roots exceeds Wcr.
%     Potential evapotranspiration not hindered by soil dryness.  If
%     layer with less than half the roots is dryer than Wcr, extra
%     evaporation is taken from the wetter layer.  Otherwise layers
%     contribute to evapotransipration based on root fraction.
% total soil moisture is abundant in the two conceptual layers
smAbd= ((WTop>WcrTop)&(WBtm>=Wcr(:,end))) |... % I feel this condition is covered by the latter two
       ((WTop>=WcrTop)&(1-root(:,end)>=0.5)) |...
       ((WBtm>=Wcr(:,end))&(root(:,end)>=0.5));
nAbd=sum(smAbd);
if nAbd>0
    gsm_inv=ones(nAbd,1);
    rc=calc_rc(r0c(smAbd),RGL(smAbd),netShort(smAbd),Tair(smAbd),VPD(smAbd),LAI(smAbd),gsm_inv,false);
    % total transpiration by Penman Equation
    actTrans=Penman(elevation(smAbd),Tair(smAbd),netRad(smAbd),VPD(smAbd),RaC(smAbd),rc,rarc(smAbd));
    actTrans=actTrans*dt.*transFrac(smAbd);
    W1=W(smAbd,:);
    Wcr1=Wcr(smAbd,:);
    Wwp1=Wwp(smAbd,:);
    root1=root(smAbd,:);
    % actual ratio applied to the actual transpiration due to soil moisture
    % deficit in layers
    gsm_inv1=nan(nAbd,nLayers);
    gsm_inv1(W1>=Wcr1)=1;
    gsm_inv1(W1<Wwp1)=0;
    indexLinear=(W1<=Wcr1)&(W1>=Wwp1);
    gsm_inv1(indexLinear)=(W1(indexLinear) - Wwp1(indexLinear))./(Wcr1(indexLinear) - Wwp1(indexLinear));
    if ~isempty(actTrans)
        actTrans=repmat(actTrans,[1,nLayers]);
    else
        actTrans=zeros(0,nLayers);
    end
    % layered transpiration by Penman equation
    ETPenman=actTrans.*root1;
    % actual layered transpiration due to soil moisture deficit
    layerTrans1=gsm_inv1.*ETPenman;
    % spared transpiration by moisture deficit layers
    spareTrans=sum(ETPenman-layerTrans1,2);
    root1=root1.*(gsm_inv1==1);
    % total root fraction of soil moisture abundant layers
    rootAbd=sum(root1,2);
    rootFrac=root1./repmat(rootAbd,[1,nLayers]);
    % spared transpiration from SM deficit to SM abundant layers
    reallocatedTrans=repmat(spareTrans,[1,nLayers]).*rootFrac;
    % final actual layered transpiration (mm)
    layerTrans1=layerTrans1+reallocatedTrans;
else
    layerTrans1=zeros(0,nLayers);
end
%%  CASE 2: Independent evapotranspirations
%    Evapotranspiration is restricted by low soil moisture. Evaporation
%    is computed independantly from each soil layer.
% total soil moisture is deficit
nDeficit=nCells-nAbd;
smDeficit=~smAbd;
if nDeficit>0
    W2=W(smDeficit,:);
    Wcr2=Wcr(smDeficit,:);
    Wwp2=Wwp(smDeficit,:);
    gsm_inv2=nan(nDeficit,nLayers);
    gsm_inv2(W2>=Wcr2)=1;
    gsm_inv2(W2<Wcr2)=0;
    indexLinear=(W2<Wcr2)&(W2>=Wwp2);
    gsm_inv2(indexLinear)=(W2(indexLinear) - Wwp2(indexLinear))./(Wcr2(indexLinear) - Wwp2(indexLinear));
    hasTrans=gsm_inv2>0;
    elevation2=repmat(elevation(smDeficit),[1,nLayers]);
    Tair2=repmat(Tair(smDeficit),[1,nLayers]);
    VPD2=repmat(VPD(smDeficit),[1,nLayers]);
    LAI2=repmat(LAI(smDeficit),[1,nLayers]);
    RGL2=repmat(RGL(smDeficit),[1,nLayers]);
    netShort2=repmat(netShort(smDeficit),[1,nLayers]);
    r0c2=repmat(r0c(smDeficit),[1,nLayers]);
    RaC2=repmat(RaC(smDeficit),[1,nLayers]);
    rarc2=repmat(rarc(smDeficit),[1,nLayers]);
    netRad2=repmat(netRad(smDeficit),[1,nLayers]);
    rc=nan(nDeficit,nLayers);
    rc(hasTrans)=calc_rc(r0c2(hasTrans),RGL2(hasTrans),netShort2(hasTrans),Tair2(hasTrans),VPD2(hasTrans),LAI2(hasTrans),gsm_inv2(hasTrans),false);
    layerTrans2=zeros(nDeficit,nLayers);
    % no compensation at all
    layerTrans2(hasTrans)=Penman(elevation2(hasTrans),Tair2(hasTrans),netRad2(hasTrans),VPD2(hasTrans),RaC2(hasTrans),rc(hasTrans),rarc2(hasTrans));
    layerTrans2=layerTrans2.*dt.*repmat(transFrac(smDeficit),[1,nLayers]).*root(smDeficit,:);
else
    layerTrans2=zeros(0,nLayers);
end
layerTrans=zeros(nCells,nLayers);
layerTrans(smAbd,:)=layerTrans1;
layerTrans(smDeficit,:)=layerTrans2;
indexOverTranspir=(W-layerTrans)<Wwp;% prevent the transpirated soil moisture below the wilting point
layerTrans(indexOverTranspir)=W(indexOverTranspir)-Wwp(indexOverTranspir);
end