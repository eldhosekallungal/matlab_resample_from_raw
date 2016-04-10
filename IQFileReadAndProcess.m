% This script will open the raw IQ file
% Default format 16 bit PCM
% Dual channel
clear all;

folder = '.';
IQ12FileList = dir(strcat(folder,'/*.wav'));
IQ48FileList = dir(strcat(folder,'/*.iq48'));

% Process IQ12 files

for i = 1:length(IQ12FileList)
    fileName = IQ12FileList(i).name;
    % Open the file pointer
    directory = strcat(folder, '/', fileName);
    fp = fopen(directory);
    IQ12rawData = fread(fp, [2, inf], 'int16=>double');
    IQ12rawData = IQ12rawData';
end

% Process IQ48 files

for i = 1:length(IQ48FileList)
    fileName = IQ48FileList(i).name;
    % Open the file pointer
    directory = strcat(folder, '/', fileName);
    fp = fopen(directory);
    IQ48rawData = fread(fp, [2, inf], 'int16=>double');
    IQ48rawData = IQ48rawData';
end