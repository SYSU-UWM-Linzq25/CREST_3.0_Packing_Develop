function covers=ReadVegLib(libPath)
 fid=fopen(libPath);
 title=textscan(fid,'%s',53,'Delimiter',',');
 formatSpec='%d %d %d %f %f';% overstory,bare,RArc,rmin
 for i=1:12% albedo
     formatSpec=[formatSpec,' %f'];
 end
 for i=1:12% vegetation roughness
     formatSpec=[formatSpec,' %f'];
 end
 for i=1:12%displacement
     formatSpec=[formatSpec,' %f'];
 end
 formatSpec=[formatSpec,' %d %f %f %f %f %f %f %f %f %f %f %s'];%wind_h,RGL,rad_atten,wind_atten,Trunk Ratio
 raw=textscan(fid,formatSpec,'Delimiter',',');
 nCover=length(raw{1});
 covers(nCover)=Cover(nCover);
%              covers=covers';
 iStartAlbedo=6;
 iStartRgh=iStartAlbedo+12;
 iStartDis=iStartRgh+12;
 alb=[raw{iStartAlbedo:iStartAlbedo+11}];
 rgh=[raw{iStartRgh:iStartRgh+11}];
 dis=[raw{iStartDis:iStartDis+11}];
 for i=1:nCover
    covers(i).iOrder=i;
    covers(i).index=raw{1}(i)';
    covers(i).isOverstory=raw{2}(i)';
    covers(i).isBare=raw{3}(i)';
    covers(i).rarc=raw{4}(i)';
    covers(i).rmin=raw{5}(i)';
    covers(i).albedo=alb(i,:)';
    covers(i).roughness=rgh(i,:)';
    covers(i).displacement=dis(i,:)';
    covers(i).wind_h=raw{iStartDis+12}(i)';
    covers(i).RGL=raw{iStartDis+13}(i)';
    covers(i).rad_atten=raw{iStartDis+14}(i)';
    covers(i).wind_atten=raw{iStartDis+15}(i)';
    covers(i).trunk_ratio=raw{iStartDis+16}(i)';
    covers(i).root_depths(1)=raw{iStartDis+17}(i);
    covers(i).root_depths(2)=raw{iStartDis+19}(i);
    covers(i).root_depths(3)=raw{iStartDis+21}(i);
    covers(i).root_frac(1)=raw{iStartDis+18}(i);
    covers(i).root_frac(2)=raw{iStartDis+20}(i);
    covers(i).root_frac(3)=raw{iStartDis+22}(i);
 end
 fclose(fid);
end