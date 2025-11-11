% pa3.m
% Main script for Programming Assignment 3
% Implements the matching part of the ICP algorithm
% Aiza Maksutova and Vibha Kamath
% 
%
% Usage: pa3('a') or pa3('b') or pa3('c') etc.
% Or just run: pa3 (will prompt for letter)

function pa3(mode, letter_index)
    if nargin < 2
        error("Please provide the problem to solve as an argument. Example: pa3('debug', 'a')");
    end
    
    if ~ischar(mode) && ~isstring(mode)
        error("Mode must be a string or character array. Expected 'debug' or 'unknown'.");
    end
    
    if ~ischar(letter_index) && ~isstring(letter_index)
        error("Letter index must be a string or character array. Expected a single letter.");
    end
    
    mode = lower(char(mode));
    letter_index = lower(char(letter_index));
    
    if ~ismember(mode, {'debug', 'unknown'})
        error("Mode must be either 'debug' or 'unknown'. Got: '%s'", mode);
    end
    
    if length(letter_index) ~= 1
        error("Letter index must be a single character. Got: '%s'", letter_index);
    end
    
    if strcmp(mode, 'debug')
        if letter_index < 'a' || letter_index > 'f'
            error("Debug mode only supports letters 'a' through 'f'. Got: '%s'", letter_index);
        end
    elseif strcmp(mode, 'unknown')
        if letter_index < 'g' || letter_index > 'k'
            error("Unknown mode only supports letters 'g' through 'k'. Got: '%s'", letter_index);
        end
    end
    
    % Directory config
    data_dir = 'Data';
    output_dir = './outputs';
    
    % Create output directory if it doesn't exist
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    % Construct filenames
    bodyAFile = fullfile(data_dir, 'Problem3-BodyA.txt');
    bodyBFile = fullfile(data_dir, 'Problem3-BodyB.txt');
    meshFile = fullfile(data_dir, 'Problem3Mesh.sur');
    
    % Construct sample file name based on mode
    if strcmp(mode, 'debug')
        sample_filename = sprintf('PA3-%s-Debug-SampleReadingsTest.txt', upper(letter_index));
    else
        sample_filename = sprintf('PA3-%s-Unknown-SampleReadingsTest.txt', upper(letter_index));
    end
    sampleFile = fullfile(data_dir, sample_filename);
    
    fprintf('PA3: Reading input files...\n');
    
    % Read rigid body definitions
    bodyA = read_body_file(bodyAFile);
    bodyB = read_body_file(bodyBFile);
    
    % Read surface mesh
    mesh = read_mesh_file(meshFile);
    
    % Read sample readings
    samples = read_sample_file(sampleFile, bodyA, bodyB);

    % Process each sample frame and get d_k points
    [d_k] = dk_from_sample_input(samples, bodyA, bodyB);

    % Closest points on mesh to d_k, since assuming F_reg = I
    N = samples.N_samps; 
    c_k = zeros(N, 3);
    diff_mag = zeros(N, 1);

    build_time = 0; % to keep track of build time for data structures

    % Choose search method: 'linear', 'octree', or 'boundingSphere'
    search_method = 'boundingSphere';   % <--- just change this line
    
    % assign corresponding function decl
    for k = 1:N
        switch search_method
            case 'linear'
                t_query_start = tic;
                c_k(k, :) = find_closest_point_mesh(d_k(k, :), mesh);
            case 'octree'
                t_build_start = tic; 

                if ~isfield(mesh, 'octree')
                mesh.octree = build_octree(mesh);
                end

                build_time = toc(t_build_start);
                
                t_query_start = tic; % keep track of query time
                c_k(k, :) = search_octree(d_k(k, :), mesh.octree, mesh);
            case 'boundingSphere'
                t_build_start = tic;

                if ~isfield(mesh, 'bounding_spheres')
                    mesh = precompute_bounding_spheres(mesh);
                end
                build_time = toc(t_build_start);
                
                t_query_start = tic;
                c_k(k, :) = bounding_sphere_find_closest_point_mesh(d_k(k, :), mesh);
            otherwise
                error('Unknown search method: %s', search_method);
        end
    
        % Difference magnitude
        diff_mag(k) = norm(d_k(k, :) - c_k(k, :));
        query_time = toc(t_query_start);
    end
     
    fprintf('Writing output file...\n');
    
    % Write output file
    output_filename = sprintf('pa3-%s-%s-Output.txt', letter_index, mode);
    outputFile = fullfile(output_dir, output_filename);
    write_output3(output_filename, samples.N_samps, d_k, c_k, diff_mag)
    fprintf('Output written to: %s\n', outputFile);
    
    % Write aux File
    write_aux_file(letter_index, mode, search_method, ...
    outputFile, data_dir, output_dir, ...
    build_time, query_time, diff_mag);
end

