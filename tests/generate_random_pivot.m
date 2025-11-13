function [frame, R, t] = generate_random_pivot(G, P_true, p_true)
% Generate a random pivot frame by applying a random rotation and translation.

% Input:
%   G - (n×3) 3D point set
%   P_true - (3×1) optional global tip position
%   p_true - (3×1) optional local tip position

% Output:
%   frame - (n×3) transformed point set
%   R - (3×3) rotation matrix
%   t - (3×1) translation vector

    if nargin < 3 || isempty(p_true)
        p_true = 0.1 * randn(3,1);  % random local tip position
    end
    if nargin < 2 || isempty(P_true)
        P_true = randn(3,1);        % random global tip position
    end
    axis = rand(3,1); axis = axis / norm(axis);
    theta = rand * 2 * pi;
    R = axisAngleToRotm(axis, theta);
    t = P_true - R * p_true;
    frame = (R * G.' + t).';
end
