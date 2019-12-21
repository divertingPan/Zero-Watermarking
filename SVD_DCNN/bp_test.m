% *********************** ѵ�� ************************ %
% ��������ǩ����T������ÿ����������ķ��򣬻������Ϊһ����һ��batch
% ֱ���滻���ѭ���������Լ���T����
for i = 1:16
    T(i) = rand;
end

% ������16������ͼ���ṹͬ��
% ֱ���������ȡ3x3����ͼ�鼴�ɣ������ͼ�ڵ�������ƴ����
for s = 1:16
    for i = 1:3
        for j = 1:3
            image(i, j, s) = rand;
        end
    end
end

% Ԥ��������
P = reshape(image, 9, []);

% ��������ṹ
bp_net = newff(P, T, 10);

bp_net.trainParam.goal = 1e-5;
bp_net.trainParam.epochs = 300;
bp_net.trainParam.lr = 0.05;
bp_net.trainParam.showWindow = 1;
bp_net.divideFcn = '';

bp_net = train(bp_net, P, T);


% *********************** Ԥ�� ************************ %
% ������һ��ͼ
% �������ȡ��ͼ�飬����Ԥ�����ֵ������ά��ͬ��
for s = 1:16
    for i = 1:3
        for j = 1:3
            image_predict(i, j, s) = rand;
        end
    end
end

% Ԥ��������
P_predict = reshape(image_predict, 9, []);

output = sim(bp_net, P_predict);
disp(['predict: ', num2str(output)])