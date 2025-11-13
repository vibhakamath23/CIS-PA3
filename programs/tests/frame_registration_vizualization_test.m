function frame_registration_vizualization_test(seed)
% Visualization test for frame registration.

% Input:
%   seed - random seed for reproducibility

% Output:
%   None (displays visualizations and prints registration errors)

    addpath('../programs');
    rng(seed);
    
    [A] = create_point_cloud();

    R_target = quat2rotm(randrot);
    t_target = randn(3, 1);
    E_target = [R_target t_target; 0 0 0 1];
    A_target_proj = apply_transform(E_target, A);

    [~, ~, E_pred] = point_cloud_registration(A, A_target_proj);
    A_pred_proj = apply_transform(E_pred, A);

    mse_before = mse_error(A_target_proj, A);
    mse_after  = mse_error(A_target_proj, A_pred_proj);
    
    rotation_err = compute_angle_err(R_target, E_pred(1:3, 1:3));
    translation_err = mse_error(E_pred(1:3, 4), t_target);
    
    fprintf('--- Frame Registration Report ---\n');
    fprintf('MSE before align    : %.2f\n', mse_before);
    fprintf('MSE after align     : %.2f\n', mse_after);
    fprintf('Rotation error (deg) : %.2f\n', rotation_err);
    fprintf('Translation error    : %.2f\n', translation_err);
    

    figure('Color','w','Name','Frame Registration Test'); clf;
    subplot(1,2,1); 
    hold on; 
    grid on; 
    axis equal;
    title('Before alignment');
    scatter3(A(:,1), A(:,2), A(:,3), 'filled', 'Marker', 'o', 'MarkerFaceAlpha', 0.8);
    scatter3(A_target_proj(:,1), A_target_proj(:,2), A_target_proj(:,3), 'filled', 'Marker', 'square', 'MarkerFaceAlpha', 0.9); % B
    legend('A source','A target','Location','best'); view(45,30);
    xlabel('X'); ylabel('Y'); zlabel('Z');

    subplot(1,2,2); 
    hold on; 
    grid on; 
    axis equal;
    title(sprintf('After alignment (MSE=%.4g)', mse_after));
    scatter3(A_pred_proj(:,1), A_pred_proj(:,2), A_pred_proj(:,3), 'filled','Marker', 'diamond', 'MarkerFaceAlpha', 1);
    scatter3(A_target_proj(:,1), A_target_proj(:,2), A_target_proj(:,3), 'filled','Marker', 'square', 'MarkerFaceAlpha', 0.5);
    legend('A predicted projection','A target','Location','best'); view(45,30);
    xlabel('X'); ylabel('Y'); zlabel('Z');

end
