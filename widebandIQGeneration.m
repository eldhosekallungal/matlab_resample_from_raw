% This script will take every IQ12 and IQ48 files and upsample to 250kHz.
% This will also synchronize every file such that each of them have same
% length
% Finally it will place each file in the 1MHz frequency domain
% 535kHz-1710Khz
% 4kHz adjacent gap is provided.

% Setting the frequency domain parameters
clear all;

centerFrequency = 1e6;
upsampleRate = 250e3;  % Frequency in Hz
frequencyBin = (2*pi)/upsampleRate; % Digital frequency bin
frequencySpacing = 4e3; % Spacing to avoid overlapping

% Setting the file folder
folderName = '.';

%Getting the list of files for WAV file

fileList = dir(strcat(folderName,'/*.wav')); % It is a structre

%...... fileList
%...............--->name
%...............--->date
%...............--->bytes
%...............--->isdir
%------------------>datenum

% Total files

filesCount = length(fileList);

if(filesCount == 0)
    disp(strcat('The folder does not contain any wave file, filesCount',...
        '=', num2str(filesCount)));
    return;
end
% Pre-allocate the file size
IQFiles(filesCount).samples = 0;
IQFiles(filesCount).rate = 0;
IQFiles(filesCount).length = 0;
%iterate through each file and find the largest file

%Create a temporary variable for getting largest time sampled file
tmpTimeSamples = 0;
% Temporary variable for getting maximum count
tmpSamples = 0;
for i = 1:filesCount

    %Get the name
    name = fileList(i).name;
    %Set the file
    file = strcat(folderName,'/',name);
    %Read the wave file
    [IQFiles(i).samples, IQFiles(i).rate] = wavread(name,'native');
    IQFiles(i).samples = double(IQFiles(i).samples);
    % This is only for testing
    tmpTimeSamples = IQFiles(i).samples;
    %
    IQFiles(i).length = length(IQFiles(i).samples);
    % Find the maximum samples
    if(IQFiles(i).length > tmpSamples)
        tmpSamples = IQFiles(i).length;
    end
end

% Rearrange each file to the maximum sample and upsample to 250kHz
% Shift the spectrum to entire 1Mhz band
% TODO Calculate the maximum number of files can included in 1MHz band
% TODO Save bandwidth of each file for allocating the bands

nextFreq = 1.02e6; % The start frequency

for i = 1:filesCount
    
    % Find the number of copies required
    
    mul = ceil(tmpSamples/IQFiles(i).length);
    
    %create temporary variable for resized array
    
    tmpResizeArray = zeros(mul*IQFiles(i).length,2);
    for j = 1:mul
        tmpResizeArray((j-1)*IQFiles(i).length + 1 : j*IQFiles(i).length,:)...
             = IQFiles(i).samples;
    end
    IQFiles(i).samples = tmpResizeArray;
    IQFiles(i).samples = IQFiles(i).samples(1:tmpSamples,:);
    
    % Do the resampling
    IQFiles(i).samples = resample(IQFiles(i).samples,...
        upsampleRate, IQFiles(i).rate);
    
    % Shift the spectrum to entire 1MHz band
    
    % For simplicity assume 20kHz bandwidth
    
    shiftBins = (centerFrequency - nextFreq) * frequencyBin;
    shiftValues = exp((-1i * shiftBins).*[0:length(IQFiles(i).samples)-1])';
    
    IQFiles(i).samples(:,1) = real(shiftValues).*IQFiles(i).samples(:,1);
    IQFiles(i).samples(:,2) = imag(shiftValues).*IQFiles(i).samples(:,2);
    
    nextFreq = nextFreq + 20e3 + frequencySpacing;
    
end
    
timeSamples = complex(IQFiles(1).samples(:,1), IQFiles(1).samples(:,2));
fftSamples = fft(timeSamples, 16384);
plot(10*log10(abs(fftSamples)));

hold on;

timeSamples = complex(tmpTimeSamples(:,1), tmpTimeSamples(:,2));
fftSamples = fft(timeSamples, 16384);
plot(10*log10(abs(fftSamples)));

            
