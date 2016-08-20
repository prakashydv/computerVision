function interzoom_fn(data,OCglobal,impath,mode,SFoffset)
    [l,m,n]=size(data);
    windowstart=-10;
    windowend=10;
    Zend=l;
    if mode ~=1 %not search mode
        windowstart=1;
        windowend=1;
    end
    if mode==3 %base center mode
        Zend=l-1;
        load([impath,'OCpairList'])
    end
    allPairCenters=zeros(28,28,2);
    
    load([impath,'horz']);
    load([impath,'vert']);
    
    points=1;
    figure
    for fromZoom=1:Zend
        for toZoom=1:l
            if(fromZoom==toZoom)
                continue;
            end
            
            
            
            
            %fprintf('::verifyRatio:: [%fx-->%fx]:%f\n',fromZoom+SFoffset,toZoom+SFoffset,SF);
           
            minrms=9999;
            maxErr=-1;
            ERR=zeros(m*(n/2),2);ERRcount=0;
            minCenter=OCglobal(:,:);
            ERRcount=ERRcount+1;
            
            dh=(horz(toZoom,1))./(horz(fromZoom,1));
            dv=vert(toZoom,1)./(vert(fromZoom,1));
            SF= mean([dh,dv]);

            for i=windowstart:windowend
                for j=windowstart:windowend

                    Err=zeros(m*(n/2),1);
                    ErrCount=0;
                    if mode==1
                        OC=[OCglobal(1,1)+i;OCglobal(2,1)+j];  %searchOC mode
                    elseif mode ==2
                        OC=OCglobal;                           %globalOC mode
                    else                            %OC as baseZoom OC mode
                        try
                            OC=OCpairList(fromZoom,:)';
                        catch 
                            continue;
                        end

                    end

                    for ii=1:m
                        for jj=1:2:n
                            Ax=data(fromZoom,ii,jj);
                            Ay=data(fromZoom,ii,jj+1);
                            Bx=data(toZoom,ii,jj);
                            By=data(toZoom,ii,jj+1);
                            Px=Ax*(SF)+(1-SF)*OC(1,1);
                            Py=Ay*(SF)+(1-SF)*OC(2,1);
                            ErrCount=ErrCount+1;
                            Err(ErrCount,1)=sqrt((Px-Bx)^2+(Py-By)^2);
                        end
                    end


                   currRMS=rms(Err(1:ErrCount));
%                     currRMS=median(Err(1:ErrCount));
                    if(minrms>currRMS)
                        minrms=currRMS;
                        maxErr=max(Err(1:ErrCount));
                        minCenter=OC;
                        ERR(ERRcount,:)=[median(Err(1:ErrCount)),mean(Err(1:ErrCount))];

                    end
                end
            end
            
            fprintf('[%dx->%dx] mean:%f\tmedian:%f\tminrmsErr:%f\tMaxErr:%f(%fm)\t Center:(%f,%f)\n',fromZoom+SFoffset,toZoom+SFoffset,ERR(ERRcount,2),ERR(ERRcount,1),minrms,maxErr,realError(maxErr,toZoom,impath),minCenter(1,1),minCenter(2,1));
            allPairCenters(fromZoom,toZoom,:)=minCenter';
            
            plot(points,realError(maxErr,toZoom,impath),'r.'),hold on,grid on
            plot(points,realError(ERR(ERRcount,2),toZoom,impath),'g.')
            plot(points,realError(ERR(ERRcount,1),toZoom,impath),'b.')

            points=points+1;
        end
        line([points points],[0 5])
    end
    line([0 points],[2 2])
    hold off
    if mode==1
        save([impath,'allPairCenters'],'allPairCenters')
    end
end