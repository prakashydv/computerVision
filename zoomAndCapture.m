%% Zoom&Capture
function zoomAndCapture(numOfPictures,imfolder,COMx)
    zoomLevels=['0000';'166F';'1FF0';'257D';'2940';'2C02';'2E2B';'2FEE';'316A';'32B2';'33D4';'34D9';'35C8';'36A4';'3773';'3836';'38F0';'39A0';'3A49';'3AE8';'3B7F';'3C0C';'3C8E';'3D06';'3D73';'3DD4';'3E2C';'3E7C';'3EC2';'3F00';'3F38';'3F68';'3F94';'3FBD';'3FDF';'4000'];
    vid = videoinput('winvideo',2);
    vid.FramesPerTrigger = 1;
    vid.TriggerRepeat=Inf;
    try
        preview(vid);
        start(vid);
    catch err
        display('Could not open Device !')
        throw(err)
    end
    count=0;
    imaqmem(2000000000);% memory LIMIT set to ~2GB 
    
    ipt_zoom=input('Enter 1 to increment zoom automatically [ 1x to lastZoom]: ');
    while count < numOfPictures
        %% zoom 
        if ipt_zoom~=1
            z=input('EnterZoom Level: ');
        else
            z=count+1;
        end
        if z<1 || z>=numOfPictures
            break;
        end
        fprintf('zooming to [%d:%s]\n',z,zoomLevels(z,:));
        zoom(COMx,zoomLevels(z,:));
        
        %% capture Image
        s=['[',int2str(count+1),'] Capture Image? (y=1/n=0) : '];
        op=input(s);
        if op==1
            try 
                im=getdata(vid);
            catch err
                display('Could Not Capture Image !');
                throw(err)
            end
            fname = sprintf('%s/%06d.jpg',imfolder,count);
            try 
                imwrite(im,fname);
            catch err
                display('Could not save file to disk!')
                throw(err)
            end
            count=count+1;
            flushdata(vid)
        else
            break
        end
        
    end
    stop(vid);
    delete(vid);
end
   