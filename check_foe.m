
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
% path = '../28x_plain/28_focused_1_14/';start_index = 2;end_index = 14;
% path = '../28_focused_15_28/';start_index = 1;end_index = 14;
% path = '../28x_cover/28x_cover_1_15_try1/';start_index = 2;end_index = 13;
% path = '../28x_cover_1_15_try2/';start_index = 2;end_index = 13; %ERR??
% path = '../28x_cover/28x_cover_14_28/';start_index = 1;end_index = 15;
% path = '../28x_SS/28x_ss_1_12/';start_index = 2;end_index = 12;
% path = '../30x_1_30/';start_index = 1;end_index = 30;
% path = '../30x_1_28_28xzoommap/';start_index = 1;end_index = 27; 


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

% Get expansion lines
lns = zeros(r * c, 1, 2);
count = 1;
lim = c * 2;

figure
for i = 1:r
    for j = 1:2:lim
        points = data(:, i, j:j+1);
        lns(count, :, :) = polyfit(points(:, :, 1), -points(:, :, 2), 1);
        count = count + 1;
        plot3(points(:, :, 1),-points(:, :, 2),50*(1:size(points,1)), 'g-'),grid on,hold on
    end
end

% Plot fitted lines
% figure, plot(points(:, 1, 1), -points(:, 1, 2), 'g'),grid on
% figure, plot3(points(:, 1, 1),-points(:, 1, 2),50*(1:size(points,1)), 'g'),grid on
xlim([0, 800]);
ylim([-800 0]);
hold on
for i = 1:count-1
     refline(lns(i, 1, 1), lns(i, 1, 2))
end

% Plot Actual Lines
for i = 1:r
    for j = 1:2:lim
        points = data(:, i, j:j+1);
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

% opticalMonitor([-res(2);res(1)],'../img_28_focused_15_28/',end_index - start_index + 1);
verifyOC([res(1);-res(2)],data,13);%SFoffset=1 as 1 corrsponds to zoom 14x.

fprintf('------------------%s-----------------------',path);
fprintf('\nApprox. Point of Intersection : (%f,%f)\n',res(1,1),-res(2,1));
fprintf('Max Distance : %f\nMin Distance : %f\n',maxE,minE);
fprintf('RMS Error    : %f\n',ERR);
fprintf('--------------------------------------------------\n');




    