function tests = test_frame_registration
    addpath('../programs');
    tests = functiontests(localfunctions);
end

function test_translation(testCase)
    % Checks that when only translation is applied to a point cloud, 
    % the registration algorithm recovers the translation vector 
    % and the transformed cloud with extremely small error.
    [A, ~, ~, t_true] = create_point_cloud();
    R_true = eye(3);
    E_true = [R_true t_true; 0 0 0 1];
    B = apply_transform(E_true, A);

    [~, ~, E] = point_cloud_registration(A, B);
    R = E(1:3,1:3); 
    t = E(1:3,4);

    angle_err = compute_angle_err(R_true, R);
    translation_err = norm(t - t_true);

    testCase.verifyLessThanOrEqual(angle_err, 1e-7);
    testCase.verifyLessThanOrEqual(translation_err, 1e-9);

    A_aligned = apply_transform(E, A);
    testCase.verifyLessThanOrEqual(mse_error(A_aligned, B), 1e-10);
end

function test_rotation(testCase)
    % Checks that when only rotation is applied, 
    % the registration algorithm correctly estimates the rotation matrix, 
    % maintaining nearly zero angle error after alignment.
    [A, ~, R_true, ~] = create_point_cloud();
    t_true = [0; 0; 0];
    E_true = [R_true t_true; 0 0 0 1];
    B = apply_transform(E_true, A);

    [~, ~, E] = point_cloud_registration(A, B);
    R = E(1:3, 1:3); 
    t = E(1:3, 4);

    angle_err = compute_angle_err(R_true, R);
    translation_err = norm(t - t_true);

    testCase.verifyLessThanOrEqual(angle_err, 1e-6);
    testCase.verifyLessThanOrEqual(translation_err, 1e-9);

    A_aligned = apply_transform(E, A);
    testCase.verifyLessThanOrEqual(mse_error(A_aligned, B), 1e-10);
end

function test_noise_robustness_small_sigma(testCase)
    % Checks the algorithm's robustness to Gaussian noise 
    % by ensuring that alignment error decreases after registration 
    % and that the recovered transformation remains close to the ground truth 
    % despite noise.
    [A, B_clean, R_true, t_true] = create_point_cloud();

    sigma = 1e-3;
    B_noisy = B_clean + sigma * randn(size(B_clean));

    [~, ~, E] = point_cloud_registration(A, B_noisy);
    A_aligned = apply_transform(E, A);

    mse_before = mse_error(A, B_noisy);
    mse_after  = mse_error(A_aligned, B_noisy);

    testCase.verifyLessThan(mse_after, mse_before);
    ang_err = compute_angle_err(R_true, E(1:3,1:3));
    trans_err = norm(E(1:3,4) - t_true);
    testCase.verifyLessThanOrEqual(ang_err, 0.1);
    testCase.verifyLessThanOrEqual(trans_err, 1e-2);
end

function test_small_sets_minimal_points(testCase)
    % Checks that the algorithm works correctly on the minimal 
    % number of non-collinear points, 
    % correctly recovering the original transformation 
    % and achieving minimal error.
    A = [0 0 0; 1 0 0; 0 1 0]; % non-collinear
    [R_true, t_true] = randFrame();
    E_true = [R_true t_true; 0 0 0 1];
    B = apply_transform(E_true, A);

    [~, ~, E] = point_cloud_registration(A, B);
    A_aligned = apply_transform(E, A);

    testCase.verifyLessThanOrEqual(mse_error(A_aligned, B), 1e-10);
end

function test_degenerate_sets_should_fail_or_warn(testCase)
    % For collinear points, rotation about the line is unidentified
    A = [0 0 0; 1 0 0; 2 0 0; 3 0 0]; % collinear
    [R_true, t_true] = randFrame();
    E_true = [R_true t_true; 0 0 0 1];
    B = apply_transform(E_true, A);

    try
        [R, ~, E] = point_cloud_registration(A, B);
        testCase.verifyLessThanOrEqual(compute_angle_err(R'*R, eye(3)), 1e-6);
        A_aligned = apply_transform(E, A);
        testCase.verifyLessThan(mse_error(A_aligned, B), mse_error(A, B));
    catch ME
        testCase.verifyTrue(contains(ME.identifier, "registration") || ...
                            contains(lower(ME.message),'degenerate'), ...
                            'If thrown, use a ME message.');
    end
end

function test_equivariance_global_transform(testCase)
    % Checks that when both point clouds are transformed 
    % by the same SE(3) pose, 
    % the relative transform between them remains unchanged.
    [A, B, ~, ~] = create_point_cloud();

    [Rg, tg] = randFrame();
    G = [Rg tg; 0 0 0 1];
    G_inv = inv_homog(G);

    A_g = apply_transform(G, A);
    B_g = apply_transform(G, B);

    [~, ~, E] = point_cloud_registration(A, B);
    [~, ~, E_g] = point_cloud_registration(A_g, B_g);

    testCase.verifyLessThanOrEqual(norm(G * E * G_inv - E_g, 'fro'), 1e-8);
end

function test_left_inverse_property(testCase)
    % Checks that applying the evaluated transform 
    % followed with its inverse correctly 
    % recovers the original point cloud.
    [A, B, ~, ~] = create_point_cloud();

    [~, ~, E] = point_cloud_registration(A, B);
    E_inv = inv_homog(E);

    A2 = apply_transform(E_inv, B);
    testCase.verifyLessThanOrEqual(mse_error(A2, A), 1e-10);
end
