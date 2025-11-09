function point = project_on_segment(c, p, q)
    lambda = dot((c - p), (q - p)) / dot((q - p), (q - p));
    lambda_seg = max(0,min(lambda,1));
    point = p + lambda_seg * (q - p);
end