[filename,pathname]=uigetfile('*.*','Select the Input Grayscal Image');
filewithpath=strcat(pathname,filename);
Img=imread(filewithpath);
faceDetector=vision.CascadeObjectDetector;
faceDetector.MergeThreshold=10;
bboxes = faceDetector(Img);
if ~isempty (bboxes)
Imgf = insertObjectAnnotation(Img,'rectangle',bboxes,'Face','LineWidth',3);
imshow(Imgf)
title('Detected faces');
else
position=[0 0]; %[x y]
label='No face Detected';
Imgn = insertText(Img,position,label,'FontSize',25,'BoxOpacity',1);
imshow(Imgn)
end