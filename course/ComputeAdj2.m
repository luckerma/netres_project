function [Adj, wAdj, qAdj, qInverseAdj] = ComputeAdj2(ROUTES, TravelLinkTime, Stops)
    % Initialize adjacency and weight matrices based on StopList size
    numStops = length(Stops);
    Adj = zeros(numStops, numStops);
    wAdj = zeros(numStops, numStops);
    qAdj = inf(numStops, numStops); % Quality matrix (direct travel time)
    qInverseAdj = inf(numStops, numStops); % Quality matrix (inverse travel time)

    % Loop through each route in ROUTES
    for itinerary = 1:size(ROUTES, 2)
        % Get the index of the first stop in the route from Stops list
        LastStopIdx = find(strcmp(Stops, ROUTES{itinerary}{1}));

        % Iterate through the rest of the stops in the route
        for Stop = 2:size(ROUTES{itinerary}, 2)
            % Get the index of the current stop
            StopIdx = find(strcmp(Stops, ROUTES{itinerary}{Stop}));

            % Update adjacency and weight matrices
            Adj(LastStopIdx, StopIdx) = 1;
            wAdj(LastStopIdx, StopIdx) = TravelLinkTime{itinerary}{Stop - 1};

            % Update quality matrix (direct travel time)
            if TravelLinkTime{itinerary}{Stop - 1} > 0
                qAdj(LastStopIdx, StopIdx) = 1 / TravelLinkTime{itinerary}{Stop - 1};
            end

            % Update the last stop index
            LastStopIdx = StopIdx;
        end
    end

    % Transform adjacency and weight matrices into undirected versions
    Adj = max(Adj, Adj'); % Make adjacency matrix symmetric
    wAdj = max(wAdj, wAdj'); % Symmetrize the weight matrix

    % Compute the maximum travel time for the inverse quality matrix
    TravelLinkTime = cellfun(@str2double, TravelLinkTime, 'UniformOutput', false);
    maxTravelTime = max(wAdj(wAdj > 0), [], 'all'); % Ignore zero entries
    % Transform the quality matrix for inverse travel time
    for i = 1:numStops
        for j = 1:numStops
            if wAdj(i, j) > 0 % Only compute for valid edges
                qInverseAdj(i, j) = 1 / (maxTravelTime * wAdj(i, j));
            end
        end
    end

    % Ensure symmetry for the inverse quality matrix
    qAdj = min(qAdj, qAdj'); % Make direct quality matrix symmetric
    qInverseAdj = min(qInverseAdj, qInverseAdj'); % Symmetrize the inverse quality matrix
end
