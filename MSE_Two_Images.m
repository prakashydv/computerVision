function mse = MSE_Two_Images(X,Y)
%Calculates the Peak-to-peak Signal to Noise Ratio of two images X and Y
[M,N]=size(X);
mse=double(0);
X=cast(X,'double');
Y=cast(Y,'double');
for i=1:M
    for j=1:N
        mse=mse+((X(i,j)-Y(i,j))^2);
    end
end
mse=mse/(M*N);
return ;
