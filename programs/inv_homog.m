function E_inv = inv_homog(E)
% Invert frame transform 
% Input:
%     E: (4, 4), original frame transform
% Output:
%     E_inv: (4, 4), inverse frame transform
    t = E(1:3, 4);
    rot = E(1:3, 1:3);
    E_inv = [rot.' -rot.' * t; 0 0 0 1];
end
