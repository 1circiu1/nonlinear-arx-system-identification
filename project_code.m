clc
clear
close all
load iddata-10.mat

uid = id.InputData{:};
yid = id.OutputData{:};
uval = val.InputData{:};
yval = val.OutputData{:};

u_id = uid(1:end-1);
y_id = yid(1:end-1);

u_val = uval(1:end-1);
y_val = yval(1:end-1);

function exp = exp_poly(nx, m)
    exp = [];
    for d = 0:m
        exp = [exp; exp_deg(nx, d)];
    end
end

function e_deg = exp_deg(nx, deg)
    if nx == 1
        e_deg = deg;
    else
        e_deg = [];
        for k = 0:deg
            ek = exp_deg(nx-1, deg-k);
            e_deg = [e_deg; [k*ones(size(ek,1),1), ek]];
        end
    end
end


function PHI = phi_poly(X, m)
    [N, nx] = size(X); % nx = na + nb
    exp = exp_poly(nx, m);
    PHI = zeros(N, size(exp,1));
    for k = 1:size(exp,1)
        PHI(:,k) = prod(X.^exp(k,:), 2);
    end
end

function [teta,Yap,PHI] = calcTeta(X,y,m)
    PHI = phi_poly(X, m);
    teta = PHI\y;
    Yap = PHI*teta;
end

function Yvalap = calcYVal(X,m,teta)
    PHI = phi_poly(X, m);
    Yvalap = PHI*teta;
end


function X = yprediction(y, u, na, nb)
    N = length(y);
    maxn = max(na, nb);
    Ns = N - maxn;
    X = zeros(Ns, na + nb);
    for k = 1:na
        X(:, k) = y(maxn-k+1:N-k);
    end
    for k = 1:nb
        X(:, na+k) = u(maxn-k+1:N-k);
    end
end

function y_sim = calc_ysim(u, y, na, nb, m, teta)
    N = length(u);
    maxn = max(na, nb);
    y_sim = zeros(N,1);
    y_sim(1:maxn) = y(1:maxn);

    for k = maxn+1:N
        x = zeros(1, na+nb);
        for i = 1:na
            x(i) = y_sim(k-i);
        end
        for j = 1:nb
            x(na+j) = u(k-j);
        end
        phi = phi_poly(x, m);
        y_sim(k) = phi * teta;
    end
end

function [] = plotsval(y_sim,y_pred,y)
figure
subplot(211)
plot(y,Color='r',DisplayName='yval')
hold on
plot(y_sim,Color='g',LineStyle='--',DisplayName='ysim')
title('y simulated compared to y validation')
legend show
hold off
subplot(212)
plot(y,Color='r',DisplayName='yval')
hold on
plot(y_pred,Color='g',LineStyle='--',DisplayName='ypred')
title('y prediction compared to y validation')
legend show
end

function [] = plotsid(y_sim,y_pred,y)
figure
subplot(211)
plot(y,Color='r',DisplayName='yid')
hold on
plot(y_sim,Color='g',LineStyle='--',DisplayName='ysim')
title('y simulated compared to y id')
legend show
hold off
subplot(212)
plot(y,Color='r',DisplayName='yid')
hold on
plot(y_pred,Color='g',LineStyle='--',DisplayName='ypred')
title('y prediction compared to y id')
legend show
end

function MSE = MSECalc(y,Yap,N)
    sum = 0;
    for i = 1:N
        sum = sum + (Yap(i) - y(i))^2;
    end
    MSE = 1/N * sum;
end

na = 4;
nb = 5;
m  = 2;

X_id = yprediction(y_id, u_id, na, nb);
X_val = yprediction(y_val, u_val, na, nb);

y_idd = y_id(max(na,nb)+1:end);
y_vall = y_val(max(na,nb)+1:end);

N_id = length(y_idd);
N_val = length(y_vall);

[teta_id,Yap_id,PHI_id] = calcTeta(X_id,y_idd,m);
y_pred = calcYVal(X_val,m,teta_id);
y_sim = calc_ysim(u_val, y_val, na, nb, m, teta_id);

y_simid = calc_ysim(u_id, y_id, na, nb, m, teta_id);
y_predid = PHI_id * teta_id;

plotsid(y_simid(max(na,nb)+1:end), y_predid, y_id)
plotsval(y_sim(max(na,nb)+1:end), y_pred, y_val)

%% CALCULATING BEST na,nb and m USING MSE
MSEbun = inf;
for na = 1:5
    for nb = 1:5
        for m = 1:5

            maxn = max(na, nb);
            X_id  = yprediction(y_id,  u_id,  na, nb);
            X_val = yprediction(y_val, u_val, na, nb);

            y_idd  = y_id(maxn+1:end);
            y_vall = y_val(maxn+1:end);
            try
                teta_id = phi_poly(X_id, m) \ y_idd;
            catch
                continue
            end
            y_pred = phi_poly(X_val, m) * teta_id;
            N = length(y_pred);
            mse_val = MSECalc(y_vall, y_pred,N);
            if mse_val < MSEbun
                MSEbun = mse_val;
                nabun  = na;
                nbbun  = nb;
                mbun  = m;
            end
        end
    end
end
fprintf('MSEbun = %.6g\n', MSEbun);
fprintf('m = %d\n', mbun);
fprintf('na = %d\n', nabun);
fprintf('nb = %d', nbbun);

Ts_id = id.Ts{1};
Ts_val = val.Ts{1};

sim_id = iddata(y_simid(1:1994), u_id(1:1994), Ts_id);
pred_id = iddata(y_predid(1:1994), u_id(1:1994), Ts_id);

sim_val = iddata(y_sim(1:1994), u_val(1:1994), Ts_val);
pred_val = iddata(y_pred(1:1994), u_val(1:1994), Ts_val);

id_data  = iddata(y_id(1:1994), u_id(1:1994), Ts_id);
val_data = iddata(y_val(1:1994), u_val(1:1994), Ts_val);

figure
compare(id_data, sim_id, pred_id)
legend('Measured','NARX Simulation','NARX Prediction')
title('NARX vs Measured – Identification')
figure
compare(val_data, sim_val, pred_val)
legend('Measured','NARX Simulation','NARX Prediction')
title('NARX vs Measured – Validation')