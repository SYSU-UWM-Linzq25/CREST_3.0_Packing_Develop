function fileFlushed=landsurf2DE(this)
%% Convert land surface result from geographic grids to DE grids
%% Algorithm Description: 
% Each subbasin pours at an outlet stored in a node object. Due to the
% existence of sinks in the DEM data, the relative elevation to an outlet
% can be negative for any given basin. Therefore, the row dimension can
% accomodates negative value and is still 1-based. 
% For a subbasin without sink, rowEMin=0. 
% For any grid in any basin, 
    %rowEMin=min(elev)/resE (0-based) 
    %rowE=elev/resE-rowEMin+1(1-based) 
% When saved, any rowE<1 is merged to row 1
% When routed to a parent node, rowE<-rowE+rowEMin+elev2O/res
% relative CS: 1-based (rowE, colD)
% absolute CS: (elev,dist) determined (rowE,colD)
dirLoc=[this.globalVar.resPathInitLoc,];
dirLocOut=[dirLoc,'out'];
inProc=false(length(this.nodes),1);% indicate if the computation of a node is finished
for n=1:length(this.nodes)
    if ~isprop(this.nodes(n),'processed')
        this.nodes(n).addprop('processed');
    end
    this.nodes(n).processed=false;
    if isempty(this.nodes(n).children)
        inProc(n)=true;
    end
end
%% regrid from the upstream nodes to the downstream
outletMap=ReadRaster(this.fileOutletMap);%%
[rows,cols]=size(this.excS);
while any(inProc)
    indexNode=find(inProc);
    for n=1:length(indexNode)
        currentNode=this.nodes(indexNode(n));
        rowOut=currentNode.row;
        colOut=currentNode.col;
        indOut=sub2ind([rows,cols],rowOut,colOut);
        maskOut=outletMap==indOut;
        if ~isprop(currentNode,'elev') % the grid configuration is stored in the node for the whole time period
            currentNode.addprop('elev');
            currentNode.addprop('dist');
            currentNode.addprop('rowsE');% the dimension of grids (constant for all time steps)
            currentNode.addprop('colsD');% the dimension of grids (constant for all time steps)
            currentNode.addprop('rowE');% all non-zero grids
            currentNode.addprop('colD');% all non-zero grids
            currentNode.addprop('indDE');% 1d index of all grids
            currentNode.addprop('rowsESave');% the dimension of grids (constant for all time steps)
            currentNode.addprop('colsDSave');% the dimension of grids (constant for all time steps)
            currentNode.addprop('elevMin');% the mininum elevation difference to the outlet (-Inf,0]
            % land surface variables (sparse matrices, dynamic at every time step)
            currentNode.addprop('rowMin');
            currentNode.addprop('excSDE');
            currentNode.addprop('excIDE');
            currentNode.addprop('excSSnowDE');
            currentNode.addprop('excISnowDE');
            
            currentNode.elev=this.elevMap(maskOut);
            currentNode.dist=this.distMap(maskOut);
            currentNode.elevMin=min(currentNode.elev);
            elevMax=max(currentNode.elev);
            distMax=max(currentNode.dist);
            currentNode.rowMin=round(currentNode.elevMin/this.resE);%minimal row number (can be negative)
            % actual dimension 1-based dimension of the DE map
            currentNode.rowsE=this.elev2row(elevMax,false,currentNode.rowMin);
            currentNode.colsD=this.dist2col(distMax,false);
           
            % the maximum row in the absolute DE CS (not 1-based)
            rowMax=currentNode.rowMin+currentNode.rowsE-1;
            for ch=1:length(currentNode.children)
                child=currentNode.children(ch);
                dist2O=this.distMap(child.row,child.col);
                elev2O=this.elevMap(child.row,child.col);
                % the minimal row is converted to the absolute CS of the
                % current node
                rowMinC=child.rowMin+this.diff2Out2grid(elev2O,false);
                currentNode.rowMin=min(currentNode.rowMin,rowMinC);
                colsMaxC=this.diff2Out2grid(dist2O,true)+child.colsD;
                % the maximal row in the absolute CS
                rowMaxC=child.rowsE+rowMinC-1;
                rowMax=max(rowMax,rowMaxC);
                currentNode.colsD=max(currentNode.colsD,colsMaxC);
            end
            currentNode.rowsE=rowMax-currentNode.rowMin+1;
            %% composite the final grids to save in coarser resolution
            % the image dimension(1-based, negative elevation are forced to 0)
            currentNode.rowsESave=this.elev2row(...
                this.row2elev(currentNode.rowsE,currentNode.rowMin),true);
            currentNode.colsDSave=this.dist2col(...
                this.col2dist(currentNode.colsD),true);
            % the (row,col) of all contributing grids in the DE map
            currentNode.rowE=this.elev2row(currentNode.elev,false,currentNode.rowMin);
            currentNode.colD=this.dist2col(currentNode.dist,false);
            currentNode.indDE=sub2ind([currentNode.rowsE,currentNode.colsD],...
            currentNode.rowE,currentNode.colD);
        end
        % sum up the LS result of the same DE temporay grids (high res)
        currentNode.excSDE=accumgrids(currentNode.indDE,this.excS(maskOut),currentNode.rowsE,currentNode.colsD);
        currentNode.excIDE=accumgrids(currentNode.indDE,this.excI(maskOut),currentNode.rowsE,currentNode.colsD);
        currentNode.excSSnowDE=accumgrids(currentNode.indDE,this.snowmeltExcS(maskOut),currentNode.rowsE,currentNode.colsD);
        currentNode.excISnowDE=accumgrids(currentNode.indDE,this.snowmeltExcI(maskOut),currentNode.rowsE,currentNode.colsD);
        %% sum the "LS image" of all tributaries
        for ch=1:length(currentNode.children)
            child=currentNode.children(ch);
            dist2O=this.distMap(child.row,child.col);
            elev2O=this.elevMap(child.row,child.col);
            currentNode.excSDE=currentNode.excSDE+this.offsetAChild(currentNode,child,'excSDE',dist2O,elev2O);
            currentNode.excIDE=currentNode.excIDE+this.offsetAChild(currentNode,child,'excIDE',dist2O,elev2O);
            currentNode.excSSnowDE=currentNode.excSSnowDE+...
                this.offsetAChild(currentNode,child,'excSSnowDE',dist2O,elev2O);
            currentNode.excISnowDE=currentNode.excISnowDE+...
                this.offsetAChild(currentNode,child,'excISnowDE',dist2O,elev2O);
        end
        %% convert from temporal to final resolution to save
        excSDE_Mat=this.fine2coarse(currentNode,currentNode.excSDE);
        if ~isempty(currentNode.parent)
            excSDE_Mat(1,1)=excSDE_Mat(1,1)+this.excS(currentNode.row,currentNode.col);
        end
        
%         WriteMultiBandRaster(fileName,excSDE_Mat,geoTrans,proj,GDTFloat,'GTiff',-9999,4,1,true);
%         clear excSDE_Mat
        excIDE_Mat=this.fine2coarse(currentNode,currentNode.excIDE);
        if ~isempty(currentNode.parent)% for the most downstream points, the outlet is labeled as in basin
            excIDE_Mat(1,1)=excIDE_Mat(1,1)+this.excI(currentNode.row,currentNode.col);
        end
%         WriteMultiBandRaster(fileName,excIDE_Mat,geoTrans,proj,GDTFloat,'GTiff',-9999,4,2,false);
%         clear excIDE_Mat
        excSSnowDE_Mat=this.fine2coarse(currentNode,currentNode.excSSnowDE);
        if ~isempty(currentNode.parent)
           excSSnowDE_Mat(1,1)=excSSnowDE_Mat(1,1)+this.snowmeltExcS(currentNode.row,currentNode.col);
        end
%         WriteMultiBandRaster(fileName,excSSnowDE_Mat,geoTrans,proj,GDTFloat,'GTiff',-9999,4,3,false);
%         clear excSSnowDE_Mat
        excISnowDE_Mat=this.fine2coarse(currentNode,currentNode.excISnowDE);
        if ~isempty(currentNode.parent)
            excISnowDE_Mat(1,1)=excISnowDE_Mat(1,1)+this.snowmeltExcI(currentNode.row,currentNode.col);
        end
        dirLocOutNode=[dirLocOut,this.forcingVar.pathSplitor,currentNode.STCD];
        fileFlushed=this.FlushToRes(dirLocOutNode,{'excS','excI','excSnowS','excSnowI'},...
            {excSDE_Mat,excIDE_Mat,excSSnowDE_Mat,excISnowDE_Mat});
%         WriteMultiBandRaster(fileName,excISnowDE_Mat,geoTrans,proj,GDTFloat,'GTiff',-9999,4,4,false);
        clear excSDE_Mat excIDE_Mat excSSnowDE_Mat excISnowDE_Mat
        currentNode.processed=true;
%         disp(currentNode.STCD);
    end
%     disp('level completed')
    inProc(:)=false;
    for n=1:length(inProc)
        currentNode=this.nodes(n);
        children=currentNode.children;
        if currentNode.processed || isempty(children)
            continue;
        end
        toAdd=true;
        for ch=1:length(children)
            if ~children(ch).processed
                toAdd=false;
                break;
            end
        end
        if toAdd
            inProc(n)=true;
        end
    end
end
end
function LSDE=accumgrids(indDE,LSVal,rows,cols)
LSDE=accumarray(indDE,LSVal,[],@sum,[],true);
[indDE,~,LSDE]=find(LSDE);
[rowE,colD]=ind2sub([rows,cols],indDE);
LSDE=sparse(rowE,colD,LSDE,rows,cols);
end

