% This program generates a sequence of runnable Wireless Insite simulation 
% directories with a given SUMO traffic pattern.
% Prerequisites:
%     1. A "base" Wireless Insite simulation directory with fixed 3D models
%        (e.g. buildings, ground) and transmitters/receivers all properly 
%        configered.
%     2. A SUMO-generated traffic pattern. Save vehicle locations and types
%        at each timestamp to one .mat file and put all files of one traffic
%        pattern to one directory.
%     3. A set of vehicle models in the format of Wireless Insite 3D files (.object). 
%        The vehicle types should be consistent with the types in SUMO. 
%        Save the 3D models to one directory.
%
%

clear;clc;
close all;

%% Config SUMO file folders
sumo_folder = '../sumo/';   % This is where you store the SUMO .mat files
sim_num = 1000;             % Manually set simulation steps
veh_z_offset = -3;
veh_x_offset = 0;
rx_z_offset = [2.3; 3.4; 3.4];
object_angle_offset = 0;    % Manually adjust the vehicle and Rx offset

setup_fn = 'empty_city';

% Old file
% old_dir = 'wi_setup/';
old_dir = '../ucsd_campus_large_scale_base/';   % This is where the "base" directory located
old_fn = strcat(old_dir, setup_fn);
old_setup_fn = strcat(old_fn, '.setup');        % Check all these files in the base directory before running the code
old_x3d_fn = strcat(old_fn, '.x3d.xml');
old_x3dgeometry_fn = strcat(old_fn, '.X3DGeometry.xml');
old_txrx_fn = strcat(old_fn, '.txrx');

for sim_idx = 1:100
    fprintf('Generating snapshot %d/%d\n', sim_idx, sim_num);
    %% Parameters
    sumo_fn = sprintf('%ssim_%d.mat', sumo_folder, sim_idx);
    load(sumo_fn);
    object_pos = object_pos + [veh_x_offset 0 veh_z_offset];
    
    %% Read file and create new files
    old_setup = fopen(old_setup_fn);
    old_x3d = fopen(old_x3d_fn);
    old_x3dgeometry = fopen(old_x3dgeometry_fn);
    old_txrx = fopen(old_txrx_fn);
    
    % New
    new_dir = sprintf('../../tmp/sim_%d/', sim_idx);        % This is where the generated simulation directories are located
    mkdir(new_dir);
    new_fn = strcat(new_dir, setup_fn);
    new_setup_fn = strcat(new_fn, '.setup');
    new_x3d_fn = strcat(new_fn, '.x3d.xml');
    new_x3dgeometry_fn = strcat(new_fn, '.X3DGeometry.xml');
    new_txrx_fn = strcat(new_fn, '.txrx');
    
    new_setup = fopen(new_setup_fn, 'w');
    new_x3d = fopen(new_x3d_fn, 'w');
    new_x3dgeometry = fopen(new_x3dgeometry_fn, 'w');
    new_txrx = fopen(new_txrx_fn, 'w');
    
    %% Copy files and change geometry locations
    % Copy *.city and ground
    source_fn = strcat(old_dir, 'empty_city.city');         % Building 3D models
    target_fn = strcat(new_dir, 'empty_city.city');
    copy_status_city = copyfile(source_fn, target_fn);
    
    source_fn = strcat(old_dir, 'ground.object');           % Ground 3D models, you can also copy other fixed 3D models
                                                            % (e.g. trees, road surfaces, etc) using the same format
    target_fn = strcat(new_dir, 'ground.object');
    copy_status_ground = copyfile(source_fn, target_fn);
    
    object_list_len = length(object_list);
    object_list_len = min(150, length(object_list));
    
    for obj_idx = 1:object_list_len
        % Copy files
        source_fn = sprintf('%s%d.object', old_dir, object_list(obj_idx));      % Vehicle 3D model
        target_fn = sprintf('%svehicle_%d.object', new_dir, obj_idx);           % Vehicle "object" in the generated simulation directory
        copy_status = copyfile(source_fn, target_fn);
        % Change geometry locations
        fprintf(' - Moving vehicle %d (out of %d)\n', obj_idx, object_list_len);
        moveObj(new_dir(1:end-1), ['vehicle_', num2str(obj_idx) ], object_pos(obj_idx,:), -object_angle(obj_idx)+object_angle_offset ,new_dir(1:end-1));
    end
    
    %% Identify the insertion point
    % write *.setup
    tline = fgetl(old_setup);
    while ischar(tline)
        if strcmp(tline, 'filename ./ground.object')        % Note: change it to the last fixed 3D object in your setup file
            fprintf(new_setup, '%s\r\n', tline);
            tline = fgetl(old_setup);
            fprintf(new_setup, '%s\r\n', tline);
            % Insert objects
            for obj_idx = 1:object_list_len
                fprintf(new_setup, 'begin_<feature>\r\n');
                fprintf(new_setup, 'feature %d\r\n', obj_idx+1);
                fprintf(new_setup, 'object\r\n');
                fprintf(new_setup, 'active\r\n');
                fprintf(new_setup, 'filename ./vehicle_%d.object\r\n', obj_idx);
                fprintf(new_setup, 'end_<feature>\r\n');
            end
        else
            fprintf(new_setup, '%s\r\n', tline);
        end
        tline = fgetl(old_setup);
    end
    
    % write *.x3d.xml
    tline = fgetl(old_x3d);
    while ischar(tline)
        % Insert objects
        if strcmp(tline, '          </remcom::rxapi::GeometryList>')
            for obj_idx = 1:object_list_len
                fprintf(new_x3d, '            <Geometry>\n');
                fprintf(new_x3d, '              <remcom::rxapi::Object>\n');
                fprintf(new_x3d, '                <GeometrySource>\n');
                fprintf(new_x3d, '                  <remcom::rxapi::WirelessInSiteGeometry>\n');
                fprintf(new_x3d, '                    <Filename>\n');
                fprintf(new_x3d, '                      <remcom::rxapi::FileDescription>\n');
                fprintf(new_x3d, '                        <Filename>\n');
                fprintf(new_x3d, '                          <remcom::rxapi::String Value="./vehicle_%d.object"/>\n', obj_idx);
                fprintf(new_x3d, '                        </Filename>\n');
                fprintf(new_x3d, '                        <FilenameChecksum>\n');
                fprintf(new_x3d, '                          <remcom::rxapi::String/>\n');
                fprintf(new_x3d, '                        </FilenameChecksum>\n');
                fprintf(new_x3d, '                      </remcom::rxapi::FileDescription>\n');
                fprintf(new_x3d, '                    </Filename>\n');
                fprintf(new_x3d, '                  </remcom::rxapi::WirelessInSiteGeometry>\n');
                fprintf(new_x3d, '                </GeometrySource>\n');
                fprintf(new_x3d, '              </remcom::rxapi::Object>\n');
                fprintf(new_x3d, '            </Geometry>\n');
            end
            fprintf(new_x3d, '%s\n', tline);
            % Insert Tx\Rx
        elseif strcmp(tline, '          </remcom::rxapi::TxRxSetList>')
            for obj_idx = 1:object_list_len
                txrx_set_config_fn = strcat(old_dir, 'txrxset_x3d.xml');
                txrx_set_config = fopen(txrx_set_config_fn);
                for line_num = 1:103
                    txrx_tline = fgetl(txrx_set_config);
                    if line_num == 11
                        fprintf(new_x3d, '                          <remcom::rxapi::Double Value="%.15f"/>\n', ...
                            object_pos(obj_idx, 1));
                    elseif line_num == 14
                        fprintf(new_x3d, '                          <remcom::rxapi::Double Value="%.15f"/>\n', ...
                            object_pos(obj_idx, 2));
                    elseif line_num == 17
                        fprintf(new_x3d, '                          <remcom::rxapi::Double Value="%.15f"/>\n', ...
                            object_pos(obj_idx, 3)+rx_z_offset(object_list(obj_idx)));
                    elseif line_num == 24
                        fprintf(new_x3d, '                  <remcom::rxapi::Integer Value="%d"/>\n', obj_idx+175);
                    elseif line_num == 97
                        fprintf(new_x3d, '                  <remcom::rxapi::String Value="vehicle %d receiver"/>\n', ...
                            obj_idx);
                    else
                        fprintf(new_x3d, '%s\n', txrx_tline);
                    end
                end
                fclose(txrx_set_config);
            end
            fprintf(new_x3d, '%s\n', tline);
        else
            fprintf(new_x3d, '%s\n', tline);
        end
        
        tline = fgetl(old_x3d);
    end
    
    % write *.X3DGeometry.xml
    tline = fgetl(old_x3dgeometry);
    while ischar(tline)
        % Insert objects
        if strcmp(tline, '          </remcom::rxapi::GeometryList>')
            for obj_idx = 1:object_list_len
                fprintf(new_x3dgeometry, '            <Geometry>\n');
                fprintf(new_x3dgeometry, '              <remcom::rxapi::Object>\n');
                fprintf(new_x3dgeometry, '                <GeometrySource>\n');
                fprintf(new_x3dgeometry, '                  <remcom::rxapi::WirelessInSiteGeometry>\n');
                fprintf(new_x3dgeometry, '                    <Filename>\n');
                fprintf(new_x3dgeometry, '                      <remcom::rxapi::FileDescription>\n');
                fprintf(new_x3dgeometry, '                        <Filename>\n');
                fprintf(new_x3dgeometry, '                          <remcom::rxapi::String Value="./vehicle_%d.object"/>\n', obj_idx);
                fprintf(new_x3dgeometry, '                        </Filename>\n');
                fprintf(new_x3dgeometry, '                        <FilenameChecksum>\n');
                fprintf(new_x3dgeometry, '                          <remcom::rxapi::String/>\n');
                fprintf(new_x3dgeometry, '                        </FilenameChecksum>\n');
                fprintf(new_x3dgeometry, '                      </remcom::rxapi::FileDescription>\n');
                fprintf(new_x3dgeometry, '                    </Filename>\n');
                fprintf(new_x3dgeometry, '                  </remcom::rxapi::WirelessInSiteGeometry>\n');
                fprintf(new_x3dgeometry, '                </GeometrySource>\n');
                fprintf(new_x3dgeometry, '              </remcom::rxapi::Object>\n');
                fprintf(new_x3dgeometry, '            </Geometry>\n');
            end
            fprintf(new_x3dgeometry, '%s\n', tline);
            % Insert Tx\Rx
        elseif strcmp(tline, '          </remcom::rxapi::TxRxSetList>')
            for obj_idx = 1:object_list_len
                txrx_set_config_fn = strcat(old_dir, 'txrxset_x3d.xml');
                txrx_set_config = fopen(txrx_set_config_fn);
                for line_num = 1:103
                    txrx_tline = fgetl(txrx_set_config);
                    if line_num == 11
                        fprintf(new_x3dgeometry, '                          <remcom::rxapi::Double Value="%.15f"/>\n', ...
                            object_pos(obj_idx, 1));
                    elseif line_num == 14
                        fprintf(new_x3dgeometry, '                          <remcom::rxapi::Double Value="%.15f"/>\n', ...
                            object_pos(obj_idx, 2));
                    elseif line_num == 17
                        fprintf(new_x3dgeometry, '                          <remcom::rxapi::Double Value="%.15f"/>\n', ...
                            object_pos(obj_idx, 3)+rx_z_offset(object_list(obj_idx)));
                    elseif line_num == 24
                        fprintf(new_x3dgeometry, '                  <remcom::rxapi::Integer Value="%d"/>\n', obj_idx+175);
                    elseif line_num == 97
                        fprintf(new_x3dgeometry, '                  <remcom::rxapi::String Value="Vehicle %d Rx"/>\n', ...
                            obj_idx);
                    else
                        fprintf(new_x3dgeometry, '%s\n', txrx_tline);
                    end
                end
                fclose(txrx_set_config);
            end
            fprintf(new_x3dgeometry, '%s\n', tline);
        else
            fprintf(new_x3dgeometry, '%s\n', tline);
        end
        tline = fgetl(old_x3dgeometry);
    end
    
    % Write *.txrx
    tline = fgetl(old_txrx);
    while ischar(tline)
        fprintf(new_txrx, '%s\r\n', tline);
        tline = fgetl(old_txrx);
    end
    
    for obj_idx = 1:object_list_len
        fprintf(new_txrx, 'begin_<points> vehicle %d receiver\r\n', obj_idx);
        fprintf(new_txrx, 'project_id %d\r\n', obj_idx+175);
        fprintf(new_txrx, 'active\r\nvertical_line no\r\npattern_shown no\r\ncube_size 0.25000\r\nCVxLength 10.00000\r\nCVyLength 10.00000\r\nCVzLength 10.00000\r\nAutoPatternScale\r\nShowDescription yes\r\nCVsVisible no\r\nCVsThickness 3\r\nbegin_<location> \r\nbegin_<reference> \r\ncartesian\r\nlongitude 0.000000000000000\r\nlatitude 0.000000000000000\r\nvisible no\r\nterrain\r\nend_<reference>\r\nnVertices 1\r\n');
        fprintf(new_txrx, '%.15f %.15f %.15f\r\n', ...
            object_pos(obj_idx, 1), object_pos(obj_idx, 2), ...
            object_pos(obj_idx, 3)+rx_z_offset(object_list(obj_idx)));
        fprintf(new_txrx, 'end_<location>\r\npattern_show_arrow no\r\npattern_show_as_sphere no\r\ngenerate_p2p yes\r\nuse_apg_acceleration yes\r\nis_transmitter no\r\nis_receiver yes\r\nbegin_<receiver> \r\nbegin_<pattern> \r\nantenna 0\r\nwaveform 0\r\nrotation_x 0.00000\r\nrotation_y 0.00000\r\nrotation_z 0.00000\r\nend_<pattern>\r\nNoiseFigure 3.00000\r\nend_<receiver>\r\npowerDistribution Uniform 10.00000 10.00000 inactive nosampling 10\r\nend_<points>\r\n');
    end
    
    fclose('all');
end