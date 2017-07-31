
close all
clear all
clc

global myModel fileID markerScale divisor iteration

% Create strings for the subject name and type of prosthesis. For file naming and labeling only.
subject = 'A07';
prosType = 'passive';


import org.opensim.modeling.*

ikSetupPath = ([pwd '\IKSetup\']);
genericSetupForIK = 'A07_Setup_IK.xml';
trcDataDir = ([pwd '\MarkerData\PREF\']);
inputModelDir = ([pwd '\Models\Scaled\']);
modelDir = ([pwd '\Models\AutoPlaced\']);

modelFile = [pwd '\autoPlaceWorker.osim'];
markerFile = [trcDataDir '\A07_Pref_0002.trc'];
outputMotionFile = [pwd '\autoPlaceWorker.mot'];

ikTool = InverseKinematicsTool([ikSetupPath genericSetupForIK]);
% Edit setup .xml with model path
factorProp  = ikTool.getPropertyByName('model_file');
% Set the value for this string to the model path
PropertyHelper.setValueString(modelFile,factorProp);
factorProp  = ikTool.getPropertyByName('marker_file');
PropertyHelper.setValueString(markerFile,factorProp);
factorProp  = ikTool.getPropertyByName('output_motion_file');
PropertyHelper.setValueString(outputMotionFile,factorProp);
ikTool.print([ikSetupPath genericSetupForIK]);

iteration = 1;
% markerScale = 1;
% divisor = 1;

% downSample the passive .trc file for speed
% file_input = [trcDataDir 'A07_Pref_0002.trc']; 	% Your marker tracking .trc file
% file_output = 'Chopped.trc';                    % Leave this, used in other functions
% downSampleTRC(divisor,file_input,file_output)



% create new file for log - ROB search
% fileID = fopen('coarseMarkerSearch_log_passive_ROB_unchopped.txt', 'w'); 
% myModel = 'A07_passive_coarseSearch_chopped.osim';
% newName = 'A07_passive_coarse_marker_search.osim';

% create new file for log of marker search
fileID = fopen(['coarseMarkerSearch_log_' subject '_' prosType '_' char(datetime('now','TimeZone','local','Format','d-MMM-y_HH.mm.ss')) '.txt'], 'w'); % myModel = 'A07_passive_manual_foot_markers.osim';

% model = [subject '_' prosType '_pre_auto_marker_place.osim'];
model = 'A07_passive_manual_foot_markers.osim';
myModel = [inputModelDir model];    % define .osim model used as the starting point

newName = [subject '_' prosType '_ROB_auto_marker_place_' char(datetime('now','TimeZone','local','Format','d-MMM-y_HH.mm.ss')) '.osim'];
newModelName = [modelDir newName];  % set name for new .osim model created after placing ROB markers

robMarkerNames = {'R_AC','L_AC','R_ASIS','L_ASIS','R_PSIS', ...
            'L_PSIS','R_THIGH_PROX_POST','R_THIGH_PROX_ANT', ...
            'R_THIGH_DIST_POST','R_THIGH_DIST_ANT','R_SHANK_PROX_ANT', ...
            'R_SHANK_PROX_POST','R_SHANK_DIST_POST','R_SHANK_DIST_ANT', ...
            'R_HEEL_SUP','R_HEEL_MED','R_HEEL_LAT','R_TOE','R_1ST_MET', ...
            'R_5TH_MET','STERN','C7'};
prosMarkerNames = {'L_SHANK_PROX_POST', ...
            'L_SHANK_PROX_ANT','L_SHANK_DIST_ANT','L_SHANK_DIST_POST', ...
            'L_HEEL_SUP','L_HEEL_MED','L_HEEL_LAT', ...
            'L_TOE','L_1ST_MET','L_5TH_MET'};
prosThighMarkerNames = {'L_THIGH_PROX_POST','L_THIGH_PROX_ANT', ...
            'L_THIGH_DIST_POST','L_THIGH_DIST_ANT'};
% prosThighMarkerNames = {};

% Set model and algorithm options:
options.IKsetup = [ikSetupPath genericSetupForIK];
options.model = myModel;                    % generic model name
options.subjectMass = 67.3046;
options.newName = newModelName;
options.modelWorker = modelFile;
options.motionWorker = outputMotionFile;

% Choose which set of bodies/markers is being placed. 'ROB' = Rest of
% body, 'pros' = Markers on the prosthesis, 'prosThigh' = Thigh markers on
% the prosthesis side and the socket joint center of rotation:
options.bodySet = 'ROB';

options.txLock = false;
options.tyLock = false;
options.tzLock = false;
options.flexLock = false;
options.adducLock = false;
options.rotLock = false;

options.markerNames = robMarkerNames;

% List marker coordinates to be locked - algorithm cannot move them from
% hand-picked location:
options.fixedMarkerCoords = {'STERN x','STERN y','STERN z','L_HEEL_SUP y','L_TOE x','L_TOE y','L_TOE z'};

% Specify frame from .trc file at which socket flexion should be minimized:
options.flexionZero = 51; 

% Specify marker search convergence threshold. All markers must move less 
% than convThresh mm from start position at each markerset iteration to 
% converge. If 1, a full pass with no marker changes must take place:
options.convThresh = 1; 

tic

X_ROB = coarseMarkerSearch(options);
model = Model('autoPlaceWorker.osim');
model.initSystem();
model.print(newModelName);

myModel = newModelName;
newName = [subject '_' prosType '_PROS_auto_marker_place_' char(datetime('now','TimeZone','local','Format','d-MMM-y_HH.mm.ss')) '.osim'];
newModelName = [modelDir newName];
options.bodySet = 'pros';
options.markerNames = prosMarkerNames;
X_pros = coarseMarkerSearch(options);
model = Model('auoPlaceWorker.osim');
model.initSystem();
model.print(newModelName);


% preSocketJointModel = [modelDir 'A07_passive_PROS_auto_marker_place_4dof_base.osim'];
preSocketJointModel = newModelName;

myModel = preSocketJointModel;
newName = [subject '_' prosType '_FULL_auto_marker_place_RIGID_' char(datetime('now','TimeZone','local','Format','d-MMM-y_HH.mm.ss')) '.osim'];
newModelName = [modelDir newName];
options.bodySet = 'prosThigh';
options.txLock = true;
options.tyLock = true;
options.tzLock = true;
options.flexLock = true;
options.adducLock = true;
options.rotLock = true;
options.markerNames = prosThighMarkerNames;
options.fixedMarkerCoords = {'STERN x','STERN y','STERN z','L_HEEL_SUP y','L_TOE x','L_TOE y','L_TOE z','SOCKET_JOINT_LOC_IN_BODY z'};
X_prosThigh = coarseMarkerSearch(options);
model = Model('autoPlaceWorker.osim');
model.initSystem();
model.print(newModelName);

myModel = preSocketJointModel;
newName = [subject '_' prosType '_FULL_auto_marker_place_FLEXION_ONLY_' char(datetime('now','TimeZone','local','Format','d-MMM-y_HH.mm.ss')) '.osim'];
newModelName = [modelDir newName];
options.txLock = true;
options.tyLock = true;
options.tzLock = true;
options.flexLock = false;
options.adducLock = true;
options.rotLock = true;
options.fixedMarkerCoords = {'L_HEEL_SUP y','L_TOE x','L_TOE y','L_TOE z','SOCKET_JOINT_LOC_IN_BODY z'};
X_prosThigh = coarseMarkerSearch(options);
model = Model('autoPlaceWorker.osim');
model.initSystem();
model.print(newModelName);

myModel = preSocketJointModel;
newName = [subject '_' prosType '_FULL_auto_marker_place_PISTON_ONLY_' char(datetime('now','TimeZone','local','Format','d-MMM-y_HH.mm.ss')) '.osim'];
newModelName = [modelDir newName];
options.txLock = true;
options.tyLock = false;
options.tzLock = true;
options.flexLock = true;
options.adducLock = true;
options.rotLock = true;
options.fixedMarkerCoords = {'L_HEEL_SUP y','L_TOE x','L_TOE y','L_TOE z','SOCKET_JOINT_LOC_IN_BODY z'};
X_prosThigh = coarseMarkerSearch(options);
model = Model('autoPlaceWorker.osim');
model.initSystem();
model.print(newModelName);

myModel = preSocketJointModel;
newName = [subject '_' prosType '_FULL_auto_marker_place_FLEXION_PISTON_' char(datetime('now','TimeZone','local','Format','d-MMM-y_HH.mm.ss')) '.osim'];
newModelName = [modelDir newName];
options.txLock = true;
options.tyLock = false;
options.tzLock = true;
options.flexLock = false;
options.adducLock = true;
options.rotLock = true;
X_prosThigh = coarseMarkerSearch(options);
model = Model('autoPlaceWorker.osim');
model.initSystem();
model.print(newModelName);

myModel = preSocketJointModel;
newName = [subject '_' prosType '_FULL_auto_marker_place_4DOF_' char(datetime('now','TimeZone','local','Format','d-MMM-y_HH.mm.ss')) '.osim'];
newModelName = [modelDir newName];
options.fixedMarkerCoords = {'L_HEEL_SUP y','L_TOE x','L_TOE y','L_TOE z','SOCKET_JOINT_ORIENT x','SOCKET_JOINT_ORIENT y'};
options.txLock = true;
options.tyLock = false;
options.tzLock = true;
options.flexLock = false;
options.adducLock = false;
options.rotLock = false;
X_prosThigh = coarseMarkerSearch(options);
model = Model('autoPlaceWorker.osim');
model.initSystem();
model.print(newModelName);


fclose(fileID);

