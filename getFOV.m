% path = '../30x_1_30/';start_index = 1;end_index = 30;depth=1070;%in cm
% path = '../28x_cover_1_15_try1/';start_index = 2;end_index = 13;depth=1200;%in cm
 path = '../28x_ss_1_12/';start_index = 2;end_index = 12;depth=500;%in cm
% path = '../28_1_14/';start_index = 1;end_index = 13;depth=1070;%in cm
% path = '../28x_cover_14_28/';start_index = 1;end_index = 15;depth=1070;%in cm
ext = '.dat'; r = 5; c = 8;
fs = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f \n';

imwidth=704; imheight=576;
width_in_cm=10;

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

lim = c * 2;
[l,m,n]=size(data);
FOV=zeros(l,2);
for k=1:l
    wpx=mean([data(k,1,lim-1)-data(k,1,1),data(k,r,lim-1)-data(k,r,1)]);
    wpy=mean([data(k,r,2)-data(k,1,2),data(k,r,lim)-data(k,1,lim)]);
    fx=depth*wpx/(c*width_in_cm);
    fy=depth*wpy/(r*width_in_cm);
    img_width=(c*width_in_cm*imwidth)/wpx;
    img_height=(r*width_in_cm*imheight)/wpy;    
    hfov=2.0*atan(img_width/(2*depth))*180.0/pi;
    vfov=2.0*atan(img_height/(2*depth))*180.0/pi;
    fprintf('[image %d]hfov: %f \tvfov: %f\n',k,-hfov,-vfov);    
    FOV(k,:)=[-hfov,-vfov];
    %fprintf('%f,',mean([-hfov,-vfov]));
end
dhfov=FOV(1:l-1,1)./FOV(2:l,1);
dvfov=FOV(1:l-1,2)./FOV(2:l,2);
(dhfov+dvfov)./2
% plot(1:11,(dhfov+dvfov)./2,'r-',1:11,dhfov,'g-')
pause()
plot(1:k,FOV(:,1),'r-',1:k,FOV(:,2),'b-'),grid on
