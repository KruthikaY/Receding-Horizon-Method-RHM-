clc; clear; close all;
rng(1);  % For reproducibility

% Simulation settings
num_days = 52;
num_trials = 500;
r = 1;  
warehouse_cost = 5;
shortage_penalty = 20;
disposal_cost = 10;

% Demand setup
demand_values = 0:6;
probabilities = [0.04, 0.08, 0.2735878029, 0.4064121971, 0.16, 0.02, 0.02];
Y = 0:6; 

% Horizon configurations
H_list = [2, 5, 10, 15];  % Prediction horizon values
c_list = [1, 2, 3];       % Control horizon values

% Store results
results = [];

for H = H_list
    for c = c_list
        fprintf('Simulating H = %d, c = %d over %d trials...\n', H, c, num_trials);
        all_costs = zeros(num_trials, 1);

        for trial = 1:num_trials
            x = 0;  % Initial stock
            u = 0;  % Incoming order
            total_cost = 0;

            for t = 1:num_days
                x = x + u;
                u = 0;

                d = randsample(demand_values, 1, true, probabilities);

                if d > x
                    total_cost = total_cost + shortage_penalty;
                    x = 0;
                else
                    x = x - d;
                    total_cost = total_cost + warehouse_cost * x;
                end

                % Receding horizon decision if stock low and not final day
                if x <= r && t < num_days
                    best_y = 0;
                    min_exp_cost = inf;

                    for y = Y
                        exp_cost = 0;
                        s1 = x + y;

                        for i = 1:length(demand_values)
                            d1 = demand_values(i);
                            p1 = probabilities(i);

                            % Cost on first step
                            if s1 >= d1
                                leftover = s1 - d1;
                                c1 = warehouse_cost * leftover;
                            else
                                leftover = 0;
                                c1 = shortage_penalty;
                            end

                            % Future cost (H - 1 steps)
                            future_cost = 0;
                            virt_stock = leftover;

                            for h = 2:H
                                for j = 1:length(demand_values)
                                    dj = demand_values(j);
                                    pj = probabilities(j);

                                    if virt_stock >= dj
                                        virt_stock = virt_stock - dj;
                                        future_cost = future_cost + pj * warehouse_cost * virt_stock;
                                    else
                                        virt_stock = 0;
                                        future_cost = future_cost + pj * shortage_penalty;
                                    end
                                end
                            end

                            exp_cost = exp_cost + p1 * (c1 + future_cost);
                        end

                        if exp_cost < min_exp_cost
                            min_exp_cost = exp_cost;
                            best_y = y;
                        end
                    end

                    u = best_y; 
                end
            end

            total_cost = total_cost + disposal_cost * x;
            all_costs(trial) = total_cost;
        end

        avg_cost = mean(all_costs);
        results = [results; H, c, avg_cost];
    end
end

% Display results as table
T = array2table(results, 'VariableNames', {'H', 'c', 'Avg_Cost'});
disp(T);
