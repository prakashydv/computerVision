%video epsnr 

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

    imgEdge = edge(rgb2gray(videoFrame1),'canny');
    [M,N]=size(imgEdge);
    edgePixels=0;
    m=double(0);
    
    for i=1:M
        for j=1:N
            if(imgEdge(i,j)==1)
                edgePixels=edgePixels+1;
                m=m+(double(videoFrame2(i,j))-double(videoFrame1(i,j)))^2;
            end
        end
    end
    
    m=m/(edgePixels);
    mse=mse+m;
  
end
mse=mse/numOfFrames;
epsnr=10*log10(255*255/mse)

tocId=toc;
conversionTime=tocId
numOfFrames
% release(videoPlayer);
release(videoFWriter);
release(videoFReader);
