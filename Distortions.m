%GAUSSIAN DISTORTION (BLURRING)

%img=rgb2gray(imread('img1.jpg'));
img=imread('img1.jpg');

%creates rotationally symmetric Gaussian lowpass filter of size hsize 
%with standard deviation sigma (positive). hsize can be a vector
%specifying the number of rows and columns in h, or it can be a scalar,
%in which case h is a square matrix. The default value for hsize is [3 3];
%the default value for sigma is 0.5.

sigma1=3.2;
sigma2=3.9;
sigma3=4.6;
gaussian_filter_1 = fspecial('gaussian', floor(sigma1), sigma1);
gaussian_filter_2 = fspecial('gaussian', floor(sigma2), sigma2);
gaussian_filter_3 = fspecial('gaussian', floor(sigma3), sigma3);


%filter the multidimensional array A with the multidimensional 
%filter h. The array A can be logical or a nonsparse numeric array
%of any class and dimension. The result B has the same size and class as A.

img1 = imfilter(img,gaussian_filter_1);
img2 = imfilter(img,gaussian_filter_2);
img3 = imfilter(img,gaussian_filter_3);


%display results

% subplot(1,4,1);imshow(img);title('Original Image');
% subplot(1,4,2);imshow(img1);title('Sigma 3.2');
% subplot(1,4,3);imshow(img2);title('Sigma 3.9');
% subplot(1,4,4);imshow(img3);title('Sigma 4.6');

%write resulting images to folder

%BLURRED IMAGES
imwrite(img1,'img1_sigma_3_2.jpg','jpg');
imwrite(img2,'img1_sigma_3_9.jpg','jpg');
imwrite(img3,'img1_sigma_4_6.jpg','jpg');

%COMPRESSED IMAGES
imwrite(img,'img_comp_5.jpg','quality',5);
imwrite(img,'img_comp_12.jpg','quality',12);
imwrite(img,'img_comp_27.jpg','quality',27);

%IMAGES WITH NOISE
imwrite(imnoise(img,'salt & pepper',0.05),'img_noise_05.jpg');
imwrite(imnoise(img,'salt & pepper',0.10),'img_noise_10.jpg');
imwrite(imnoise(img,'salt & pepper',0.20),'img_noise_20.jpg');