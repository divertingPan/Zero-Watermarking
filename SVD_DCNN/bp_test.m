% *********************** 训练 ************************ %
% 随便产生标签矩阵T，列是每组数据延伸的方向，或者理解为一列是一个batch
% 直接替换这个循环，换成自己的T即可
for i = 1:16
    T(i) = rand;
end

% 随便产生16个输入图，结构同上
% 直接在这里读取3x3的子图块即可，多个子图在第三轴上拼起来
for s = 1:16
    for i = 1:3
        for j = 1:3
            image(i, j, s) = rand;
        end
    end
end

% 预处理输入
P = reshape(image, 9, []);

% 构建网络结构
bp_net = newff(P, T, 10);

bp_net.trainParam.goal = 1e-5;
bp_net.trainParam.epochs = 300;
bp_net.trainParam.lr = 0.05;
bp_net.trainParam.showWindow = 1;
bp_net.divideFcn = '';

bp_net = train(bp_net, P, T);


% *********************** 预测 ************************ %
% 随便产生一个图
% 在这里读取子图块，产生预测输出值，数据维度同上
for s = 1:16
    for i = 1:3
        for j = 1:3
            image_predict(i, j, s) = rand;
        end
    end
end

% 预处理输入
P_predict = reshape(image_predict, 9, []);

output = sim(bp_net, P_predict);
disp(['predict: ', num2str(output)])