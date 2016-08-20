function zoompairAnalysis(impath,ext,fs,r,c,start_index,end_index)
    OCcount=0;
    OC=zeros(end_index-start_index,2);
    Err=zeros(end_index-start_index,1);
    OCpairList=zeros(end_index-start_index,2);
    for i=start_index:end_index-1
        file1=[impath int2str(i) ext];
        file2=[impath int2str(i+1) ext];
        OCcount=OCcount+1;
        [OC(OCcount,:),Err(OCcount,1)]=opticalCenter(file1,file2,fs,r,c);
        fprintf('\n[%d] Approx. Point of Intersection : (%f,%f) RMS Error: %f (%fm) \n',OCcount,OC(OCcount,1),-OC(OCcount,2),Err(OCcount,1),realError(Err(OCcount,1),i,impath));
        %fprintf('%f,%f;',OC(OCcount,1),OC(OCcount,2));
        OCpairList(OCcount,:)=[OC(OCcount,1),-OC(OCcount,2)];


        %% comment to disable visualization
        if i<11
            fname=[impath '00000' int2str(i-1) '.ppm'];
        else
            fname=[impath '0000' int2str(i-1) '.ppm'];
        end
        img=imread(fname);
        [s1,s2,s3]=size(img);
        imshow(img);
        img(floor(-OC(OCcount,2)),:,:)=128*ones(1,s2,s3);
        img(:,floor(OC(OCcount,1)),:)=128*ones(s1,1,s3);
        imshow(img);
        pause();


    end
    save([impath,'OCpairList'],'OCpairList');

    figure,hold on, grid on
    % im=imread('D:\Ubuntu Bacup\pano\newpoints\000006.ppm');
    for i=1:OCcount-1
        line([OC(i,1) OC(i+1,1)],[OC(i,2) OC(i+1,2)]);
        plot(OC(i,1),OC(i,2),'b*');
        plot(OC(i+1,1),OC(i+1,2),'b*');
    %     im(floor(-OC(i,2)),floor(OC(i,1)),:)=255*ones(1,1,3);%[0 floor((i/(OCcount-1))*255) 0];
    %     im(floor(-OC(i+1,2)),floor(OC(i+1,1)),:)=255*ones(1,1,3);
    end
    plot(mean(OC(:,1)),mean(OC(:,2)),'r*'),hold off
    % im(floor(mean(-OC(:,2))),floor(mean(OC(:,1))),:)=[255,0,0];
    % pause();imshow(im);
    fprintf('\n-----------\nMean : (%f,%f) StdDev: %f,%f\n',mean(OC(:,1)),mean(OC(:,2)),sqrt(var(OC(:,1))),sqrt(var(OC(:,2))));




end
