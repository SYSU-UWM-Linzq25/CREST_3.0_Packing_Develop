function chromosome=genbin(bitl,numchrom)
maxchros=2^bitl;
if numchrom>=maxchros
  numchrom=maxchros;
end
chromosome=round(rand(numchrom,bitl));