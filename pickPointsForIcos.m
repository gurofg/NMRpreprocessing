function vektor = pickPointsForIcos(matrix)
% A function for making intervals (segments) for aligning by icoshift
%vektor = pickPointsForIcos(matrix)
% Input: Matrix
% Output: a vector of start and end points for each segment
% EB og GFG, 2011

%Choose areas to zoom in to 
[a,b] = size(matrix);
maxY = (max(max(matrix))/15);
plot(matrix')
fprintf('pick regions to zoom in by cliciking, finish by pressing return\n');
ylim([-10 maxY]);
[x,y] = ginput;
x = [1;x;b];
x = x';
x = round(x);
points = [];
vektor = [];
temp = [];


% Look at each area individually and choose segments

fprintf('pick regions to align by clicking\n');
for i = 1:(length(x)-1)
    plot((x(i):x(i+1)),matrix(:,[x(i):x(i+1)])')
    [region,yy] = ginput;
    temp = [temp;region];
end

temp = round(temp)';
temp2 = temp+1;




for j = 1:length(temp)
    vektor = [vektor,temp(j), temp2(j)];
end

vektor = [1,vektor,b];

end




