function venn_diagram_with_percentages(n1, n2, nIntersect)
% venn_diagram_with_percentages plots a Venn diagram given the size of two groups
% and the size of their intersection, displaying the percentage of each part.
%
% INPUTS:
% - n1: Size of the first group
% - n2: Size of the second group
% - nIntersect: Size of the intersection between the two groups

% Calculate unique counts for each set
nUnique1 = n1 - nIntersect;
nUnique2 = n2 - nIntersect;

% Calculate total size
total = nUnique1 + nUnique2 + nIntersect;

% Calculate percentages
percent1 = (nUnique1 / total) * 100;
percent2 = (nUnique2 / total) * 100;
percentIntersect = (nIntersect / total) * 100;

% Plot the Venn diagram
figure;
venn([n1, n2], nIntersect);
hold on;

% Add text for each part with percentages
text(-0.4, 0, sprintf('%.1f%%', percent1), 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', 'b');
text(0.4, 0, sprintf('%.1f%%', percent2), 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', 'r');
text(0, 0, sprintf('%.1f%%', percentIntersect), 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', 'k');

hold off;
axis off;
end
