load('../28x_cover/squareCorners_28x.mat')
depth=1200;% 1070 1210 in cm
imwidth=704; imheight=576;
OBJ_height=15;
OBJ_width=15;

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

FOV=zeros(l,2);
for k=1:l
    wpx=mean([data(k,2,1)-data(k,1,1),data(k,3,1)-data(k,4,1)]);
    wpy=mean([data(k,4,2)-data(k,1,2),data(k,3,2)-data(k,2,2)]);
    fx=depth*wpx/(OBJ_width);
    fy=depth*wpy/(OBJ_height);
    img_width=(OBJ_width*imwidth)/wpx;
    img_height=(OBJ_height*imheight)/wpy;    
    hfov=2.0*atan(img_width/(2*depth))*180.0/pi;
    vfov=2.0*atan(img_height/(2*depth))*180.0/pi;
    fprintf('[zoom %d]hfov: %f \tvfov: %f\n',k,hfov,vfov);    
    FOV(k,:)=[hfov,vfov];
end

FOV(17,:)=(FOV(16,:)+FOV(18,:))./2

dhfov=FOV(1:l-1,1)./FOV(2:l,1)
dvfov=FOV(1:l-1,2)./FOV(2:l,2)
(dhfov+dvfov)./2
plot(1:27,(dhfov+dvfov)./2,'r-',1:27,dhfov,'g-')
pause()

FOVideal=zeros(l,2);
FOVideal(1,:)=FOV(1,:);
for i=2:l
    FOVideal(i,:)=FOV(1,:)/i;
end
%FOVideal
plot(1:k,FOV(:,1),'r-',1:k,FOV(:,2),'b-',1:k,FOVideal(:,1),'r-.',1:k,FOVideal(:,2),'b-.'),grid on
