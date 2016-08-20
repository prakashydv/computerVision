%% OPTICAL CENTER Experiments
function OC_chess(impath,start_index,end_index,depth,SF_offset)

    ext = '.dat'; r = 5; c = 8;
    fs = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f \n';
    data = zeros(end_index - start_index + 1, r, c * 2);

    % Read data
    for i = start_index:end_index
        fn = [impath int2str(i) ext];
        f = fopen(fn,'r');
        cc = textscan(f, fs);
        a = cell2mat(cc);
        data(i - start_index + 1, :, :) = a;
        fclose(f);
    end
    % Get expansion lines
    lns = zeros(r * c, 1, 2);

    %% EXTRACT Global Optical Center
    count = 1;
    lim = c * 2;

    figure,hold on,grid on
    for i = 1:r
        for j = 1:2:lim
            points = data(:, i, j:j+1);
            lns(count, :, :) = polyfit(points(:, :, 1), -points(:, :, 2), 1);
            count = count + 1;
            plot3(points(:, :, 1),-points(:, :, 2),50*(1:size(points,1)), 'g-')
        end
    end

    % Plot fitted lines
    
%     figure, plot(points(:, 1, 1), -points(:, 1, 2), 'g'),grid on
%     figure, plot3(points(:, 1, 1),-points(:, 1, 2),50*(1:size(points,1)), 'g'),grid on

    xlim([0, 800]);
    ylim([-800 0]);
   
    for i = 1:count-1
         refline(lns(i, 1, 1), lns(i, 1, 2))
    end

    % Plot Actual Lines
    for i = 1:r
        for j = 1:2:lim
            
            if mod(size(data,1),2)==0
                klim=size(data,1);
            else
                klim=size(data,1)-1;
            end
            for k=1:2:klim

                line([data(k, i, j) data(k+1, i, j) ],-[data(k, i, j+1) data(k+1, i, j+1) ],50*[k k+1]);
                plot3(data(k, i, j),-data(k, i, j+1),50*k,'r.');
                plot3(data(k+1, i, j),-data(k+1, i, j+1),50*(k+1),'g.');
            end
        end
    end
    mx=max(max(max(data)));
    set(gca,'YLim',[-mx mx])

    % Solve the equations
    A = zeros(r * c, 2);
    B = lns(:, :, 2);
    A(:, 2) = 1;
    A(:, 1) = -lns(:, :, 1);
    res = A \ B;

    plot(res(1,1),res(2,1),'r*');
    hold off

    % Error [Root Mean Square]
    maxE=0.0;
    minE=99999.0;
    ERR=double(0.0);
    for i=1:count-1
        % reference: http://math.ucsd.edu/~wgarner/math4c/derivations/distance/distptline.htm
        E=abs(res(2,1)-lns(i,:,1)*res(1,1)-lns(i,:,2))/sqrt(lns(i,:,1)*lns(i,:,1)+1);
        if(minE>E)
            minE=E;
        end
        if(maxE<E)
            maxE=E;
        end
        ERR=ERR+E*E/(count-1);
    end
    ERR=sqrt(ERR);

    fprintf('------------------%s-----------------------',impath);
    fprintf('\nApprox. Point of Intersection : (%f,%f)\n',res(1,1),-res(2,1));
    fprintf('Max Distance : %f\nMin Distance : %f\n',maxE,minE);
    fprintf('RMS Error    : %f\n',ERR);
    fprintf('--------------------------------------------------\n');
    
    globalOC=[res(1);-res(2)];
    save([impath,'globalOC'],'globalOC');
    
    %% Calculate FOV
    lim = c * 2;
    [l,m,n]=size(data);
    imwidth=704; imheight=576;
    width_in_cm=10;
    FOV=zeros(l,2);
    fprintf('\nField of View [FOV]\n');
    for k=1:l
        wpx=mean([data(k,1,lim-1)-data(k,1,1),data(k,r,lim-1)-data(k,r,1)]);
        wpy=mean([data(k,r,2)-data(k,1,2),data(k,r,lim)-data(k,1,lim)]);
        img_width=((c-1)*width_in_cm*imwidth)/wpx;
        img_height=((r-1)*width_in_cm*imheight)/wpy;    
        hfov=2.0*atan(img_width/(2*depth))*180.0/pi;
        vfov=2.0*atan(img_height/(2*depth))*180.0/pi;
        fprintf('[image %d]hfov: %f \tvfov: %f\n',k,hfov,vfov);    
        FOV(k,:)=abs([hfov,vfov]);

    end
    save([impath,'FOV'],'FOV');


    %% Calculate Scaling Ratios
    firstZoom=2;
    horz=zeros(l,1);
    vert=zeros(l,1);
    for k=1:l
        h=zeros(m,1);
        for i=1:m
            h(i,1)=abs(data(k,i,lim-1)-data(k,i,1));
        end
        horz(k,1)=mean(h);
        v=zeros(lim/2,1);
        for j=2:2:lim
            v(j/2,1)= abs(data(k,m,j)-data(k,1,j));
        end
        vert(k,1)=mean(v);
    end
    %dh=horz(2:l,1)./horz(1:l-1,1);
    %dv=vert(2:l,1)./vert(1:l-1,1);
    %ratio=mean([dh,dv])
    %ratio([path,'ratio'],'ratio');

    save([impath,'horz'],'horz');
    save([impath,'vert'],'vert');

    fprintf('\nPair-wise scale ratios [FOV]\n');
    for i=1:l
        for j=i:l
            if i==j
                continue;
            end
            dh=horz(j,1)./horz(i,1);
            dv=vert(j,1)./vert(i,1);
            fprintf('[%2d]-->[%2d]\tratio:%f\n',firstZoom+i-1,firstZoom+j-1,(dv+dh)./2);
        end
    end

    %% Optical Center Experiments and visualisations
    figure
    fprintf('\nConsecutive zoom pair estimated centers analysis:\n');
    zoompairAnalysis(impath,ext,fs,r,c,start_index,end_index);
    fprintf('\nAnalysis of Global Center through images:\n');
    opticalMonitor([-res(2);res(1)],impath,end_index - start_index + 1);

    %fprintf('\nVerifying Optical Centers by predicting via scaling:\n');
    %verifyOC([res(1);-res(2)],data);

    %% Interzoom results
    fprintf('\n[1] inter-zoom search mode \n');
    interzoom_fn(data,[res(1);-res(2)],impath,1,SF_offset);% search mode 
    fprintf('\n[2] inter-zoom globalCenter mode \n');
    interzoom_fn(data,[res(1);-res(2)],impath,2,SF_offset);% global center mode
    fprintf('\n[3] inter-zoom base center mode \n');
    interzoom_fn(data,[res(1);-res(2)],impath,3,SF_offset);% base center mode
    
    
end
