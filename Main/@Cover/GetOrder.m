function order=GetOrder(covers,uc)
%% gives the corresponding order from the class index to the cover type.
%% input
% covers: the cover lib that stores the properties of each cover
% uc: the unique class index from the land cover map
%% output
% order: order in the covers of uc
% e.g., uc(1)=4: the first class in uc corresponds to the forth cover type in covers
nClasses=length(uc);
order=zeros(nClasses,1);
for i=1:nClasses
    for coverOrder=1:length(covers)
        if covers(coverOrder).index==uc(i)
            order(i)=coverOrder;
            break;
        end
    end
end
end