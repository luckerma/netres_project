function run_NodePercolation_WithBC
    % run_NodePercolation_WithBC
    % --------------------------------------------------------
    % 1) Builds or loads your adjacency matrix (Adj) from routes
    % 2) Computes node betweenness centrality (BC)
    % 3) Sorts nodes ascending & descending by BC
    % 4) Runs 'NodePercolation' to remove nodes in that order,
    %    computing fraction of OD demand disconnected each step.
    % 5) Outputs the final vectors you can directly use to plot:
    %    [Proba_NODE_removal_asc, Proba_OD_decrease_asc]
    %    [Proba_NODE_removal_desc,Proba_OD_decrease_desc]
    %
    % (C) Example by ChatGPT. Adapt to your data or code structure.

    % -----------------------------
    % 0. LOAD or BUILD your network
    % -----------------------------
    % Suppose you already have an adjacency matrix for your 15-stop network:
    %    Adj: NxN adjacency (binary or 1 if link exists, or you can treat as unweighted).
    %    OD : NxN OD demand matrix (Mandl or other).
    % For this demonstration, we create dummy data. Replace with your actual data:

    % Example adjacency for 15 nodes: a random connectivity or your Mandl-based adjacency
    n = 15;
    rng(0)  % for reproducible random example
    Adj0 = sprand(n,n,0.2)>0;      % random 20% density
    Adj0 = triu(Adj0,1);           % make it upper triangular
    Adj0 = Adj0 + Adj0';           % symmetrize
    Adj0 = double(Adj0);           % cast to double
    % Ensure there are no self-loops:
    Adj0(logical(eye(n)))=0;

    % Example OD: random demands, you presumably have your real 15x15 Mandl OD
    OD = randi([0 100],n,n);
    for i=1:n, OD(i,i)=0; end % no self-demand

    % True: in your code, you might do something like:
    %   [DAdj, DwAdj] = ComputeAdj2(ROUTES, TravelLinkTime, Stops);
    %   Adj0 = DAdj;   % or some adjacency

    % -----------------------------
    % 1. Compute Betweenness for each node
    % -----------------------------
    BC = BetweennessCentrality(Adj0);  % <--- define or adapt your BC function

    % -----------------------------
    % 2. Sort nodes by BC (asc & desc)
    % -----------------------------
    [~, nodeOrderAsc]  = sort(BC,'ascend');
    [~, nodeOrderDesc] = sort(BC,'descend');

    % -----------------------------
    % 3. Run Node Percolation
    % -----------------------------
    [Proba_OD_decrease_asc, Proba_NODE_removal_asc] = NodePercolation(Adj0, OD, nodeOrderAsc);
    % Need a fresh adjacency for the second scenario
    [Proba_OD_decrease_desc,Proba_NODE_removal_desc]= NodePercolation(Adj0, OD, nodeOrderDesc);

    % -----------------------------
    % 4. Print or return final vectors
    % -----------------------------
    fprintf('ASCENDING BC node removal results:\n');
    disp(table(Proba_NODE_removal_asc, Proba_OD_decrease_asc));

    fprintf('\nDESCENDING BC node removal results:\n');
    disp(table(Proba_NODE_removal_desc, Proba_OD_decrease_desc));

    % Now you have the four vectors:
    %  Proba_NODE_removal_asc,  Proba_OD_decrease_asc
    %  Proba_NODE_removal_desc, Proba_OD_decrease_desc
    %
    % You can plot them right away:
    figure('Name','Node Attack Percolation','NumberTitle','off'); hold on
    plot(Proba_NODE_removal_asc, Proba_OD_decrease_asc,'-o','LineWidth',1.5,...
         'DisplayName','Ascend BC Removal');
    plot(Proba_NODE_removal_desc,Proba_OD_decrease_desc,'-s','LineWidth',1.5,...
         'DisplayName','Descend BC Removal');
    xlabel('Fraction of Nodes Removed')
    ylabel('Fraction of OD Demand Disconnected')
    grid on
    legend('Location','best')
    title('Node-Based Percolation (Betweenness Order)')
end


%% NodePercolation function
function [Proba_OD_decrease, Proba_NODE_removal] = NodePercolation(Adj0, OD, Node_order)
    % NodePercolation
    %   Removes nodes one by one in the order given by Node_order.
    %   After each removal, compute:
    %    - fraction of nodes removed (Proba_NODE_removal)
    %    - fraction of OD demand that is disconnected (Proba_OD_decrease)

    n = size(Adj0,1);
    Adj = Adj0;               % working copy
    removedNodes = false(n,1);

    Proba_OD_decrease  = zeros(n+1,1); % store for each step 0..n
    Proba_NODE_removal = zeros(n+1,1);

    % Step 0 (no nodes removed)
    Proba_OD_decrease(1) = fractionODdisconnected(Adj, OD, removedNodes);
    Proba_NODE_removal(1)= 0;

    % Iteratively remove nodes
    for step = 1:n
        nd = Node_order(step);
        removedNodes(nd) = true;

        % "remove" edges from adjacency
        Adj(nd,:) = 0;
        Adj(:,nd) = 0;

        % fraction of nodes removed
        Proba_NODE_removal(step+1) = step/n;
        % fraction of OD demand disconnected
        Proba_OD_decrease(step+1) = fractionODdisconnected(Adj, OD, removedNodes);
    end

    % Trim if you prefer to keep exactly n+1 points
    % Otherwise, they are the correct length for plotting: index 1..(n+1)
end


%% fractionODdisconnected function
function fracDis = fractionODdisconnected(Adj, OD, removedNodes)
    % fractionODdisconnected
    %   BFS-check connectivity for each OD pair that has nonzero demand
    %   and is not trivially removed (i.e., if either origin or destination
    %   is removed, that OD is forcibly disconnected).
    %
    %   Returns:
    %     fracDis = (total OD demand disconnected) / (sum of all OD demands)

    n = size(Adj,1);
    totalDemand = sum(OD(:));
    connectedDemand = 0;

    for o = 1:n
        for d = 1:n
            if OD(o,d) == 0, continue; end
            % If either node is removed => automatically disconnected
            if removedNodes(o) || removedNodes(d)
                continue;
            end
            % else check connectivity from o to d
            if isConnectedBFS(Adj, o, d)
                connectedDemand = connectedDemand + OD(o,d);
            end
        end
    end

    disconnectedDemand = totalDemand - connectedDemand;
    fracDis = disconnectedDemand / totalDemand;
end


%% isConnectedBFS function
function flag = isConnectedBFS(Adj, startNode, endNode)
    % isConnectedBFS: BFS or DFS to check connectivity in an unweighted graph
    if startNode == endNode
        flag = true;
        return
    end
    n = size(Adj,1);
    visited = false(n,1);
    queue = startNode;
    visited(startNode) = true;

    while ~isempty(queue)
        current = queue(1);
        queue(1) = [];  % pop front
        if current == endNode
            flag = true;
            return;
        end
        neighbors = find(Adj(current,:));
        for nb = neighbors
            if ~visited(nb)
                visited(nb) = true;
                queue(end+1) = nb;  %#ok<AGROW>
            end
        end
    end

    flag = false;
end


%% BetweennessCentrality function (example)
function BC = BetweennessCentrality(Adj)
    % BetweennessCentrality
    %   A very simple version of brandes or a standard BFS approach
    %   for unweighted graphs.
    %
    %   This is a placeholder - adapt or replace with your own BC function.
    n = size(Adj,1);
    BC = zeros(n,1);

    for s = 1:n
        stack = [];
        pred  = cell(n,1);
        dist  = -ones(n,1); dist(s)=0;
        sigma = zeros(n,1); sigma(s)=1;
        queue = [s];

        % BFS
        while ~isempty(queue)
            v = queue(1); queue(1) = [];
            stack(end+1) = v; %#ok<AGROW>
            neighbors = find(Adj(v,:));
            for w = neighbors
                if dist(w)<0
                    queue(end+1) = w; %#ok<AGROW>
                    dist(w) = dist(v)+1;
                end
                if dist(w) == dist(v)+1
                    sigma(w) = sigma(w)+sigma(v);
                    pred{w}(end+1) = v; %#ok<AGROW>
                end
            end
        end

        % Accumulation
        delta = zeros(n,1);
        while ~isempty(stack)
            w = stack(end);
            stack(end) = [];
            for v = pred{w}
                delta(v) = delta(v) + (sigma(v)/sigma(w))*(1+delta(w));
            end
            if w~=s
                BC(w) = BC(w) + delta(w);
            end
        end
    end
    % Normalization for undirected graphs
    BC = BC / 2;
end
