clc; clear; close all;
rng(1); 

% Simulation settings
num_days = 52;
num_trials = 500;
H = 5; 

% Cost parameters
warehouse_cost = 5;
shortage_penalty = 20;
disposal_cost = 10;

% Demand distribution 
demand_values = 0:6;
probabilities = [0.04, 0.08, 0.27358780290000001, 0.40641219710000004, 0.16, 0.02, 0.02];

% Policy parameters
reorder_level = 1;     
Y = 0:6;              

% Results
total_costs = zeros(1, num_trials);
final_orders = zeros(num_trials, num_days);
final_stocks = zeros(num_trials, num_days + 1);

for trial = 1:num_trials
    x = 0;                     % Initial stock (x₀)
    total_cost = 0;
    u = 0;                     % Incoming order (uₜ)
    order = zeros(1, num_days);
    x_record = zeros(1, num_days + 1);
    x_record(1) = x;

    for t = 1:num_days
        % Step 1: Apply previous day's order
        x = x + u;
        u = 0;

        % Step 2: Sample stochastic demand
        rand_val = rand();
        cumulative_prob = cumsum(probabilities);
        demand = demand_values(find(rand_val <= cumulative_prob, 1));

        % Step 3: Fulfill demand, apply cost
        if demand > x
            daily_cost = shortage_penalty;
            x = 0;
        else
            x = x - demand;
            daily_cost = warehouse_cost * x;
        end

        % Step 4: Receding Horizon Control
        if x <= reorder_level
            best_y = 0;
            min_exp_cost = inf;

            for y = Y
                exp_cost = 0;
                virt_stock = x + y;

                % Predict expected cost over horizon H
                for h = 1:H
                    for d = demand_values
                        p = probabilities(d + 1);
                        if virt_stock >= d
                            leftover = virt_stock - d;
                            c = warehouse_cost * leftover;
                        else
                            c = shortage_penalty;
                        end
                        exp_cost = exp_cost + p * c;
                    end
                end

                % Select order with minimum expected cost
                if exp_cost < min_exp_cost
                    min_exp_cost = exp_cost;
                    best_y = y;
                end
            end

            % Apply optimal order 
            order(t) = best_y;
            u = best_y;
        else
            order(t) = 0;
        end

        total_cost = total_cost + daily_cost;
        x_record(t + 1) = x;
    end

    % Step 5: Apply disposal cost at end of horizon
    total_cost = total_cost + x * disposal_cost;

    % Record results
    total_costs(trial) = total_cost;
    final_orders(trial, :) = order;
    final_stocks(trial, :) = x_record;
end

% Output results
mean_cost = mean(total_costs);
static_policy_cost = 422.00; % From fixed policy (y=3, r=1)

fprintf('RHM Total Cost over %d trials: %.2f gold coins\n', num_trials, mean_cost);
fprintf('Static Policy Cost (y = 3, r = 1): %.2f gold coins\n', static_policy_cost);
fprintf('Used r = %d and H = %d\n', reorder_level, H);

% Display sample dynamic policy
disp('Sample yₜ order sequence (last trial):');
disp(final_orders(end, :));

% Plot results
figure;
stem(1:num_days, final_orders(end, :), 'filled');
xlabel('Day'); ylabel('Order Quantity yₜ');
title('Daily Orders (RHM, Sample Trial)');
grid on;

figure;
stairs(0:num_days, final_stocks(end, :), 'LineWidth', 2);
xlabel('Day'); ylabel('Inventory Level xₜ');
title('Stock Level Over Time (Sample Trial)');
grid on;
