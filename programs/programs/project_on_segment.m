function point = project_on_segment(c, p, q)
% Projects a point onto a line segment, clamping the result to segment endpoints.
%
% Inputs: 
%   c (1 × 3 point to project), p, q (1 × 3 segment endpoints)
% Outputs: 
%   point (1 × 3 projection on segment [p, q])

    lambda = dot((c - p), (q - p)) / dot((q - p), (q - p));
    lambda_seg = max(0,min(lambda,1));
    point = p + lambda_seg * (q - p);
end
