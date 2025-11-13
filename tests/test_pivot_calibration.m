function tests = test_pivot_calibration
    addpath('../programs');
    tests = functiontests(localfunctions);
end

%% --- PA1 BASIC FUNCTIONALITY TESTS ---

function testTwoIdenticalFrames(testCase)
    % Two identical frames should fail
    frame = rand(5,3);
    frames = {frame, frame};
    verifyError(testCase, @() pivot_calibration(frames), ...
        'MATLAB:SingularSystem');
end

function testTooFewFrames(testCase)
    % Error when fewer than 2 frames are provided
    base_geometry = [0 0 0; 1 0 0; 0 1 0];
    frames = {base_geometry};
    testCase.verifyError(@() pivot_calibration(frames), ...
        'MATLAB:NeedAtLeast2Frames');
end


function testRandomFramesRunWithoutError(testCase)
    % Check random frames run without crashing
    frames = cell(1,5);
    [G, ~, ~] = generate_random_data();
    for k = 1:5
        [frame, ~, ~] = generate_random_pivot(G);
        frames{k} = frame;
    end
    [p, P] = pivot_calibration(frames);
    verifySize(testCase, p, [3 1]);
    verifySize(testCase, P, [3 1]);
end


function testKnownSyntheticSolution(testCase)
    [G, p_true, P_true] = generate_random_data();

    M = randi([3, 500]);
    frames = cell(1, M);
    
    for k = 1:M
        [frame, R, ~] = generate_random_pivot(G, P_true, p_true);
        frames{k} = frame;
        if k == 1
            R1 = R;
        end
    end

    [p_est, P_est] = pivot_calibration(frames);
    p_true = R1 * p_true;
    
    verifyLessThan(testCase, norm(p_est - p_true), 1e-15, ...
        'Probe tip estimate is not accurate enough');
    verifyLessThan(testCase, norm(P_est - P_true), 1e-15, ...
        'Tracker post location estimate is not accurate enough');

end


function testTranslationInvariance(testCase)
    % Shifting all frames in tracker space should shift P_tracker, but not
    % change p_probe
    seed = randi([10, 200]);
    rng(seed);
    [G, p_true, P_true] = generate_random_data();

    M = randi([10, 200]);
    frames = cell(1, M);
    for k = 1:M
        [frame, ~, ~] = generate_random_pivot(G, P_true, p_true);
        frames{k} = frame;
    end

    % Add known translation diff to every frame
    delta = randn(3, 1);
    frames_translated = cellfun(@(F) F + delta', frames, 'UniformOutput', false);

    [p_est_1, P_est_1] = pivot_calibration(frames);
    [p_est_2, P_est_2] = pivot_calibration(frames_translated);

    % p_tip (local coords) should be unchanged
    verifyEqual(testCase, p_est_2, p_est_1, 'AbsTol', 1e-10);

    % P_tip (tracker coordinates) should shift by delta
    verifyEqual(testCase, P_est_2, P_est_1 + delta, 'AbsTol', 1e-10);
end


function testDegenerateMarkers(testCase)
    % all points are collinear or repeated — rigid registration should fail
    base_geometry = [0 0 0; 1 0 0; 2 0 0];
    frames = {base_geometry, base_geometry + [0 1 0]};
    
    % error!
    verifyError(testCase, @() pivot_calibration(frames), 'MATLAB:SingularSystem');
end
