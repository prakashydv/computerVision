%Copyright 2006 Bob L. Sturm
%http://www.ece.ucsb.edu/courses/ECE158/158_F10Gibson/158LAB6.pdf

M = 8; N = 8;
n = [0:N-1];
m = [0:M-1];
for k=0:M-1
 for l=0:N-1
 basis(k*M+1:(k+1)*M, l*N+1:(l+1)*N) = ...
 repmat(cos((2*m+1)*k*pi/(2*M))',1,N).* ...
 repmat(cos((2*n+1)*l*pi/(2*M)),M,1);
 if k==0
 basis(k*M+1:(k+1)*M, l*N+1:(l+1)*N) = ...
 basis(k*M+1:(k+1)*M, l*N+1:(l+1)*N)./sqrt(2);
 end
 if l==0
 basis(k*M+1:(k+1)*M, l*N+1:(l+1)*N) = ...
 basis(k*M+1:(k+1)*M, l*N+1:(l+1)*N)./sqrt(2);
 end
 end
end
basis = basis.*(sqrt(2/N)*sqrt(2/M));
x = double(imread('basis_img.png'));
x = x(1:512,1:512);
% x=zeros(512,512);
[r,c] = size(x);
X = zeros(r,c);
for i=0:r/M-1
 for j=0:c/N-1
 xb = x(i*M+1:(i+1)*M, j*N+1:(j+1)*N);
 for k=0:M-1
 for l=0:N-1
 X(i+k*(r/M)+1,j+l*(c/N)+1) = sum(sum(xb.*basis(k*M+1:(k+1)*M,l*N+1:(l+1)*N)));
 end
 end
 end
end
XdB = 20*log10(abs(X)./max(max(abs(X))));
XdBt = XdB + 60;
XdBt = max(XdBt,0);
f1 = figure('Position',[500 300 600 600],'Units','Normalized');
set(f1,'PaperPosition',[0.25 1.5 8 8]);
axes('Position',[0.09 0.09 0.88 0.88]);
imagesc([0:c-1],[0:r-1],XdBt);
cmap = colormap('gray');
colormap(flipud(cmap));
set(gca,'XTick',[0:c/N:c],'YTick',[0:r/M:r]);
set(gca,'XTickLabel','','YTickLabel','');
grid on; set(gca,'GridLineStyle','-');
axis equal;
for k=0:M-1
     text(-40,k*r/M+r/M/2,['k = ' num2str(k)],'FontSize',14);
end
for l=0:M-1
 text(l*c/M+c/N/4,r+15,['l = ' num2str(l)],'FontSize',14);
end