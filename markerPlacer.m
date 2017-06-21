function markerPlacer(X, newName, options)

global myModel markerScale

import org.opensim.modeling.*
   
model = Model(myModel);
model.initSystem();
% disp(myModel)
% move markers
markers = model.getMarkerSet;
fixedMarkerCoords = options.fixedMarkerCoords;


% X(1:end) = X(1:end)./ markerScale;
% disp(X)

% determine amputation side
joints = model.getJointSet();
socketParent = joints.get('socket').getParentBody();

if strcmp(options.bodySet, 'ROB') % Note sternum not included - constrained to initial position
    if strcmp(char(socketParent),'tibia_l_amputated')
        
        markerNames = {'R_AC','L_AC','R_ASIS','L_ASIS','R_PSIS', ...
            'L_PSIS','R_THIGH_PROX_POST','R_THIGH_PROX_ANT', ...
            'R_THIGH_DIST_POST','R_THIGH_DIST_ANT','R_SHANK_PROX_ANT', ...
            'R_SHANK_PROX_POST','R_SHANK_DIST_POST','R_SHANK_DIST_ANT', ...
            'R_HEEL_SUP','R_HEEL_MED','R_HEEL_LAT','R_TOE','R_1ST_MET', ...
            'R_5TH_MET','C7'};
    else
        markerNames = {'R_AC','L_AC','R_ASIS','L_ASIS','R_PSIS','L_PSIS', ...
            'L_THIGH_PROX_POST','L_THIGH_PROX_ANT', ...
            'L_THIGH_DIST_POST','L_THIGH_DIST_ANT','L_SHANK_PROX_ANT', ...
            'L_SHANK_PROX_POST','L_SHANK_DIST_POST','L_SHANK_DIST_ANT', ...
            'L_HEEL_SUP','L_HEEL_MED','L_HEEL_LAT','L_TOE','L_1ST_MET', ...
            'L_5TH_MET','C7'};
    end
elseif strcmp(options.bodySet, 'pros')
%     if strcmp(char(socketParent),'tibia_l_amputated')
%         markerNames = {'L_SHANK_PROX_POST', ...
%             'L_SHANK_PROX_ANT','L_SHANK_DIST_ANT','L_SHANK_DIST_POST', ...
%             'L_HEEL_SUP','L_HEEL_MED','L_HEEL_LAT', ...
%             'L_TOE','L_1ST_MET','L_5TH_MET'};
%     else
%         markerNames = {'R_SHANK_PROX_POST', ...
%             'R_SHANK_PROX_ANT','R_SHANK_DIST_ANT','R_SHANK_DIST_POST', ...
%             'R_HEEL_SUP','R_HEEL_MED','R_HEEL_LAT', ...
%             'R_TOE','R_1ST_MET','R_5TH_MET'};
%     end
    if strcmp(char(socketParent),'tibia_l_amputated')
        markerNames = {'L_SHANK_PROX_POST', ...
            'L_SHANK_PROX_ANT','L_SHANK_DIST_ANT','L_SHANK_DIST_POST', ...
            'L_HEEL_SUP','L_HEEL_MED','L_HEEL_LAT', ...
            'L_TOE','L_1ST_MET','L_5TH_MET','L_THIGH_PROX_POST','L_THIGH_PROX_ANT', ...
            'L_THIGH_DIST_POST','L_THIGH_DIST_ANT'};
    else
        markerNames = {'R_SHANK_PROX_POST', ...
            'R_SHANK_PROX_ANT','R_SHANK_DIST_ANT','R_SHANK_DIST_POST', ...
            'R_HEEL_SUP','R_HEEL_MED','R_HEEL_LAT', ...
            'R_TOE','R_1ST_MET','R_5TH_MET','R_THIGH_PROX_POST','R_THIGH_PROX_ANT', ...
            'R_THIGH_DIST_POST','R_THIGH_DIST_ANT'};
    end
% elseif strcmp(options.bodySet, 'prosThigh')
%     if strcmp(char(socketParent),'tibia_l_amputated')
%         markerNames = {'L_THIGH_PROX_POST','L_THIGH_PROX_ANT', ...
%             'L_THIGH_DIST_POST','L_THIGH_DIST_ANT'};
%     else
%         markerNames = {'R_THIGH_PROX_POST','R_THIGH_PROX_ANT', ...
%             'R_THIGH_DIST_POST','R_THIGH_DIST_ANT'};
%     end
else
    error('Invalid body set name')
end

index = 1;
for i = 1:length(markerNames)
    m = Vec3(0,0,0);
    markers.get(markerNames(i)).getOffset(m);
    for j=1:3
        switch j
            case 1
                if max(strcmp(fixedMarkerCoords,[markerNames{i} ' x']))
                    mx = m.get(0);                
                else
                    mx = X(index);
                    index = index+1;
                end
            case 2
                if max(strcmp(fixedMarkerCoords,[markerNames{i} ' y']))
                    my = m.get(1);
                else
                    my = X(index);
                    index = index+1;
                end                
            case 3
                if max(strcmp(fixedMarkerCoords,[markerNames{i} ' z']))
                    mz = m.get(2);                
                else
                    mz = X(index);
                    index = index+1;
                end                
        end
    end
    M = Vec3(mx,my,mz);
    markers.get(markerNames(i)).setOffset(M);
end

% for i = 1:length(markerNames) % change to for length of total coords minus fixed coords, change in IC function
%         
%     if strcmp(markerNames{i},'L_HEEL_SUP')
%         m = Vec3(0,0,0);
%         markers.get(markerNames(i)).getOffset(m);
%         M = Vec3(X(3*(i-1) + 1),m.get(1),m.get(2));
%         markers.get(markerNames(i)).setOffset(M);  
%     elseif strcmp(markerNames{i},'L_TOE')
% %         m = Vec3(0,0,0);
% %         markers.get(markerNames(i)).getOffset(m)
% %         M = Vec3(m.get(0),m.get(1),m.get(2));
% %         markers.get(markerNames(i)).setOffset(M); 
%     else
%         M = Vec3(X(3*(i-1) + 1),X(3*(i-1) + 2),X(3*(i-1) + 3));
%         markers.get(markerNames(i)).setOffset(M);
%     end
%     
% end

%append to marker coords loop. Change location and orientation in parent
%(and child?)
%     sc = Vec3(); % create empty OpenSim vector for socket loc in child 
%     sp = Vec3(); % create empty OpenSim vector for socket loc in parent 
%     joints.get('socket').getLocationInParent(sp);
    socketNewP = Vec3(X(end-2),X(end-1),X(end));
    joints.get('socket').setLocationInParent(socketNewP);

% get coordinates and set defaults that may be altered from scaling
coords = model.getCoordinateSet();


coords.get('mtp_angle_r').setDefaultLocked(false);
coords.get('knee_angle_l').setDefaultLocked(false);
coords.get('foot_flex').setDefaultLocked(false);

% socket coordinates
coords.get('socket_tx').setDefaultLocked(true);
coords.get('socket_ty').setDefaultLocked(false);
coords.get('socket_tz').setDefaultLocked(true);
coords.get('socket_flexion').setDefaultLocked(false);
coords.get('socket_adduction').setDefaultLocked(false);
coords.get('socket_rotation').setDefaultLocked(false);

% model.setName('A07_passive_femurLengthStudy')

model.initSystem();

% pause(0.1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model.print(newName);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
