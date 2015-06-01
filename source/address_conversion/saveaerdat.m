function saveaerdat(train,filename)
% function saveaerdat(train[,filename])
% write events to a .dat file (tobi's aer data format).
% run this script, which opens a file browser. browse to the .dat file and click "Open".
%
% argument train is the data, an Nx2 array.
% train(:,1) are the timestamps with 1us tick, train(:,2) are the
% addresses.
% these address are raw; to generate addressses corresponding to a
% particular x,y location and event type, you need to know the bit mapping.
% For instance, for the DVS128, the addresses are 15 bit, with 
% AE15=0, AE14:8=y, AE7:1=x, and AE0=polarity of event. See
% extractRetina128EventsFromAddress.m.
%
% filename is an optional filename which overrides the dialog box

if nargin==1,
    [filename,path,filterindex]=uiputfile('*.aedat','Save data file');
elseif nargin==2,
    path='';
end

ts=train(:,1);
addr=train(:,2);

f=fopen([path,filename],'w','b'); % open the file for writing with big endian format

% data format:
%
% int16 addr
% int32 timestamp
% int16 address
% int32 timestamp
% ....

% the skip argument to fwrite is how much to skip *before* each value is written

% timestamps
fseek(f,0,'bof'); % seek to start of file, because we will skip before first timestamp
count=fwrite(f,uint32(ts),'uint32',2); % write 4 byte timestamps, skipping 2 bytes before each

% addressses
fseek(f,0,'bof'); % seek to start of file which is where addresses start
count=fwrite(f,uint16(addr(1)),'uint16'); % write first address
fseek(f,2,'bof'); % seek to place so that skip of 4 will bring us to 2nd address
count=fwrite(f,uint16(addr(2:end)),'uint16',4); % write 2 byte addresses, skipping 4 bytes after each
fclose(f);