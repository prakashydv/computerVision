%image source : http://armyphotos.net/army-soldiers-photos/ww2-russian-soldiers/
I = imread('image.jpg');
I = im2double(I);
I=I(1:512,1:512);%crop
T = dctmtx(8);
dct = @(block_struct)( T * block_struct.data * T' );
B = blockproc(I,[8 8],dct);
mask = [1   1   1   1   1   0   0   0
        1   1   1   1   0   0   0   0
        1   1   1   0   0   0   0   0
        1   1   0   0   0   0   0   0
        1   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0];
B2 = blockproc(B,[8 8],@(block_struct) mask .* block_struct.data);
invdct = @(block_struct) T' * block_struct.data * T;
I2 = blockproc(B2,[8 8],invdct);
imshow(I), figure, imshow(I2)
imwrite(I2,'image_15DCTcoeffs.jpg','quality',100);