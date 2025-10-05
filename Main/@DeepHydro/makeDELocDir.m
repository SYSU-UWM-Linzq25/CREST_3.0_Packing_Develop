function makeDELocDir(resPathInitLoc,pathSplitor)
%% create the folder for the current simulation
dirLocIn=[resPathInitLoc,pathSplitor,'in'];
dirLocOut=[resPathInitLoc,pathSplitor,'out'];
mkdir(resPathInitLoc);
mkdir(dirLocIn);
mkdir(dirLocOut);