clc;clear;close all;
 
vid = VideoReader('3.mp4');

vidWidth = vid.Width;
vidHeight = vid.Height;
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);
frames = zeros(vidHeight,vidWidth,3,80);
 
k = 1;
while hasFrame(vid)
    frames(:,:,:,k) = readFrame(vid);
    k = k+1;
end

R = squeeze(frames(:,:,1,:));
G = squeeze(frames(:,:,2,:));
B = squeeze(frames(:,:,3,:));
 
 
R_back = uint8(mode(R,3));
G_back = uint8(mode(G,3));
B_back = uint8(mode(B,3));
 
Background = cat(3,R_back,G_back,B_back);

for x = 1:80
    CurrentFrame = uint8(frames(:,:,:,x));
     
    % Mengkonversi citra menjadi grayscale
    Background_gray = rgb2gray(Background);
    CurrentFrame_gray = rgb2gray(CurrentFrame);
     
    % Pengurangan citra grayscale
    Subtraction = (double(Background_gray)-double(CurrentFrame_gray));
    Min_S = min(Subtraction(:));
    Max_S = max(Subtraction(:));
    Subtraction = ((Subtraction-Min_S)/(Max_S-Min_S))*255;
    Subtraction = uint8(Subtraction);
     
    % Mengkonversi citra menjadi biner menggunakan metode Otsu
    Subtraction = ~im2bw(Subtraction,graythresh(Subtraction));
     
    % Operasi Morfologi
    bw = imfill(Subtraction,'holes');
    bw = bwareaopen(bw,10);
     
    % Pembuatan masking dan proses cropping
    [row,col] = find(bw==1);
    h_bw = imcrop(CurrentFrame,[min(col) min(row) max(col)-min(col) max(row)-min(row)]);
     
    [a,b] = size(bw);
    mask = false(a,b);
    mask(min(row):max(row),min(col):max(col)) = 1;
    mask =  bwperim(mask,8);
    mask = imdilate(mask,strel('square',3));
     
    R = CurrentFrame(:,:,1);
    G = CurrentFrame(:,:,2);
    B = CurrentFrame(:,:,3);
     
    R(mask) = 255;
    G(mask) = 0;
    B(mask) = 0;
     
    RGB = cat(3,R,G,B);
     
    mov(x).cdata = RGB;
end
hf = figure;
set(hf,'position',[0 0 vidWidth vidHeight]);
 
movie(hf,mov,1,vid.FrameRate);
close