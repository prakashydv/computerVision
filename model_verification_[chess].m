%% OC grid verification
clear all 
clc

%% model and data control variables
% ratiopath='../28x_cover/veri/grid/';
% FOVpath='../28x_cover/veri/grid/';
% OCpath='../28x_cover/veri/singleSquare/';

ratiopath='../28x_SS/28_SS_11_4_try2/';
FOVpath='../28x_SS/veri/28_ss_4_4/';
OCpath='../28x_SS/veri/28_ss_4_4/';

datapath='../28x_SS/28_ss_4_4/';
start_index = 1;end_index = 27; 

Doffset=1;
FOVoffset=0;
OCoffset=0;

%% run


ext = '.dat'; r = 5; c = 8;
fs = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f \n';

data = zeros(end_index - start_index + 1, r, c * 2);

% Read data
for i = start_index:end_index
    fn = [datapath int2str(i) ext];
    f = fopen(fn,'r');
    cc = textscan(f, fs);
    a = cell2mat(cc);
    data(i - start_index + 1, :, :) = a;
    fclose(f);
end

load([OCpath,'allPairCenters'])
load([datapath,'globalOC'])



[k,m,n]=size(data);

z=0;
figure,hold on,grid on
centers=zeros(1,2);centerindex=0;

for fromZoom=1+Doffset:k
    for toZoom=1+Doffset:k
        if (fromZoom==toZoom)
            continue;
        end
               
        z=z+1;
        minrms=99990;maxErr=-1;
        
        %try
            SF=getRatio(fromZoom,toZoom,ratiopath,0);
            fprintf('\nverifyzoom: %fx->%fx:%f \n',fromZoom,toZoom,SF);
            Err=zeros(1,1);ErrCount=0;
            OC=[allPairCenters(fromZoom+OCoffset,toZoom+OCoffset,1); ...
                allPairCenters(fromZoom+OCoffset,toZoom+OCoffset,2)];
            fprintf('verifyCenter: %fx->%fx:(%f,%f)\n',fromZoom,toZoom,OC(1,1),OC(2,1));
        %catch
        %    continue;
        %end
        
        for ii=1:m
            for jj=1:2:n
                Ax=data(fromZoom-Doffset,ii,jj);
                Ay=data(fromZoom-Doffset,ii,jj+1);
                Bx=data(toZoom-Doffset,ii,jj);
                By=data(toZoom-Doffset,ii,jj+1);
                Px=Ax*(SF)+(1-SF)*OC(1,1);
                Py=Ay*(SF)+(1-SF)*OC(2,1);
                ErrCount=ErrCount+1;
                Err(ErrCount,1)=sqrt((Px-Bx)^2+(Py-By)^2);
            end
        end
        
        currRMS=rms(Err(1:ErrCount,1));
        if(currRMS<minrms)
            minrms=currRMS;
            maxErr=max(Err(1:ErrCount,1));
        end
    
        subplot(2,1,1),plot(z,realError(minrms,toZoom+FOVoffset,FOVpath),'b.'),hold on,grid on
        subplot(2,1,1),plot(z,realError(maxErr,toZoom+FOVoffset,FOVpath),'r.'),hold on,grid on
        fprintf('[%d->%d] rmsError:%f MaxErr:%f (%fm)\n',fromZoom,toZoom,minrms,maxErr,realError(maxErr,toZoom+FOVoffset,FOVpath));

        centerindex=centerindex+1;
        centers(centerindex,:)=OC';

    end
    subplot(2,1,1),line([z z],[0 5]);
end
subplot(2,1,1),line([0 z],[2 2])


subplot(2,1,2),plot3(centers(:,1),centers(:,2),1:centerindex,'b*'),hold on,grid on
subplot(2,1,2),plot3(globalOC(1,1),globalOC(2,1),1:centerindex,'r*'),hold on,grid on

fprintf('centers mean:(%f,%f) StdDev:(%f,%f)\n',mean(centers(:,1)),mean(centers(:,2)),std(centers(:,1)),std(centers(:,2)));

hold off
