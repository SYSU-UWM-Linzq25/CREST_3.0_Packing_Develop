function [fileStateTXT,fileStateMat]=GenerateFileNames(dirState)
    fileStateTXT=strcat(dirState,'InitialConditions.txt');
    fileStateMat=strcat(dirState,'InitialConditions.mat');
end