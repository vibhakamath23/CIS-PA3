function [R,t,F] = point_cloud_registration(point_cloud1, point_cloud2)
% Computes the transformation (Rotation R and translation t) that aligns two 
% corresponding point sets. Used by Problems 4a and 4b.
%
% Inputs:
%     point_cloud1 - N x 3 source
%     point_cloud2 - N x 3 observed
%
% Outputs: 
%     R - rotation matrix (3 x 3)
%     t - translation vector (3 x 1)
%     F - combined R, t transform frame F

    % calculate the centroids for each point cloud
    point_cloud1 = point_cloud1.';
    point_cloud2 = point_cloud2.';
    centroid_EM = mean(point_cloud1, 2);
    centroid_OPT = mean(point_cloud2, 2);
    point_cloud1 = point_cloud1 - centroid_EM;
    point_cloud2 = point_cloud2 - centroid_OPT;
    
    H = point_cloud1 * point_cloud2.';
    [U, S, V] = svd(H);

% rotation and translation components
    R = V * U.';
    t = centroid_OPT - R * centroid_EM;

% combined transform frame
    F = [R t; 0 0 0 1];
end
    
    
