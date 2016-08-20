 path = '../30x_plain/30x_1_30/';start_index = 1;end_index = 30;
% path = '../28x_cover_1_15_try2/';start_index = 2;end_index = 13;
% path = '../28x_SS/28x_ss_1_12/';start_index = 2;end_index = 12;
% path = '../28x_plain/28_1_14/';start_index = 1;end_index = 13;
% path = '../28x_cover/28x_cover_14_28/';start_index = 1;end_index = 15;
firstZoom=1;

ext = '.dat'; r = 5; c = 8;
fs = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f \n';
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
    vert(k,1)=mean(h);
    %wpx=mean([data(k,1,lim-1)-data(k,1,1),data(k,r,lim-1)-data(k,r,1)]);
    %wpy=mean([data(k,r,2)-data(k,1,2),data(k,r,lim)-data(k,1,lim)]);
    
    %fprintf('%f,',mean([-hfov,-vfov]));
end
dh=horz(2:l,1)./horz(1:l-1,1);
dv=vert(2:l,1)./vert(1:l-1,1);
(dv+dh)./2


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
