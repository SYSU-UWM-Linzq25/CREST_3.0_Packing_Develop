function fin=TrimNan(fin,v)
index=find(isnan(fin)==1);
fin(index)=v;
end