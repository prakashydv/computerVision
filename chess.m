clear all
close all
clc

%% load settings
load('chessSettings')

%% call the main function
OC_chess(datapath,start_index,end_index,depth,SF_offset); 
%consider adding R=5, C=8, ext='.ppm' to argument list 