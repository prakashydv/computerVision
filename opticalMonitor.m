function opticalMonitor(center,folder,n)
    figure
    for i=1:n
        if i<11
            fname=[folder '00000' int2str(i-1) '.ppm'];
        else
            fname=[folder '0000' int2str(i-1) '.ppm'];
        end
        img=imread(fname);
        [s1,s2,s3]=size(img);
        imshow(img);
        
        img(floor(center(1,1)),:,:)=zeros(1,s2,s3);
        img(:,floor(center(2,1)),:)=zeros(s1,1,s3);
        
        imshow(img);
%         imwrite(img,[int2str(i) '.jpg']);
        pause();
    end
    
end