function [G, p_true, P_true] = generate_random_data()
% Generate random 3D data for testing.

% Input:
%   None

% Output:
%   G - (n×3) centered 3D point set
%   p_true - (3×1) random local parameter vector
%   P_true - (3×1) random global parameter vector

    G = rand(randi([4, 200]),3);
    G = G - mean(G,1);
    p_true = rand(3,1);
    P_true = rand(3,1);
end
