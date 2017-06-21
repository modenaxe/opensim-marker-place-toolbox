function cost = ObjFun(x,options)

global  rmsCOST avgRMS divisor COST fileID iteration markerScale loop coord stepCount
     
% override variables
% divisor = 1;


% Need to add comparison at frame 0 of socket angles - min to 0

genericSetupForIK = 'markerOptIKSetup.xml';

% X = x0;
X = x;
% disp(x)
newName = 'autoScaleWorker.osim';
% newName = newPassiveModel;

% markerScale
markerPlacer(X, newName,options);


try
    % run OpenSim IK executable through DOS
    [~, log_mes] = dos(['ik -S ' genericSetupForIK]);

    lines = strsplit(log_mes,'\n');
%     disp(lines)
    nLines = size(lines,2)-3;
%     disp(nLines)

    % Actually line 19, but unknown error, this cuts off first few frames
    % Revisit this, it can be cleaned up
    TSE = zeros(nLines-23,1); 
    RMS = zeros(nLines-23,1);
    for line = 22:nLines-2

        frame = strsplit(lines{line},{'\t', ' ',',','='});
        TSE(line-21,1) = str2double(frame{1,8});
        RMS(line-21,1) = str2double(frame{1,12});
        
    end
    
    TSEcost = sum((TSE.*1000).^2);
    RMScost = sum((RMS.*1000).^2);
%     disp(RMScost)
catch
    % if IK fails, it means the guess was VERY wrong
    RMScost = 10000000;
    TSEcost = 10000000;
end

IKresults = 'Chopped_ik.mot';
data = dlmread(IKresults,'\t',11,0);
% frames = round(302/divisor*.1);


% penalize the average pelvis tilt
TILTcost = abs(mean(data(1:end,2).^2))*10;

% penalize non-zero socket coordinates at the zero position
% data = importdata('Chopped_ik.mot','\t',11);
% tags = data.colheaders;
% flexionTag = find(strcmp('socket_flexion',tags));
% pistonTag = find(strcmp('socket_ty',tags));
% socketFlexion = data.data(1,flexionTag);
% socketPiston = data.data(1,pistonTag);

socketCostWeight = 100;

socketFlexion = data(1,19);
socketFlexion = socketFlexion.^2 * 100;
socketAdduction = data(1,20);
socketRotation = data(1,21);
socketPiston = data(1,23);
socketPiston = (socketPiston*1000).^2;
% SOCKETcost = (socketFlexion.^2 + socketPiston.^2) .* 50;
SOCKETcost = socketFlexion + socketPiston;

% total cost
cost = TSEcost + TILTcost + SOCKETcost;
% cost = TSEcost;

COST = cost;

rmsCOST = RMScost;


avgRMS = mean(RMS.*1000);

% t = toc;

%     message = ['OptRun: ' num2str(runner) ' Iter: ' num2str(iteration)...
%     ' Obj: ' num2str(cost) ' Avg RMS: ' num2str(avgRMS) ' time: ' ...
%     num2str(toc)];

%     message = [' Iter: ' num2str(iteration)...
%     ' Obj: ' num2str(cost) ' Avg RMS: ' num2str(avgRMS) ' Marker coordinate: ' ...
%     coord ' Steps from IC (mm): ' num2str(stepCount) ' time: ' num2str(toc)];

    message = [' Iter: ' num2str(iteration)...
    ' Obj: ' num2str(cost) ' Marker cost: ' num2str(TSEcost) ' Tilt cost: ' ...
    num2str(TILTcost) ' Socket cost: ' num2str(SOCKETcost) ' Flexion cost: ' ...
    num2str(socketFlexion) ' Piston cost: ' num2str(socketPiston) ' Avg RMS: ' ...
    num2str(avgRMS) ' Marker coordinate: ' coord ' Steps from IC (mm): ' ...
    num2str(stepCount) ' time: ' num2str(toc)];

disp(message)

strFormat = '%s';
fprintf(fileID, strFormat, message);
fprintf(fileID,'\n');

iteration = iteration + 1;


