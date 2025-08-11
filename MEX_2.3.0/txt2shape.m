function txt2shape(fileTxt,fileShp)
%% input 
% fileTxt: the input text file name. The file must be in the unicode mode
% fileShp: the output shape file
%% mainbody
GDALLoad();
[STCD,Name]=xlsread(fileTxt,'soilwater_beijing','A2:B478690');
loc=xlsread(fileTxt,'soilwater_beijing','I2:J478690');
[uSTCD,ic]=unique(STCD);
Name=Name(ic);
lon=loc(ic,2);
lat=loc(ic,1);
mask=~(lon==0 | isnan(lon));
uSTCD=uSTCD(mask);
lon=lon(mask);
lat=lat(mask);
Name=Name(mask);
CreateShape(fileShp,'STCD',str2OTFType('OFTString'),'Name',str2OTFType('OFTString'));
for i=1:length(lat)
    AddAPoint(fileShp,lon(i),lat(i),'STCD',num2str(uSTCD(i)),'Name',Name{i});
end
end