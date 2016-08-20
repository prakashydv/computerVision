folder ='../img_singleCorner/';
numOfImages=28;
dX=7.0;dY=7.0;
center=[350;275];
warning('off','all');
cornerList=zeros(28,2);
for i=0:numOfImages-1
        if i<10
            fname=[folder '00000' int2str(i) '.ppm'];
        else
            fname=[folder '0000' int2str(i) '.ppm'];
        end
        img=rgb2gray(imread(fname));
        [s1,s2]=size(img);
        imshow(img),hold on
        corners = corner(img);%,'QualityLevel',0.02 );%,'FilterCoefficients',fspecial('gaussian',[5 1],1.5));
        plot(center(1,1),center(2,1),'r*')
        m=size(corners,1);
        found=0;
        for j =1:m
           if abs(corners(j,1)-center(1,1))<=dX && abs(corners(j,2)-center(2,1))<=dY
               plot(corners(j,1),corners(j,2),'b*')
               fprintf('[%d] corner coordinates: (%f,%f)\n',i+1,corners(j,1),corners(j,2))
               cornerList(i+1,:)=corners(j,:);
               found=1;
               %break
           end
        end
        if found==0
            fprintf('[%d] corner not found, looking at cropped region for corner !\n',i+1)
            plot(corners(:,1),corners(:,2),'g.')
            pause()
            %img(250:300,325:375)=adapthisteq(img(250:300,325:375));
            corners=corner(img(250:300,325:375));
            m=size(corners,1);
            found=0;
            for j =1:m
               if abs(corners(j,1)+325-center(1,1))<=dX && abs(corners(j,2)+250-center(2,1))<=dY
                   plot(corners(j,1)+325,corners(j,2)+250,'b*')
                   fprintf('[%d] corner found ! coordinates: (%f,%f)\n',i+1,corners(j,1)+325,corners(j,2)+250)
                   cornerList(i+1,:)=[corners(j,1)+325,corners(j,2)+250];
                   found=1;
                   %break
               end
            end
            if found==0
                fprintf('[%d] no corners detected at all !\n',i)
            end
        end
        
            
%       img(floor(center(1,1)),:)=zeros(1,s2);
%       img(:,floor(center(2,1)))=zeros(s1,1);
%       imwrite(img,[int2str(i) '.jpg']);
        hold off
        pause();
        %warning('on','all');
end
cornerList
plot(cornerList(:,1),cornerList(:,2),'r*-'),grid on

