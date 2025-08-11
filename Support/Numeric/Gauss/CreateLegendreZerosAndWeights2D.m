function [XZeros,YZeros,Weights,numOfPointsX,numOfPointsY,xZeros,yZeros]=CreateLegendreZerosAndWeights2D(numOfPointsX,numOfPointsY,lx,ux,ly,uy)
[xZeros,Weightsx]=CreateLegendreZerosAndWeights(numOfPointsX,lx,ux);
[yZeros,Weightsy]=CreateLegendreZerosAndWeights(numOfPointsY,ly,uy);
numOfPointsX=length(xZeros);
numOfPointsY=length(yZeros);
[YZeros,XZeros]=meshgrid(yZeros,xZeros);
[WeightsY,WeightsX]=meshgrid(Weightsy,Weightsx);
Weights=WeightsX.*WeightsY;
XZeros=reshape(XZeros,numOfPointsX*numOfPointsY,1);
YZeros=reshape(YZeros,numOfPointsX*numOfPointsY,1);
Weights=reshape(Weights,numOfPointsX*numOfPointsY,1);
end