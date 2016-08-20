function verifyOC(globalOC,data,SFoffset)

    %% ScaleFactor MAP
    %28x_cover : skip 1.9,1.5
    %SFmap=[ 1.9,1.5,1.3592,1.2637,1.1942,1.1748,1.1460,1.1207,1.1161,1.1094,1.0824,1.0869,1.0798,...
    % 1.0739,1.0590,1.0575,1.0610,1.0607,1.0454,1.0472,1.0436,1.0446,1.0424,1.0331,1.0384,1.0399,1.04];
    
    %28x_cover_using_singleSquare 
    SFmap= [2.1181,1.5689,1.3648,1.2659,1.1953,1.1754,1.1464,1.1210,1.1163,1.1095,1.0825,...
            1.0870,1.0798,1.0739,1.0590,1.0682,1.0505,1.0608,1.0454,1.0472,1.0436,1.0446,1.0424,...
            1.0331,1.0384,1.0399,1.0308];
    
    
    %SFmap=[2,1.4782,1.3200,1.2434,1.1968,1.1580,1.1401,1.1216,1.1134,1.0974,1.0817];%28x_ss_hv_avg
    %SFmap=[2,1.4677,1.3197,1.2437,1.1949,1.1590,1.1398,1.1231,1.1116,1.0984,1.0813];%28x_ss_hfov_only
    %SFmap=[2,1.4887,1.3204,1.2430,1.1987,1.1570,1.1405,1.1201,1.1152,1.0964,1.0820];%28x_ss_vfov_only
    %SFmap=[1.4627,1.3221,1.2420,1.1900,1.1646,1.1380,1.1220,1.1120,1.0984,1.0860,1.0856,1.0742];%28_1_14 avg
    %SFmap=[1.4573,1.3202,1.2412,1.1895,1.1643,1.1378,1.1219,1.1119,1.0983,1.0859,1.0855,1.0741];
    %SFmap=[ 2, 1.4746,1.3188,1.2428,1.1965,1.1578,1.1400,1.1216,1.1134,1.0974,1.0816];
    %SFmap=[2.0,1.5,1.333,1.25,1.2,1.16667,1.14285714286,1.125,1.1111,1.1,1.09091,1.0833,1.07692307692,1.07142857143,1.06666666667,1.0625,1.05882352941,1.05555555556,1.05263157895,1.05,1.04761904762,1.04545454545,1.04347826087,1.041667,1.04,1.03846153846,1.03703703704,1.03571428571,1.03448275862];%ideal
    %SFmap=[2.0,1.5,1.3298,1.2443,1.1923,1.1659,1.1406,1.1230,1.1131,1.0991,1.0877,1.0848,1.0751, 1.0721,1.0636,1.0650,...
    %    1.0557,1.0577,1.0461,1.0509,1.0450,1.0495,1.0444,1.0348,1.0399,1.0448,1.0301];%28xCover from chessboard images
    
    %% OC Map
    % OCmap=[0,0; 351.559594,274.257778;351.130019,273.226412;350.357398,273.356539;351.156062,273.537844;351.925032,272.600425;350.914664,272.780147;351.334316,271.126780;349.758453,270.698379;353.281808,271.536138;346.089920,265.959968;356.776198,273.917984];%size=(12
    
    % OCmap for 28x_cover_1_14   2 to 13
    
    %% Verification
    
    [l,m,n]=size(data);
    minrms_center=globalOC;
    
    for k=1:l-1
        %ErrStats=zeros(100,4);ErrStatCount=0;
        %SF=((SF+1)/SF);%/1.4142;
        SF=SFmap(1,k+SFoffset);
        minrms=1000.0;
        %OC=OCmap(k+SFoffset,:)';
        maxErr=-1;
        for aleph=-10:10
            for beta=-10:10 
                OC=globalOC+[aleph;beta]./1;
                %plot(OC(1,1),OC(2,1),'c*'),hold on,grid on
                points=zeros(2,m,n/2,2);
                Err=zeros(m*(n/2),1);ErrCount=0;
                for i=1:m
                    for j=1:2:n
                        
                        points(1,i,j,:)= data(k,i,j:j+1);
                        points(2,i,j,:)= data(k+1,i,j:j+1);
                        %plot(points(1,i,j,1),points(1,i,j,2),'g*',points(2,i,j,1),points(2,i,j,2),'b*')
                        %line([OC(1,1),points(1,i,j,1)],[OC(2,1),points(1,i,j,2)])
                        %line([OC(1,1),points(2,i,j,1)],[OC(2,1),points(2,i,j,2)])
                        ErrCount=ErrCount+1;
                        Ax=points(1,i,j,1);
                        Bx=points(2,i,j,1);
                        Ay=points(1,i,j,2);
                        By=points(2,i,j,2);
                        Px=Ax*(SF)+(1-SF)*OC(1,1);
                        Py=Ay*(SF)+(1-SF)*OC(2,1);
                        %plot(Px,Py,'r*');
                        Err(ErrCount,1)=sqrt((Px-Bx)^2+(Py-By)^2);
                        %line([Bx,Px],[By,Py])

        %                 sqrt((data(1,1,1)-data(1,1,n-1))^2+(data(1,1,2)-data(1,1,n))^2)
        %                 sqrt((data(1,m,n-1)-data(1,1,n-1))^2+(data(1,m,n)-data(1,1,n))^2)
        %                 sqrt((data(1,m,1)-data(1,m,n-1))^2+(data(1,m,2)-data(1,m,n))^2)
        %                 sqrt((data(1,1,1)-data(1,m,1))^2+(data(1,1,2)-data(1,m,2))^2)
        %                 
        %                 sqrt((data(2,1,1)-data(2,1,n-1))^2+(data(2,1,2)-data(2,1,n))^2)
        %                 sqrt((data(2,m,n-1)-data(2,1,n-1))^2+(data(2,m,n)-data(2,1,n))^2)
        %                 sqrt((data(2,m,1)-data(2,m,n-1))^2+(data(2,m,2)-data(2,m,n))^2)
        %                 sqrt((data(2,1,1)-data(2,m,1))^2+(data(2,1,2)-data(2,m,2))^2)
                        

                    end
                end
                %fprintf('[%d] (%f,%f) \tRMS: %f\tMax: %f\tMin: %f\n',k,OC(1,1),OC(2,1),rms(Err),max(Err),min(Err));
                currRMS=rms(Err);
                %ErrStatCount=ErrStatCount+1;
                %ErrStats(ErrStatCount,:)=[rms(Err),max(Err),min(Err),mean(Err)];
                if(minrms>currRMS)
                    minrms=currRMS;
                    minrms_center=OC;
                    maxErr=max(Err);
                end
                
            end
        end
        fprintf('[%d] minrms: %f\tmaxErr:%f\tcenter:(%f,%f)\n',k+SFoffset,minrms,maxErr,minrms_center(1,1),minrms_center(2,1));
        %fprintf('[%d] maxRMS: %f\tminRMS:%f(center:%f,%f)\tmeanRMS:%f\tstddevRMS:%f\n',k+SFoffset,max(ErrStats(:,1)),min(ErrStats(:,1)),minrms_center(1,1),minrms_center(2,1),mean(ErrStats(:,1)),std(ErrStats(:,1)));
        hold off
        %pause()
    end
end