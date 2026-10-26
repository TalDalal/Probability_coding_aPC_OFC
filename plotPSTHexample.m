figure;
k = 67;
highRaster = High_responding_exc_struct(k).rasterHigh;
lowRaster = Low_responding_exc_struct(k).rasterLow;
hold all
subplot(4,1,1)
for i = 1:size(highRaster,2)
    scatter(highRaster(i).times, i.*ones(1, length(highRaster(i).times)), 5, 'MarkerFaceColor', highProbColor, 'MarkerEdgeColor', 'none')
    hold on
end
xlim([-3 0]);axis off

subplot(4,1,2)
for i = 1:size(lowRaster,2)
    scatter(lowRaster(i).times, i.*ones(1, length(lowRaster(i).times)), 5, 'MarkerFaceColor', lowProbColor, 'MarkerEdgeColor', 'none')
    hold on
end
xlim([-3 0])
axis off

subplot(4,1,3:4)
mypsth(High_responding_exc_struct(k).rasterHigh, 0.05, highProbColor)
hold on;
mypsth(Low_responding_exc_struct(k).rasterLow, 0.05, lowProbColor)
xlim([-3 0])
set(gca, 'FontSize', 14);box off;
xlabel('Time relative to CS (S)');ylabel('Firing rate (Hz)')