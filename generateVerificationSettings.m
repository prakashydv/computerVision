modelFilePath = 'E:/data/30x_plain/30x_1_28_28xzoommap/';
colliImagePath= 'E:/data/1020p_04/';
takeFreshImages = 2;	%0-use existing image  1-take fresh Images 2-use existing data 'P.mat'
videoPort = 1;          %refer to imaqhwinfo('winvideo')
serialPort = 'COM5'; 	%refer to Device Manager
ext='jpg';				%extention of image format
imWidth=704; 			% in pixels (used in error calculation)

save('verficationSettings','modelFilePath','colliImagePath' ...
                            ,'takeFreshImages','videoPort' ...
							,'serialPort','ext' ...
							,'imWidth');