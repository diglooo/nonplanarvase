%non-planar vase gcode generator
%by Davide Di Gloria davidedigloria87<at>gmail.com
%http://diglo.altervista.org
%2021-02-25

clc 
close all 
clear all

%how many millimeters of filamentt to extrude
%for each motion  segment
%0.043mm is for a good extrusion with a 0.4mm nozzle
deltaExtruder=0.043;

%first layer height
firstLayerHeight=0.3;

%print speed in mm/s
feedrate=35;

%minimum GCODE segment length. 0.5 is a good value
%prusaslicer generates 0.2-0.6mm segments in vase mode
minSegmentLen=0.5;

%t is the parameters of the vase function
%starting from t=10 to avoid function zeros
t=10.0;

%position of the origin of the vase in X Y mm
printOrigin=[100 100];

%vasefun is the parametric function to create the vase
%nLobes is the number of lobes in the shape of the vase
nLobes=3;

disp('Generating points...');
startPoint=vaseFun(t,nLobes);
lastPoint=startPoint;

%x y z e
gcodePoints=zeros(2,4);
extruderCounter=0;
tIncStep=0.005;
index=2;
totalPathLen=0.0;
totalExtrudedLen=0.0;

%generate segments until the object height is 50mm
while gcodePoints(index-1,3)<50        
    %to generate the next point, t is increased in small steps
    %until the euclidean distance nextPoint<->lastPoint 
    %is at least minSegmentLen
    epsilon=0.0;
    segmentLength=0.0;
    while segmentLength<minSegmentLen
         epsilon=epsilon+tIncStep;
         nextPoint=vaseFun(t+epsilon,nLobes);
         segmentLength=sqrt(sum((lastPoint - nextPoint) .^ 2));
    end
    t=t+epsilon;
    lastPoint=nextPoint;
    
    %increment extrusion
    extruderCounter=extruderCounter+deltaExtruder;
    
    %append the point 
    gcodePoints(index,1)=nextPoint(1)+printOrigin(1);
    gcodePoints(index,2)=nextPoint(2)+printOrigin(2);
    gcodePoints(index,3)=nextPoint(3)-startPoint(3)+firstLayerHeight;
    gcodePoints(index,4)=extruderCounter;
    index=index+1;
    
    totalPathLen=totalPathLen+segmentLength;
    totalExtrudedLen=extruderCounter;
end
disp('DONE');
disp(['path lenght   =' num2str(totalPathLen/1000.0) 'm']);
disp(['used filament =' num2str(totalExtrudedLen/1000.0) 'm']);

disp('Generating GCODE...');
fileID = fopen('nonplanarvase.gcode','w');

%append some staring GCODE for homing, temperature, fan... 
filetext = fileread('startGcode.txt');
fprintf(fileID,'%s\r\n',filetext);

%make the GCODE
for i=1:size(gcodePoints,1)
   fprintf(fileID,'G1 X%2.3f Y%2.3f Z%2.3f E%2.3f F%d\r\n',gcodePoints(i,1),gcodePoints(i,2),gcodePoints(i,3),gcodePoints(i,4),feedrate*60);
end
fclose(fileID);
disp('DONE');

%plot the data
figure
axis equal
plot3(gcodePoints(:,1),gcodePoints(:,2),gcodePoints(:,3));

