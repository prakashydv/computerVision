%% from images of single square, obtain scale ratios for zoom

%folder ='../28x_cover/28x_cover_1_28_singleSquare/';numOfImages=28;
folder ='../30x_plain/30x_singleSquare/';numOfImages=30;

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
        
        if(i>2)
            center=[360;290];
        else
            center=[355;285];
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
                   %fprintf('[%d :leeway %d: corner%d] corner coordinates: (%f,%f)\n',i+1,dX,found+1,corners(j,1),corners(j,2))
                   fprintf('\r[%d/%d]',i+1,numOfImages);
                   cornerList(i+1,mod(found+1,4)+1,:)=corners(j,:);
                   found=found+1;
                   %break
               end
            end
            dX=dX+1;dY=dY+1;
% for 30x_plain 11x zoom (i==10), one corner is wrongly detected 
% 1st corner X339
% 1st corner Y305
% 2nd corner X340
% 2nd corner Y263
% 3rd corner X380
% 3rd corner Y263
% 4th corner X379
% 4th corner Y305
            
            if(found>4)%manual select , add override here for specific zooms
                corners
                plot(corners(:,1),corners(:,2),'g.')
                option=input('See image for possible corners, Enter 1 to manually enter points, 2 to select index from given list:');
                if option==2
                    cornerList(i+1,1,:)=corners(input('From the given list, enter index of 1st corner: '),:);
                    cornerList(i+1,2,:)=corners(input('From the given list, enter index of 2st corner: '),:);
                    cornerList(i+1,3,:)=corners(input('From the given list, enter index of 3st corner: '),:);
                    cornerList(i+1,4,:)=corners(input('From the given list, enter index of 4st corner: '),:);
                else
                    cornerList(i+1,1,:)=[input('1st corner X:'),input('1st corner Y:')];
                    cornerList(i+1,2,:)=[input('2nd corner X:'),input('2nd corner Y:')];
                    cornerList(i+1,3,:)=[input('3rd corner X:'),input('3rd corner Y:')];
                    cornerList(i+1,4,:)=[input('4th corner X:'),input('4th corner Y:')];
                end
                found=4;          
            end
            
            if found<4
                found=0;
            elseif found >4
                found=0;
                break
            end
            
        end
        
        % HACK for 28x cover_last image
        %if i==27
        %    cornerList(28,:,:)=corners(5:8,:);
        %    found=4;
        %end
        
        
        
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
    center=[ mean(mean(cornerList(i,:,1))); mean(mean(cornerList(i,:,2))) ];
      
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
    %fprintf('%f : %f\n',mean([length1,length3])/mean([length2,length4]),mean([length1,length2,length3,length4]));
end
%refinedCornerList
plot3(refinedCornerList(:,:,1),refinedCornerList(:,:,2),1:numOfImages,'r*-'),grid on

save('../30x_plain/squareCorners_30x','refinedCornerList');

%% ---------------- Use corners to obtain side lengths
% load('../30x_plain/squareCorners_30x.mat')
imwidth=704; imheight=576;
data=zeros(size(refinedCornerList,1),4,2);
l=0;
for i=1:size(refinedCornerList,1)
    zero=0;
    for j=1:4
        for k=1:2
            if(refinedCornerList(i,j,k)==0)
                zero=1;
                fprintf('skip zoom %d\n',i);
            end
        end
    end
    if zero==0
        l=l+1;
        data(l,:,:)=refinedCornerList(i,:,:);
    end
end

data=refinedCornerList(:,:,:);
l=size(refinedCornerList,1);

lengths=zeros(l,2);
for k=1:l
    lengths(k,1)=mean([data(k,2,1)-data(k,1,1),data(k,3,1)-data(k,4,1)]);
    lengths(k,2)=mean([data(k,4,2)-data(k,1,2),data(k,3,2)-data(k,2,2)]);
end

lengths(:,:)


dh=lengths(2:l,1)./lengths(1:l-1,1);
dv=lengths(2:l,2)./lengths(1:l-1,2);
zoomratio=(dh+dv)./2

firstZoom=1;
for i=1:l-1
    for j=i:l-1
        if i==j
            continue;
        end
        h=lengths(j,1)./lengths(i,1);
        v=lengths(j,2)./lengths(i,2);
        fprintf('[%2d]-->[%2d]\tratio:%f\n',firstZoom+i-1,firstZoom+j-1,(v+h)./2);
    end
end


%% save data
save('../30x_plain/30x_plain_zoomratio','zoomratio');
save('../30x_plain/30x_squareLengths','lengths');
