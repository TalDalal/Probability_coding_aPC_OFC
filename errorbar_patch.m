function h = errorbar_patch(x,y,er,c, lineStyle)
%ERRORBAR_PATCH    - errorbar by patch
%
% ERRORBAR_PATCH(x,y,er,c) plots the graph of vector x vs. vector y with
%   error bars specified by the vector er.
%
%   input
%     - x:    
%     - y:    mean
%     - er:   error bar
%     - c:    color (vector of three values)
%
% eg.) 
%    x = [1 2 3 4];
%    y = [4 5 4 3];
%    er = [1.2 1.5 1 1.1];
%    c = [1 0 0];
%    errorbar_patch(x,y,er,c)
%
if nargin <5
    lineStyle = '-';
end
 
if nargin < 4
    c = [0 0 1];
end
if size(x,1)>size(x,2); x = x'; end
if size(y,1)>size(y,2); y = y'; end
 
X = [x fliplr(x)];
Y = [y+er fliplr(y-er)];
 

%h2 = plot(x,y,c,'LINEWIDTH', 2);  %RAafi: old: 
h1 = patch(X,Y,c,'edgecolor','none','FaceAlpha',0.2); hold on  % this line cause the x and y acis fonts to flip...
hold on;
h2 = plot(x,y,'color',c,'LINEWIDTH', 1.5, 'LineStyle', lineStyle);%I chanced to support dash lines

 
if nargout>0, h = [h1 h2]; end