function [d_k] = dk_from_sample_input(samples, bodyA, bodyB)
% compute pointer tip positions wrt to rigid body B frame
% input:
%   samples - struct containing split marker arrays
%   bodyA, bodyB - structs with tip positions and marker locations

% Output:
%   d_k - pointer tip positions in bone frame (N_samps x 3)

    A_markers_body = bodyA.markers; % coords of markers A in body frame
    B_markers_body = bodyB.markers; % coords of markers B in body frame
    A_tip = bodyA.tip;
    n_frames = samples.N_samps; 
    d_k = zeros(n_frames, 3);
    for i=1:n_frames
        % compute frame transform F_A (from body A to tracker)
        [~, ~, F_A] = point_cloud_registration(A_markers_body, ...
                                                    samples.A_markers(:, :, i));
        % compute frame transform F_B (from body B to tracker)
        [~, ~, F_B] = point_cloud_registration(B_markers_body, ...
                                                    samples.B_markers(:, :, i));
        % compute frame transform from body A to body B
        frame_transform_i = inv_homog(F_B) * F_A;
        % get positions of pointer tip wrt body B
        d_k(i, :) = transform_point(frame_transform_i, A_tip);
    end
end

