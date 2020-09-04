function [header,footer,material,numvertex,facevert] = read_object(wiFolder, objectFileName)
% This function helps read the object file.

% Read file to count face num
face_num = 0;
filename = strcat(wiFolder, '/', objectFileName, '.object');
ofid=fopen(filename);
tline = fgets(ofid);
while ischar(tline)
    if strcmp(strtrim(tline),'begin_<face>')
        face_num = face_num + 1;
    end
    tline = fgets(ofid);
end

%Begin processing the Object file
filename = strcat(wiFolder, '/', objectFileName, '.object');
ofid=fopen(filename);

%Begin reading the object file
facebegin=0;
faceline=1;
facecount=0;
faceend=0;
header={};
footer={};
facevert=cell(1, face_num);
material = zeros(1, face_num);
numvertex = zeros(1, face_num);
hcnt=0;fcnt=0; %Line counter for header and the footer
readingheader=1;
tline = fgets(ofid);
while ischar(tline)
%     disp(tline)
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
end

 
