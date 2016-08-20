function err =  realError(deltapixels,zoomLevel,datapath)
%     FOVmap=[57.621587,29.022119,18.854515,13.563407,10.810883,...
%             8.985163,7.745151,6.715008,5.996934,5.388569,...
%             4.845215,4.47952,4.114173,3.818305,3.562123,...
%             3.349231,3.140664,2.991622,2.824094,2.695775,...
%             2.572032,2.477269,2.361272,2.265785,2.196693,...
%             2.113818,2.036969,1.973202];%28x_cover_hfov
    load([datapath,'FOV']);
    FOVmap=FOV(:,1);
    angle=FOVmap(zoomLevel,1);
    if angle>50.0
        distance= 500.0;
    elseif( angle >25.0)
        distance= 500.0;
    elseif(angle > 17.0)
        distance=750.0;
    else
        distance=2000.0;
    end
    
    err=(deltapixels/704)*FOVmap(zoomLevel,1)*distance*(3.14159/180.0);
    
end