
close all
clear all
clc

global myModel fileID markerScale divisor iteration

import org.opensim.modeling.*

iteration = 1;
markerScale = 1;
divisor = 1;

% downSample the passive .trc file for speed
file_input = 'Passive_Pref0002.trc';
file_output = 'Chopped.trc';
downSampleTRC(divisor,file_input,file_output)

% create new file for log - ROB search
% fileID = fopen('coarseMarkerSearch_log_passive_ROB_unchopped.txt', 'w'); 
% myModel = 'A07_passive_coarseSearch_chopped.osim';
% newName = 'A07_passive_coarse_marker_search.osim';

% create new file for log - Socket search
fileID = fopen('coarseMarkerSearch_log_passive_PROSTHIGH_unchopped.txt', 'w'); 
% myModel = 'A07_passive_manual_foot_markers.osim';
% myModel = 'A07_passive_ROBsearch_unchopped.osim';
myModel = 'A07_passive_PROSsearch_unchopped_no_thigh.osim';
newName = 'A07_passive_PROSTHIGHsearch_unchopped.osim';

% model = Model(myModel);
% model.initSystem();
% model.print(newName);

% scale
options.modelFolder = [pwd '\Models\'];
% options.limbScaleFactor = limbScaleFactor;  % segment scale factor
options.model = myModel;                    % generic model name
options.subjectMass = 73.1637;
options.newName = newName;
% options.bodySet = 'ROB';
% options.bodySet = 'pros';
options.bodySet = 'prosThigh';
% options.fixedMarkerCoords = {'L_HEEL_SUP y','L_HEEL_SUP z','L_TOE x','L_TOE y','L_TOE z'};
% options.fixedMarkerCoords = {'L_TOE x','L_TOE y','L_TOE z'};
options.fixedMarkerCoords = {'L_HEEL_SUP y','L_TOE x','L_TOE y','L_TOE z','L_THIGH_PROX_ANT x'};

options.convThresh = 1;

tic

X = coarseMarkerSearch(options);


model = Model('autoScaleWorker.osim');
model.initSystem();
model.print(newName);
fclose(fileID);