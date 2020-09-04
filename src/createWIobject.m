%plot object created in WirelessInsite
clear all
close all

%Input folder where the original project is located
inFolder=['./WIseed'];
objectFilename='1';
setupFilename='';
xmlFileName='';
projectName='';
ofid=fopen([inFolder objectFilename '.object']);

%Create a new time stamp to create a new project
timestamp=strrep(num2str(round(clock)),'    ','_');
outFolderName=['WIproj/WI_' timestamp];
mkdir(outFolderName)


%Begin reading the object file
facebegin=0;
faceline=1;
facecount=0;
faceend=0;
header={};
footer={};
hcnt=0;fcnt=0; %Line counter for header and the footer
readingheader=1;
tline = fopen(ofid);
while ischar(tline)
    disp(tline)
    facebegin=strcmp(strtrim(tline),'begin_<face>');
    if(~facebegin && readingheader==0)
        fcnt=fcnt+1;
        footer{fcnt}=tline;
    end
    if (facebegin)
        facecount=facecount+1;
        
        %read the material type
        dummy=strsplit(strtrim(fgets(ofid)));
        material(facecount)=str2double(dummy(2));
        
        %read the number of vertices
        dummy=strsplit(strtrim(fgets(ofid)));
        numvertex(facecount)=str2double(dummy(2));
        
        %Read cordinate of each vertices
        for fvc=1:numvertex(facecount)
            dummy=strsplit(strtrim(fgets(ofid)));
            facevert{facecount}(fvc,:)=str2double(dummy);
        end
        
        %Read the 'end_<face>
        while ~strcmp(strtrim(tline),'end_<face>')
            tline=fgets(ofid);
        end
        facebegin=0;
        readingheader=0; %Everything beyond the face description is footer
    end
    if(readingheader)
        hcnt=hcnt+1;
        header{hcnt}=tline;
    end
    
    tline = fgets(ofid);
end
fclose(ofid);

%End of the object file

%Define axis of the object
centroidf1=sum(facevert{5},1)/size(facevert{5},1);
centroidobj=sum(cell2mat(facevert'))/size(cell2mat(facevert'),1);

%Draw the object along with the axis
h=figure;hold on
drawWIobject(h,facevert,centroidobj,centroidf1,'r',0.3)
grid on
axis([0 2 0 2 0 2])
view(-45,45)
axis equal


%Move the object along a trajectory, with its axis parallel to the gradient
%of the path
h3=figure;hold on
acceldata='xyzfour';
load(acceldata)
for n=1:3:length(x)
    v1=[x(n) y(n) z(n)]+[1 1 1];
    v2=v1+[u(n) v(n) w(n)];
    [facevertrot,p1rot,p2rot]=alignWithV(v1,v2,centroidobj,centroidf1,facevert);
    drawWIobject(h3,facevertrot,p1rot,p2rot,'g',0.3)
    writeWIObject(outFolderName,objectFilename,facevertrot,...
                  numvertex,material,header,footer);
end
axis equal
grid on
view([70 18])


