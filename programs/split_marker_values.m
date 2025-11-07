function samples = split_marker_values(samples, bodyA, bodyB)
% Splits the all_markers array into A, B, and D markers
% Inputs:
%   samples - struct containing all_markers and N_samps
%   bodyA, bodyB - structs containing N_markers
% Output:
%   samples - updated struct with N_A, N_B, N_D, A_markers, B_markers, D_markers

    samples.N_A = bodyA.N_markers;
    samples.N_B = bodyB.N_markers;
    samples.N_D = samples.N_S - samples.N_A - samples.N_B;

    % Split the all_markers array
    samples.A_markers = samples.all_markers(1:samples.N_A, :, :);
    samples.B_markers = samples.all_markers(samples.N_A+1:samples.N_A+samples.N_B, :, :);

    if samples.N_D > 0
        samples.D_markers = samples.all_markers(samples.N_A+samples.N_B+1:end, :, :);
    else
        samples.D_markers = zeros(0, 3, samples.N_samps);
    end
end
