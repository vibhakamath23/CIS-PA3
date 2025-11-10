function [d_k] = dk_from_sample_input(samples, bodyA, bodyB)
% Computes pointer tip positions and closest mesh points
% Inputs:
%   samples - struct containing split marker arrays
%   bodyA, bodyB - structs with tip positions and marker locations
%   mesh - surface mesh structure
% Outputs:
%   d_k - pointer tip positions in bone frame (N_samps x 3)
%   c_k - closest points on mesh (N_samps x 3)
%   diff_mag - distance between d_k and c_k (N_samps x 1)

    N = samples.N_samps;
    d_k = zeros(N, 3);

    for k = 1:N
        % Get LED marker positions for this frame
        a_markers = samples.A_markers(:, :, k);  % N_A x 3
        b_markers = samples.B_markers(:, :, k);  % N_B x 3

        % Compute rigid body transformations
        [~, ~, F_A] = point_cloud_registration(bodyA.markers, a_markers);
        [~, ~, F_B] = point_cloud_registration(bodyB.markers, b_markers);

        % Pointer tip position in tracker frame
        A_tip_hom = [bodyA.tip'; 1];
        A_tip_tracker = F_A * A_tip_hom;

        % Transform to bone frame
        F_B_inv = inv_homog(F_B);
        d_k_hom = F_B_inv * A_tip_tracker;
        d_k(k, :) = d_k_hom(1:3)';
        
    end
end

