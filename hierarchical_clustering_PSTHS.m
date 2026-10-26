function [] = hierarchical_clustering_PSTHS(allMiceData)
numOfClusters = 14;
[high_mat, low_mat, t] = z_scored_neurons_matrix(allMiceData, [-4 -3], 'allTrials', 'PC');

cluster_psth_plot(high_mat, numOfClusters, 'hierarchical', t, low_mat)