function psnr= PSNR_Two_Images(X,Y)
%Calculates the Peak-to-peak Signal to Noise Ratio of two images X and Y
[M,N]=size(X);
m=double(0);
maxx=0;
maxy=0;
X=cast(X,'double');
Y=cast(Y,'double');
for i=1:M
    for j=1:N
        m=m+((X(i,j)-Y(i,j))^2);
        maxx=max(X(i,j),maxx);
        maxy=max(Y(i,j),maxy);
    end
end
m=m/(M*N);

%either
 psnr=10*log10(255*255/m);
%or
%mx=max(maxx,maxy);
%psnr=10*log10(mx*mx/m);
