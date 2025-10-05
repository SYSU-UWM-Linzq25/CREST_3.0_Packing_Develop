function makeMosaicLocDir(resPathInitLoc,pathSplitor,nCoresLS)
%% create the folder for the current simulation
dirLocMosaic=[resPathInitLoc,'mosaic'];
dirLocMosaicIn=[dirLocMosaic,pathSplitor,'in'];
dirLocMosaicOut=[dirLocMosaic,pathSplitor,'out'];
mkdir(dirLocMosaic);
mkdir(dirLocMosaicIn);
mkdir(dirLocMosaicOut);
for iCore=1:nCoresLS
    dirLocInI=[dirLocMosaicIn,pathSplitor,num2str(iCore),'_',num2str(nCoresLS)];
    mkdir(dirLocInI);
end