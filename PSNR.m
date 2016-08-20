%video psnr 

%open file for reading
videoFReader1 = vision.VideoFileReader('video1.avi');
videoFReader2 = vision.VideoFileReader('video2.avi');

tic;
numOfFrames=0;
mse=double(0);
while ~isDone(videoFReader1) && ~isDone(videoFReader2)
  numOfFrames=numOfFrames+1;
  [videoFrame1,] = step(videoFReader1);
  [videoFrame2,] = step(videoFReader2);
%   mse=mse+MSE_Two_Images(videoFrame1,videoFrame2);
    
    m=double(0);
    X=cast(videoFrame1,'double');
    Y=cast(videoFrame2,'double');
    [M,N]=size(X);
    for i=1:M
        for j=1:N
            m=m+((X(i,j)-Y(i,j))^2);
        end
    end
    m=m/(M*N);
    mse=mse+m;
  
  
 
end
mse=mse/numOfFrames;
psnr=10*log10(255*255/mse)

tocId=toc;
conversionTime=tocId
numOfFrames
% release(videoPlayer);
release(videoFWriter);
release(videoFReader);
