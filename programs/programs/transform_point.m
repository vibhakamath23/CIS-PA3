function p_out = transform_point(F, p_in)
% transformPoint - Applies homogeneous transformation to a point
%
% Input:
%   F - 4x4 homogeneous transformation matrix
%   p_in - 1x3 or 3x1 point vector
%
% Output:
%   p_out - 1x3 transformed point (row vector)
%
% Transformation: p_out = F.R * p_in + F.p

    % check p_in is a column vector
    if size(p_in, 1) == 1
        p_in = p_in';
    end
    
    % extract rotation and translation
    R = F(1:3, 1:3);
    p = F(1:3, 4);
    
    % apply transform
    p_out = (R * p_in + p)';  % return as row vector
end
