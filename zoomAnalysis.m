% path = 'try1/';
% ext = '';
% start_index = 6;
% end_index = 19;
% r = 7;
% c = 10;
% fs = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n';

% path = '../newpoints/'; start_index = 1; end_index = 10;
% path = '../10x_2/'; start_index = 1; end_index = 9;
% path = '../26x/';start_index = 1;end_index = 14;
% path = '../28_15_28/';start_index = 1;end_index = 12;
% path = '../28_1_14/';start_index = 1;end_index = 13;
% path = '../28_15_28_try2/';start_index = 1;end_index = 14;
 path = '../28x_cover/28x_cover_1_15_try1/';start_index = 2;end_index = 13;
% path = '../28x_SS/28x_ss_1_12/';start_index = 2;end_index = 12;
% path = '../28x_cover_1_15_try2/';start_index = 2;end_index = 13; %ERR??
% path = '../30x_1_30/';start_index = 1;end_index = 30;
% path = '../28x_cover/28x_cover_14_28/';start_index = 1;end_index = 15;
OC=zeros(end_index-start_index,2);
Err=zeros(end_index-start_index,1);
OCcount=0;
ext='.dat';
r=5;c=8;
fs = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n';


for i=start_index:end_index-1
    file1=[path int2str(i) ext];
    file2=[path int2str(i+1) ext];
    OCcount=OCcount+1;
    [OC(OCcount,:),Err(OCcount,1)]=opticalCenter(file1,file2,fs,r,c);
    fprintf('\n[%d] Approx. Point of Intersection : (%f,%f) RMS Error: %f\n',OCcount,OC(OCcount,1),-OC(OCcount,2),Err(OCcount,1));
    %fprintf('%f,%f;',OC(OCcount,1),OC(OCcount,2));
end

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



