function OTFType=str2OTFType(strType)
switch strType
    case 'OFTInteger' 	
        OTFType=0;
    case 'OFTIntegerList' 	%List of 32bit integers
        OTFType=1;
    case 'OFTReal' 	% Double Precision floating point
        OTFType=2;
    case 'OFTRealList' 	%List of doubles
        OTFType=3;
    case 'OFTString' 	% String of ASCII chars
        OTFType=4;
    case 'OFTStringList' %Array of strings
        OTFType=5;
    case 'OFTWideString' 	% deprecated
        OTFType=6;
    case 'OFTWideStringList' %deprecated
        OTFType=7;
    case 'OFTBinary' 	% Raw Binary data
        OTFType=8;
    case 'OFTDate' 	% Date
        OTFType=9;
    case 'OFTTime' 	% Time
        OTFType=10;
    case 'OFTDateTime' 	% Date and Time
        OTFType=11;
    otherwise
        OTFType=-1;
        disp('unidentified type')
end
end