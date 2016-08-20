% path = '../28_15_28/';start_index = 1;end_index = 12;
% path = '../28_1_14/';start_index = 1;end_index = 13;
% path = '../28_15_28_try2/';start_index = 1;end_index = 14;
% path = '../28_focused_1_14/';start_index = 2;end_index = 14;
% path = '../28_focused_15_28/';start_index = 1;end_index = 14;
 path = '../28x_cover/28x_cover_1_15_try1/';start_index = 2;end_index = 13;
% path = '../28x_cover_1_15_try2/';start_index = 2;end_index = 13; %ERR??
% path = '../28x_cover_14_28/';start_index = 1;end_index = 15;
% path = '../28x_SS/28x_ss_1_12/';start_index = 2;end_index = 12;
% path = '../30x_1_30/';start_index = 1;end_index = 30;
% path = '../30x_1_28_28xzoommap/';start_index = 1;end_index = 27; 

SFoffset=1;

ext = '.dat'; r = 5; c = 8;
fs = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f \n';

data = zeros(end_index - start_index + 1, r, c * 2);

% Read data
for i = start_index:end_index
    fn = [path int2str(i) ext];
    f = fopen(fn,'r');
    cc = textscan(f, fs);
    a = cell2mat(cc);
    data(i - start_index + 1, :, :) = a;
    fclose(f);
end

%28x_cover : skip 1.9,1.5
%SFmap=[ 1.3592,1.2637,1.1942,1.1748,1.1460,1.1207,1.1161,1.1094,1.0824,1.0869,1.0798,...
 %1.0739,1.0590,1.0575,1.0610,1.0607,1.0454,1.0472,1.0436,1.0446,1.0424,1.0331,1.0384,1.0399,1.04];
 

 % OCmap=[0,0                  ; 351.559594,274.257778;351.130019,273.226412;...
%        350.357398,273.356539;351.156062,273.537844;351.925032,272.600425;...
%        350.914664,272.780147;351.334316,271.126780;349.758453,270.698379;...
%        353.281808,271.536138;346.089920,265.959968;356.776198,273.917984];%size=(12


%OC map of 28x_SS_2_12
%OCmap=[353.407151,276.449850;353.407151,276.449850;353.407151,277.449850;353.407151,276.449850;352.407151,276.449850;...
%    351.407151,276.449850;351.407151,276.449850;350.407151,274.449850;351.407151,277.449850;...
%    353.407151,274.449850;347.407151,275.449850];
%OCglobal=[352.4072;276.4498];

%SFmap=[2,1.4782,1.3200,1.2434,1.1968,1.1580,1.1401,1.1216,1.1134,1.0974,1.0817];%28x_ss_hv_avg
%SFmap=[2,1.4677,1.3197,1.2437,1.1949,1.1590,1.1398,1.1231,1.1116,1.0984,1.0813];%28x_ss_hfov_only
%SFmap=[2,1.4887,1.3204,1.2430,1.1987,1.1570,1.1405,1.1201,1.1152,1.0964,1.0820];%28x_ss_vfov_only
%SFmap=[1.4627,1.3221,1.2420,1.1900,1.1646,1.1380,1.1220,1.1120,1.0984,1.0860,1.0856,1.0742];%28_1_14 avg
%SFmap=[1.4573,1.3202,1.2412,1.1895,1.1643,1.1378,1.1219,1.1119,1.0983,1.0859,1.0855,1.0741];
%SFmap=[ 2, 1.4746,1.3188,1.2428,1.1965,1.1578,1.1400,1.1216,1.1134,1.0974,1.0816];
%SFmap=[2.0,1.5,1.333,1.25,1.2,1.16667,1.14285714286,1.125,1.1111,1.1,1.09091,1.0833,1.07692307692,1.07142857143,1.06666666667,1.0625,1.05882352941,1.05555555556,1.05263157895,1.05,1.04761904762,1.04545454545,1.04347826087,1.041667,1.04,1.03846153846,1.03703703704,1.03571428571,1.03448275862];%ideal
SFmap=[2.0,1.5,1.3298,1.2443,1.1923,1.1659,1.1406,1.1230,1.1131,1.0991,1.0877,1.0848,1.0751, 1.0721,1.0636,1.0650,...
       1.0557,1.0577,1.0461,1.0509,1.0450,1.0495,1.0444,1.0348,1.0399,1.0448,1.0301];%28xCover from chessboard images
globalOC=[350.804600;272.529477];

[l,m,n]=size(data);
deltaZoom=10;%=1 default
heatmap=255*ones(m,n/2);



k=1;%initial zoom
deltaZoom=10;%how far to zoom
SF=4.2;%5.7805;%2-13

ERR;ERRcount=0;
minrms=9999;maxErr=-1;minCenter=OCglobal(:,:);
%OC=OCmap(k+SFoffset,:)';
%SF=SFmap(1,k+SFoffset);
%plot3(OC(1,1),OC(2,1),k,'r*'),hold on,grid on

for i=-10:10
    for j=-10:10
        Err;ErrCount=0;
        OC=[OCglobal(1,1)+i;OCglobal(2,1)+j];
        for ii=1:m
            for jj=1:2:n
                Ax=data(1,ii,jj);
                Ay=data(1,ii,jj+1);
                Bx=data(k+deltaZoom,ii,jj);
                By=data(k+deltaZoom,ii,jj+1);
                Px=Ax*(SF)+(1-SF)*OC(1,1);
                Py=Ay*(SF)+(1-SF)*OC(2,1);
                ErrCount=ErrCount+1;
                Err(ErrCount,1)=sqrt((Px-Bx)^2+(Py-By)^2);
            end
        end
        currRMS=rms(Err(1:ErrCount));
        if(minrms>currRMS)
            minrms=currRMS;
            maxErr=max(Err(1:ErrCount));
            minCenter=OC;
            
        end
    end
end
fprintf('minrmsErr : %f\tMaxErr: %f\t Center: (%f,%f)\n',minrms,maxErr,minCenter(1,1),minCenter(2,1));