# 🏢 Inventory Control using Receding Horizon Method (RHM) + Monte Carlo 

This repository implements a **Receding Horizon Method (RHM)** for inventory control under uncertain demand conditions. The system models real-world costs such as storage, shortage, and disposal penalties while adaptively choosing order quantities that minimize total cost over a lookahead horizon. Both fixed and adaptive (RHM) policies are simulated using Monte Carlo trials.

---

## 📁 Repository Structure

| File/Folder                 | Description                                                                 |
|-----------------------------|-----------------------------------------------------------------------------|
| `src/rhm_main.m`            | Core simulation file that implements RHM control logic and compares it to a static baseline. |
| `src/rhm_gridsearch.m`      | Grid search simulation to analyze cost behavior across multiple `H` and `c` horizon values. |
| `plots_and_outputs/`        | Contains all generated plots and result visualizations.                    |
| `README.md`                 | Project overview, structure, and usage guide.                               |

---

## 💰 Cost Parameters

| Parameter          | Value | Description                                |
|--------------------|-------|--------------------------------------------|
| `warehouse_cost`   | 5     | Cost per unit of unsold inventory per day  |
| `shortage_penalty` | 20    | Penalty per unit of unmet demand           |
| `disposal_cost`    | 10    | End-of-horizon cost for leftover stock     |

These costs guide the RHM controller to balance between overstocking and shortage penalties, encouraging efficient ordering behavior.

---

## 📌 Key Highlights

- **Receding Horizon Method (RHM)**: Looks ahead `H` steps and selects the optimal order quantity `yₜ` that minimizes expected cost over that horizon.
- **Stochastic Demand Handling**: Demand is randomly drawn from a discrete probability distribution for each day.
- **Cost Metrics**:
  - `warehouse_cost` – Cost per unit of leftover inventory
  - `shortage_penalty` – Cost per unit of unmet demand
  - `disposal_cost` – End-of-horizon penalty for leftover stock
- **Static vs Adaptive Comparison**:
  - **Static Policy**: Fixed order quantity `y = 3` used when inventory drops below `r = 1`
  - **RHM Policy**: Dynamically selects best `y` using predicted demand-cost tradeoffs
- **Monte Carlo Trials**: Each simulation run consists of 500 stochastic trials
- **Grid Search**: Evaluates average cost over multiple configurations of:
  - Prediction horizon `H ∈ {2, 5, 10, 15}`
  - Control horizon `c ∈ {1, 2, 3}`

---

## 🛠 How to Run

### 🔄 Adaptive RHM Simulation

1. Open the file: `src/rhm_main.m`
2. Configure cost values and simulation parameters if needed.
3. Run the script. It:
   - Compares total cost from RHM and static policy
   - Displays sample dynamic order sequence
   - Plots results and saves them in `plots_and_outputs/`

### 🔍 Grid Search Across Horizons

1. Open the file: `src/rhm_gridsearch.m`
2. This script simulates all (H, c) combinations and computes average cost for each.
3. Output appears as a table in MATLAB and is saved as a plot image.

---

## 📊 Output Plots

| File                          | Description                                                           |
|-------------------------------|-----------------------------------------------------------------------|
| `Daily_Orders_RHM.png`        | Order quantity (yₜ) applied by RHM per day in a sample trial          |
| `GridSearch_Cost_Table.png`   | Table view of average cost across combinations of `H` and `c`         |
| `RHM_Order_Sequence.png`      | Final order sequence (stem plot) for a representative simulation      |
| `RHM_vs_Static_Costs.png`     | Cost comparison between adaptive RHM and static policy                |
| `Stock_Level_Over_Time.png`   | Plot of inventory level (xₜ) evolution across simulation days         |

---

## 📈 Sample Results

- **Mean Cost (RHM)**: 392.14 gold coins (H = 5, r = 1)
- **Static Policy Cost**: 422.00 gold coins (y = 3, r = 1)
- **Sample Order Sequence**:
```
3 3 2 3 2 3 3 3 2 3 0 3 2 ...
```

- **Best Configuration from Grid Search**:

| H  | c  | Avg Cost |
|----|----|-----------|
| 10 | 2  | **387.22** |

---

## 📚 Concepts Used

- **Receding Horizon Control**: Future-aware policy that adapts based on forecasted cost under uncertainty.
- **Discrete Probabilistic Modeling**: Demand is modeled using a categorical distribution.
- **Monte Carlo Simulation**: Cost performance averaged over 500 random demand scenarios.
- **Comparative Analysis**: Benchmarks adaptive performance vs static baseline.


