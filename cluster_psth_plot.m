function cluster_psth_plot(psth_matrix, num_clusters, method, time_vector, compare_matrix)
% cluster_psth_plot - Cluster PSTHs, overlay comparison, and show sorted matrices
%
% Inputs:
%   psth_matrix     - [neurons x time] matrix for clustering
%   num_clusters    - (optional) number of clusters (default: 4)
%   method          - (optional) 'hierarchical' or 'kmeans' (default: 'hierarchical')
%   time_vector     - (optional) time vector for x-axis
%   compare_matrix  - (optional) another matrix (same size) to overlay & show sorted

if nargin < 2 || isempty(num_clusters)
    num_clusters = 4;
end
if nargin < 3 || isempty(method)
    method = 'hierarchical';
end
if nargin < 4 || isempty(time_vector)
    time_vector = 1:size(psth_matrix, 2);
end
if nargin < 5
    compare_matrix = [];
end

firstOdorTimes = [-2 -1];
secondOdorTimes = [0 1];

% Validate
if ~isempty(compare_matrix) && any(size(compare_matrix) ~= size(psth_matrix))
    error('compare_matrix must be the same size as psth_matrix.');
end

% Colors
color_main = [0, 169, 137] / 255;
color_compare = [171, 62, 143] / 255;
cluster_colors = hsv(num_clusters);
cluster_colors = cluster_colors(randperm(num_clusters), :);

% --- Clustering
switch lower(method)
    case 'hierarchical'
        Y = pdist(psth_matrix, 'correlation');
        Z = linkage(Y, 'average');
        cluster_idx = cluster(Z, 'maxclust', num_clusters);
    case 'kmeans'
        cluster_idx = kmeans(psth_matrix, num_clusters, ...
            'Distance', 'correlation', 'Replicates', 10);
    otherwise
        error('Unsupported clustering method.');
end

% --- Plot 1: Cluster means
cols = ceil(sqrt(num_clusters));
rows = ceil(num_clusters / cols);
figure;

for c = 1:num_clusters
    subplot(rows, cols, c);
    hold on;

    clust_data = psth_matrix(cluster_idx == c, :);
    mean_psth = mean(clust_data, 1);
    plot(time_vector, mean_psth, '-', 'Color', color_main, 'LineWidth', 2);
    
    hold all
    %first odor
    plot([firstOdorTimes(1) firstOdorTimes(1)], [-.5  2], 'k--')
    plot([firstOdorTimes(2) firstOdorTimes(2)], [-.5  2], 'k--')
    
    %second odor
    plot([secondOdorTimes(1) secondOdorTimes(1)], [-.5  2], 'k--')
    plot([secondOdorTimes(2) secondOdorTimes(2)], [-.5  2], 'k--')
    
    if ~isempty(compare_matrix)
        compare_data = compare_matrix(cluster_idx == c, :);
        mean_compare = mean(compare_data, 1);
        plot(time_vector, mean_compare, '-', 'Color', color_compare, 'LineWidth', 2);
    end

    title(sprintf('Cluster %d\nn = %d', c, size(clust_data, 1)), ...
        'FontSize', 10, 'Color', cluster_colors(c,:));
    xlim([min(time_vector), max(time_vector)]);
    hold off;
end

% Shared labels
han = axes('Position',[0 0 1 1],'Visible','off');
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
xlabel(han, 'Time');
ylabel(han, 'Z-scored activity');
title(han, 'Clustered PSTHs (Mean Only)', 'FontSize', 14, 'FontWeight', 'bold');

% --- Plot 2: Sorted heatmaps
[~, sort_idx] = sort(cluster_idx);
sorted_psth = psth_matrix(sort_idx, :);
sorted_compare = [];
if ~isempty(compare_matrix)
    sorted_compare = compare_matrix(sort_idx, :);
end
sorted_cluster_idx = cluster_idx(sort_idx);

figure;

% Left subplot: sorted psth_matrix
subplot(1,2,1);
imagesc(time_vector, 1:size(sorted_psth,1), sorted_psth);
% colormap(gca, parula);
colorbar;
xlabel('Time relative to CS (sec)');
ylabel('Neurons (sorted)');
% colormap(slanCM('magma'))
caxis([-1.5 3])
hold all
%first odor
plot([firstOdorTimes(1) firstOdorTimes(1)], [size(sorted_psth,1)  1], 'w--')
plot([firstOdorTimes(2) firstOdorTimes(2)], [size(sorted_psth,1)  1], 'w--')

%second odor 
plot([secondOdorTimes(1) secondOdorTimes(1)], [size(sorted_psth,1)  1], 'w--')
plot([secondOdorTimes(2) secondOdorTimes(2)], [size(sorted_psth,1)  1], 'w--')
title('H')
set(gca, 'FontSize', 18);box off;

% Add colored cluster patches
hold on;
for c = 1:num_clusters
    rows_in_c = find(sorted_cluster_idx == c);
    for r = rows_in_c'
        patch_x = [time_vector(end)+0.5, time_vector(end)+1];
        patch_y = [r - 0.5, r + 0.5];
        fill(patch_x([1 1 2 2]), patch_y([1 2 2 1]), cluster_colors(c,:), ...
            'EdgeColor', 'none');
    end
end
xlim([min(time_vector), max(time_vector)+1]);
hold off;

% Right subplot: sorted compare_matrix
if ~isempty(sorted_compare)
    subplot(1,2,2);
    imagesc(time_vector, 1:size(sorted_compare,1), sorted_compare);
%     colormap(gca, parula);
    colorbar;
    xlabel('Time relative to CS (sec)');
    ylabel('Neurons (sorted)');
    title('Sorted Compare Matrix');

    caxis([-1.5 3])
    hold all
    %first odor
    plot([firstOdorTimes(1) firstOdorTimes(1)], [size(sorted_psth,1)  1], 'w--')
    plot([firstOdorTimes(2) firstOdorTimes(2)], [size(sorted_psth,1)  1], 'w--')
    
    %second odor
    plot([secondOdorTimes(1) secondOdorTimes(1)], [size(sorted_psth,1)  1], 'w--')
    plot([secondOdorTimes(2) secondOdorTimes(2)], [size(sorted_psth,1)  1], 'w--')
    title('L')
    set(gca, 'FontSize', 18);box off;
    colormap(slanCM('magma'))
end

end

