# 📈 Nonlinear ARX System Identification

A MATLAB implementation of a **polynomial, nonlinear ARX (AutoRegressive with eXogenous input) model** for black-box identification of an unknown dynamic system. The model is identified using linear regression and validated on a separate dataset.

---

## 📋 Problem Statement

Given a dataset measured on an unknown dynamic system with one input and one output, the goal is to develop a black-box model using a polynomial nonlinear ARX structure. The order of the dynamics is assumed to be no larger than three, and the system may be nonlinear with noisy output.

A second dataset measured on the same system is used for validation.

---

## 🧠 Model Structure

The nonlinear ARX model takes the form:

```
ŷ(k) = p(y(k−1), ..., y(k−na), u(k−nk), ..., u(k−nk−nb+1))
```

Where:
- `na` — number of past outputs used
- `nb` — number of past inputs used
- `nk = 1` — fixed delay
- `m` — polynomial degree applied to the regressor vector
- `p(·)` — polynomial mapping of degree m

Although the model is **nonlinear in the variables**, it remains **linear in the parameters**, allowing standard linear regression to identify the coefficients.

---

## ⚙️ Implementation

The project is implemented in **MATLAB** (no toolboxes required) and consists of:

- `model_arx.m` — Generates the nonlinear ARX model for configurable `na`, `nb`, and polynomial degree `m`
- `linear_regression.m` — Identifies model parameters using least squares
- `predict.m` — Runs the model in one-step-ahead prediction mode (uses real past outputs)
- `simulate.m` — Runs the model in simulation mode (uses only model's own past outputs)

### Two Operating Modes

| Mode | Description |
|---|---|
| **One-step-ahead prediction** | Uses real delayed outputs `y(k−1), ...` from the system |
| **Simulation** | Uses only previously simulated outputs `ỹ(k−1), ...` |

---

## 📊 Results

### Best Model Configuration

| Parameter | Value |
|---|---|
| Model orders | na = 4, nb = 5 |
| Polynomial degree | m = 2 |
| Delay | nk = 1 |
| Overall accuracy | ~99% |

### Mean Squared Error (MSE)

| Mode | Dataset | MSE |
|---|---|---|
| One-step-ahead prediction | Validation | 6.8042e-10 |
| Simulation | Identification | 1.3465e-10 |

> Extremely low MSE values indicate the polynomial nonlinear ARX model captures the system dynamics with very high fidelity.

---

## 🚀 Getting Started

1. Load your dataset in MATLAB:
```matlab
load('dataset.mat');  % loads id and val as iddata objects
% or use id_array and val_array if toolbox is unavailable
```

2. Identify the model:
```matlab
model = identify_narx(id, na, nb, m);
```

3. Run prediction and simulation:
```matlab
y_pred = predict_narx(model, val);
y_sim  = simulate_narx(model, val);
```

---

## 📁 Project Structure

```
nonlinear-arx/
├── data/
│   ├── iddata-10.mat          # MATLAB data file with id and val datasets
├── model_arx.m              # Nonlinear ARX model generator
├── project_code.m      # Parameter identification via least squares
└── README.md
```

---

## 📜 License

MIT License — feel free to use and adapt with attribution.

---

## 👤 Author

**Circiu Patrick-Sorin**
