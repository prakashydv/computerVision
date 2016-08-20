%video_rewrite 

%open file for reading
videoFReader = vision.VideoFileReader('PSNR/video1.avi');
%open file for writing
videoFWriter = vision.VideoFileWriter('video1.avi','FrameRate',videoFReader.info.VideoFrameRate);

videoFWriter.VideoCompressor='DV Video Encoder';
videoFReader.AudioOutputPort=true;
videoFWriter.AudioInputPort=true;

tic;

numOfFrames=0;
while ~isDone(videoFReader)
  numOfFrames=numOfFrames+1;
  [videoFrame,audioframe] = step(videoFReader);
  
  imwrite(videoFrame,'temp.jpg','quality',100);  
  videoFrame=imread('temp.jpg');
  
  step(videoFWriter,videoFrame,audioframe);
  %step(videoPlayer, videoFrame);
end
tocId=toc;
conversionTime=tocId
numOfFrames
% release(videoPlayer);
release(videoFWriter);
release(videoFReader);
