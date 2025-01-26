% The network consists in 15 stops and consisting in 18 bus routes (see final plot).
% Each route is defined by the succession of bus stops and it circulates in both directions.
clear
format compact
format free % free %(default) or % format short %(5 digits) or % format bank %(2 digits after comma)

ROUTE18={{'3','6','15','7','10','11'},{'2','3','6','8','15','7','10','11'},{'10','13','14','9'},{'1','2','4','6'},{'10','11','12'},{'9','15','7','10'},{'5','4','6','8','10'},{'1','2','3','6','8','10','13'},{'9','15','6','4','12','11'},{'1','9','8','10','11'},{'4','12','11','10'},{'1','5','4','6','15','7','10'},{'14','10','7','15','8','6','4','5'},{'9','15','7','10','11','12','4','2'},{'1','4','11','13'},{'1','3','15','14'},{'1','5','12','13'},{'3','2','5','4','6','8','10','11'}};

Travel18={{3,3,2,7,5},{4,6,10,8,8,7,5},{8,2,10},{8,3,4},{5,10},{8,2,7},{4,4,2,8},{8,2,3,2,8,10},{9,15,6,4,12,11},{1,2,8,10,11},{4,12,11,10},{1,5,4,6,15,7,10},{14,10,7,15,8,6,4,5},{9,15,7,10,11,12,4,2},{7,11,8,15},{7,8,10,14},{14,7,13,14},{9,15,12,7,9,17,6,16,12}};

ROUTES=ROUTE18;
TravelLinkTime=Travel18;
Stops = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'};

%% The MANDL network (not needed anymore as Routes18 add more edges than it)
%MANDL=zeros(15,15);
%MANDL(1,2)=1;MANDL(2,[3 4 5])=1;MANDL(3,6)=1;MANDL(4,[5 6 12])=1;MANDL(6,[8 15])=1;MANDL(7,[10 15])=1;
%MANDL(8,[10,15])=1;MANDL(9,15)=1;MANDL(10,[11 13 14])=1;MANDL(11,[12 13])=1;MANDL(13,14)=1;
%MANDL=max(MANDL,MANDL'); % Unoriented version : all the routes become bidirectionnal

% Mandl Origin/Destination matrix
OD = [...
[  0 400 200  60  80 150  75  75  30 160  30  25  35  0 0];...
[400   0  50 120  20 180  90  90  15 130  20  10  10  5 0];...
[200  50   0 120  20 180  90  90  15  45  20  10  10  5 0];...
[ 60 120  40   0  50 100  50  50  15 240  40  25  10  5 0];...
[ 80  20  60  50   0  50  25  25  10 120  20  15   5  0 0];...
[150 180 180 100  50   0 100 100  30 880  60  15  15 10 0];...
[ 75  90  90  50  25 100   0  50  15 440  35  10  10  5 0];...
[ 75  90  90  50  25 100  50   0  15 440  35  10  10  5 0];...
[ 30  15  15  15  10  30  15  15   0 140  20   5   0  0 0];...
[160 130  45 240 120 880 440 440 140  0  60 250 500 200 0];...
[ 30  20  20  40  20  60  35  35  20 600   0  75  95 15 0];...
[ 25  10  10  25  15  15  10  10   5 250  75   0  70  0 0];...
[ 35  10  10  10   5  15  10  10   0 500  95  70   0 45 0];...
[  0   5   5   5   0  10   5   5   0 200  15   0  45  0 0];...
[  0   0   0   0   0   0   0   0   0   0   0   0   0  0 0]]; % not symetric

%% Mandl Travel Times matrices % now useless, more data are in travel 18 that in this one
%TT =[...%1 2 3  4  5  6  7  8  9 10 11 12 13 14 15
%[0 8 0  0  0  0  0  0  0  0  0  0  0  0 0];...
%[8 0 2  3  6  0  0  0  0  0  0  0  0  0 0];...
%[0 2 0  0  0  3  0  0  0  0  0  0  0  0 0];...
%[0 3 0  0  4  4  0  0  0  0  0 10  0  0 0];...
%[0 6 0  4  0  0  0  0  0  0  0  0  0  0 0];...
%[0 0 3  4  0  0  0  2  0  0  0  0  0  0 3];...
%[0 0 0  0  0  0  0  0  0  7  0  0  0  0 2];...
%[0 0 0  0  0  2  0  0  0  8  0  0  0  0 2];...
%[0 0 0  0  0  0  0  0  0  0  0  0  0  0 8];...
%[0 0 0  0  0  0  7  8  0  0  5  0 10  8 0];...
%[0 0 0  0  0  0  0  0  0  5  0 10  5  0 0];...
%[0 0 0 10  0  0  0  0  0  0 10  0  0  0 0];...
%[0 0 0  0  0  0  0  0  0 10  5  0  0  2 0];...
%[0 0 0  0  0  0  0  0  0  8  0  0  2  0 0];...
%[0 0 0  0  0  3  2  2  8  0  0  0  0  0 0]]; % TT-TT' should be null

%% Plotting the network

% Diected version
[DAdj ,DwAdj]=ComputeAdj2(ROUTES,TravelLinkTime,Stops); % see Part 2 Question 1
issymmetric(DAdj)

% Unoriented versions
Adj=DAdj|DAdj';
TravelTime=max(DwAdj,DwAdj');
issymmetric(Adj)

% Unoriented Edge list
EDGES=zeros(0,2);
for i=1:size(Adj,2)
 for j=i+1:size(Adj,2)
  if Adj(i,j), EDGES=[EDGES; i,j];end
 end
end

NODESXY=[... % Nodes coordinates
1.0, 7.0; %1
2.2, 5.5; %2
3.0, 6.0; %3
2.0, 4.5; %4
1.0, 5.0; %5
3.0, 5.0; %6
5.5, 3.8; %7
4.0, 4.0; %8
7.0, 5.5; %9
5.0, 3.0; %10
3.8, 2.7; %11
2.0, 3.0; %12
5.0, 1.0; %13
7.0, 3.0; %14
4.5, 5.5] %15

%% drawing
% install only if needed
% pkg install geometry %pkg install "https://downloads.sourceforge.net/project/octave/Octave%20Forge%20Packages/Individual%20Package%20Releases/geometry-4.1.0.tar.gz"
pkg list
pkg load geometry

[HN, HE]=drawGraph(NODESXY, EDGES); % or drawGraphEdges(Nodes, Edges) %or [HN, HE]=drawDigraph(Nodes,Nodes, Edges);
axis([1 7 1 7]); axis off % box off

set(HN, 'markersize',18); set(HN, 'markerfacecolor', [1,.8,.6])
% set(HN,  'linewidth',12); set(HN, 'markeredgecolor', [1,.8,.6]) % Decorations around the nodes
set(HE,  'linewidth', 2); % set(HE, 'pointerlocation',.5) % For directed arcs
set(HE, 'color', [0,.6,.6])

% Writing node names
xx=get(HN,'xdata');yy=get(HN,'ydata');offx=-0.05;offy=0.04;
for i=1:size(Adj,2), text(xx(i)+offx,yy(i)+offy,num2str(i)); end
