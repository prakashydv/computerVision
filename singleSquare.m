%folder ='../28x_cover/28x_cover_FOV_img/';numOfImages=28;
folder ='../28x_cover/28x_cover_1_28_singleSquare/';numOfImages=28;
%folder ='../30x_plain/30x_singleSquare/';numOfImages=30;
dX=2.0;dY=2.0;

warning('off','all');
cornerList=zeros(numOfImages,4,2);
for i=0:numOfImages-1
        if i<10
            fname=[folder '00000' int2str(i) '.ppm'];
        else
            fname=[folder '0000' int2str(i) '.ppm'];
        end
        img=rgb2gray(imread(fname));
        [s1,s2]=size(img);
        %center=[s2/2;s1/2];
        
        if(i>=2)
            center=[355;280];
        else
            center=[350;280];
        end

        
        imshow(img),hold on
        corners = corner(img);%,'QualityLevel',0.02 );%,'FilterCoefficients',fspecial('gaussian',[5 1],1.5));
        plot(center(1,1),center(2,1),'r*')
        m=size(corners,1);
              
        found=0;
        while dX<275 && found~=4
            for j =1:m
               if abs(corners(j,1)-center(1,1))<=dX && abs(corners(j,2)-center(2,1))<=dY
                   plot(corners(j,1),corners(j,2),'b*')
                   fprintf('[%d :leeway %d: corner%d] corner coordinates: (%f,%f)\n',i+1,dX,found+1,corners(j,1),corners(j,2))
                   cornerList(i+1,mod(found+1,4)+1,:)=corners(j,:);
                   found=found+1;
                   %break
               end
            end
            dX=dX+1;dY=dY+1;
            if found<4
                found=0;
            elseif found >4
                found=0;
                break
            end
            
        end
        if(found==0)
            plot(corners(:,1),corners(:,2),'g.')
        elseif(found==4)
            plot(cornerList(i+1,:,1),cornerList(i+1,:,2),'c.')
        end

            
%       img(floor(center(1,1)),:)=zeros(1,s2);
%       img(:,floor(center(2,1)))=zeros(s1,1);
%       imwrite(img,[int2str(i) '.jpg']);
        hold off
        pause();
        %warning('on','all');
end
%cornerList
%plot(cornerList(:,1,1),cornerList(:,1,2),'r*-'),grid on

refinedCornerList=zeros(numOfImages,4,2);
% order: clockwise, beginning top left
for i=1:numOfImages
    if(i>=2)
        center=[355;280];
    else
        center=[350;2];
    end
    for j=1:4
        if(cornerList(i,j,1)<center(1,1) && cornerList(i,j,2)<center(2,1))
            refinedCornerList(i,1,:)=cornerList(i,j,:);
        elseif(cornerList(i,j,1)>center(1,1) && cornerList(i,j,2)<center(2,1))
            refinedCornerList(i,2,:)=cornerList(i,j,:);
        elseif(cornerList(i,j,1)>center(1,1) && cornerList(i,j,2)>center(2,1))
            refinedCornerList(i,3,:)=cornerList(i,j,:);
        elseif(cornerList(i,j,1)<center(1,1) && cornerList(i,j,2)>center(2,1))
            refinedCornerList(i,4,:)=cornerList(i,j,:);
        end
        
    end
    length1=sqrt((refinedCornerList(i,1,1)-refinedCornerList(i,2,1))^2 + (refinedCornerList(i,1,2)-refinedCornerList(i,2,2))^2) ;
    length2=sqrt((refinedCornerList(i,3,1)-refinedCornerList(i,2,1))^2 + (refinedCornerList(i,3,2)-refinedCornerList(i,2,2))^2 );
    length3=sqrt((refinedCornerList(i,3,1)-refinedCornerList(i,4,1))^2 + (refinedCornerList(i,3,2)-refinedCornerList(i,4,2))^2 );
    length4=sqrt((refinedCornerList(i,1,1)-refinedCornerList(i,4,1))^2 + (refinedCornerList(i,1,2)-refinedCornerList(i,4,2))^2 );
    fprintf('%f : %f\n',mean([length1,length3])/mean([length2,length4]),mean([length1,length2,length3,length4]));
end
%refinedCornerList
plot3(refinedCornerList(:,:,1),refinedCornerList(:,:,2),1:numOfImages,'r*-'),grid on
save('squareCorners_28x','refinedCornerList');
