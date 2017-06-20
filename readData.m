function [outfile] = readData(filename)

% global variables
global coordinates elements nn nel pointNode MAT DBCSet PFCSet

% Open file
fileID = fopen(filename,'r');

% get first three lines and discard them
for i=1:3
    fgetl(fileID);
end

% get mesh input file
tline = fgetl(fileID);
tmp = strsplit(tline);
len = length(tmp); 
if len > 4
    % concatenate name
    for i=4:len-1
        mshfile = tmp{i};
        s1 = tmp{i+1};
        mshfile = strcat(mshfile,{' '},s1);
    end
else
   mshfile = tmp{4}; 
end
% get output file location
tline = fgetl(fileID);
tmp = strsplit(tline);
len = length(tmp); 
if len > 3
    % concatenate name
    for i=3:len-1
        outfile = tmp{i};
        s1 = tmp{i+1};
        outfile = strcat(outfile,{' '},s1);
    end
else
   outfile = tmp{3}; 
end
% read Dirichlet BCs
tline = fgetl(fileID);
tmp = strsplit(tline);
ndbc = str2double(tmp(3)); % number of DBC to read
DBCSet = zeros(ndbc,4);
for i=1:ndbc
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    DBCSet(i,1) = str2double(tmp(1));
    DBCSet(i,2) = str2double(tmp(2));
    dof = sscanf(tmp{3},'%[XY]');
    value = str2double(tmp(4)); % value to assign
    if strcmp(dof,'X')
        DBCSet(i,3) = 1;
        DBCSet(i,4) = value;
    elseif strcmp(dof,'Y')
        DBCSet(i,3) = 2;
        DBCSet(i,4) = value;
    else
        error('DOF must be X or Y, please check')
    end
end
% read point force BCs
tline = fgetl(fileID);
tmp = strsplit(tline);
npfc = str2double(tmp(3)); % number of point force to read
PFCSet = zeros(npfc,4);
for i=1:npfc
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    PFCSet(i,1) = str2double(tmp(1));
    PFCSet(i,2) = str2double(tmp(2));
    dof = sscanf(tmp{3},'%[XY]');
    value = str2double(tmp(4)); % value to assign
    if strcmp(dof,'X')
        PFCSet(i,3) = 1;
        PFCSet(i,4) = value;
    elseif strcmp(dof,'Y')
        PFCSet(i,3) = 2;
        PFCSet(i,4) = value;
    else
        error('Force must be X or Y, please check')
    end
end
%Read material properties
% get next line and discard it
fgetl(fileID);
tline = fgetl(fileID);
tmp = strsplit(tline);
nmat = str2double(tmp(3)); % number of materials
MAT = zeros(nmat,2);

for i=1:nmat
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    MAT(i,1) = str2double(tmp(3)); % Elastic modulus
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    MAT(i,2) = str2double(tmp(2)); % area
end
fclose(fileID);

% ====================
% Open msh file
% ====================

fileID = fopen(mshfile,'r');

% get first three lines and discard them
for i=1:3
    fgetl(fileID);
end

% Get physical names (mandatory)
tline = fgetl(fileID);
if ~strcmp(tline,'$PhysicalNames')
    error('Input data MUST declare PhysicalNames. Please check.');
end
% get number of names
nNames = str2double(fgetl(fileID));
% get names
phyNames = zeros(nNames,2);
% each row contains: physical-dimension physical-number
for i=1:nNames
    tline = fgetl(fileID);
    phyNames(i,:) = sscanf(tline,'%d %d %*s');
end
fgetl(fileID); % discard this line
% Read nodes
fgetl(fileID); % discard this line
tline = fgetl(fileID);
nn = str2double(tline);
%
coordinates = zeros(nn,3);
for i=1:nn
    tline = fgetl(fileID);
    coordinates(i,:) = sscanf(tline,'%*d %f %f %f');
end
fgetl(fileID); % discard this line
%
% read elements
fgetl(fileID); % discard this line
tline = fgetl(fileID);
nelT = str2double(tline);
elementsT = cell(nelT,1);
% count number of 1-node point
pointCount = 0;
% count number of 2-node line
lineCount = 0;
for i=1:nelT
    tline = fgetl(fileID);
    C = str2double(strsplit(tline));
    switch C(2)
        case 15
            pointCount = pointCount + 1;
        case 1
            lineCount = lineCount + 1;
        otherwise
            error('Unknown element type. Please check.')
    end
    elementsT(i) = {C};
end
%close file
fclose(fileID);
% post-process data
nel = lineCount;
elements = zeros(nel,3); % store number of physical entity, element tag
pointNode = zeros(pointCount,2);
%
% count number of 1-node point
pointCount = 0;
% count number of 2-node line
lineCount = 0;
for i=1:nelT
    % get array
    v = elementsT{i};
    switch v(2)
        case 15
            pointCount = pointCount + 1;
            pointNode(pointCount,1) = v(4);
            pointNode(pointCount,2) = v(6); 
        case 1
            lineCount = lineCount + 1;
            elements(lineCount,1) = v(4);
            elements(lineCount,2:3) = v(6:7);
        otherwise
            error('Unknown element type. Please check.')
    end
end
%
clearvars elementsT

end