%% write chess-Settings
datapath = 'E:/data/28x_cover/28_cover_4_4/';
start_index = 1;
end_index = 27;
depth=2030;
SF_offset=1;


%% save settings to "squareSettings.mat"
save('chessSettings','datapath' ...
                     ,'start_index' ...
                     ,'end_index' ...
                     ,'depth' ...
                     ,'SF_offset');

                 