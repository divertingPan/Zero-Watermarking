function [zero_robust_seal, Net] = CNN_robust_encrypt(I_original, I_robust_seal)
% ³��ˮӡ����
I_original = imresize(I_original, [512,512]);
I_robust_seal = imresize(I_robust_seal, [36,36]);

% ��ԭʼ��ɫͼ�����ת��������ԭʼͼ�񣬽���ת��ΪYCbCrͼ�񣬲��ֽ��Y��Cb��Crͨ����
Red = I_original(:,:,1);
Green = I_original(:,:,2);
Blue = I_original(:,:,3);

Y = 0.299*Red + 0.587*Green + 0.114*Blue;
Cb = -0.1687*Red - 0.3313*Green + 0.5*Blue + 128;
Cr = 0.5*Red - 0.4187*Green - 0.0813*Blue + 128;

% ����³��ˮӡͼ�񣬲�����Arnold�任�������ҡ�
a = 1;
b = 1;
N = 30;

I_robust_seal_chaos = arnold(I_robust_seal, a, b, N);

% ��ԭʼͼ���Y��Cb��Crͨ���ֱ�������߶ȵġ�db1����ɢС���任������������ֵ�ֽ⡣
 % Y��Cb��Crͨ��С���任���������Ӵ�С��ϵ������ֱ�Ϊ
 % LL3��HL3��LH3��HH3
 % LL'3��HL'3��LH'3��HH'3
 % LL''3��HL''3��LH''3��HH''3
 % ����12�������������ֵ�ֽ⣬���õ�36����ά����

% [LL3, LH3, HL3, HH3] = DWT(Y, 'db1');
% [LLp3, LHp3, HLp3, HHp3] = DWT(Cb, 'db1');
% [LLpp3, LHpp3, HLpp3, HHpp3] = DWT(Cr, 'db1');
[coefficient_subband(:,:,1), coefficient_subband(:,:,2), coefficient_subband(:,:,3), coefficient_subband(:,:,4)] = DWT(Y, 'db1');
[coefficient_subband(:,:,5), coefficient_subband(:,:,6), coefficient_subband(:,:,7), coefficient_subband(:,:,8)] = DWT(Cb, 'db1');
[coefficient_subband(:,:,9), coefficient_subband(:,:,10), coefficient_subband(:,:,11), coefficient_subband(:,:,12)] = DWT(Cr, 'db1');

for tmp = 1:12
    [USV(:,:,tmp), USV(:,:,tmp+12), USV(:,:,tmp+24)] = svd(coefficient_subband(:,:,tmp));
end

% ����DCNN���������������ǩ���󡣽�����4�еõ���36������ת���ɳ߶�Ϊż���ķ���
 % ��Y��Cb��Crͨ���еõ��ķ���߶����ֵ��ֵ��m������m��m��36����������X
 % ÿ����ΪXn(n=1,2,��,36)����X1��ǰ36��ÿ��֮�ͳ���X1Ԫ���ܸ�������1��36�����ǩ����T
X = USV;

X_size = size(X);
for tmp = 1:36
    T(tmp) = sum(X(:,tmp,1)) / (X_size(1)*X_size(2));
end

% ������DCNN�� CNN_graph ��ʾ��
 % ����㣨C1��C2�����þ���˵ĳߴ綼Ϊ5��5��C1���18������C2���36������
 % �²����㣨S1��S2������ߴ罵Ϊԭ����1/4��
CNN_Graph = [
    imageInputLayer([64 64 1],"Name","imageinput","Normalization","zerocenter")
    convolution2dLayer([5 5],18,"Name","conv_1")
    averagePooling2dLayer([2 2],"Name","avgpool2d_1","Padding","same","Stride",[2 2])
    convolution2dLayer([5 5],36,"Name","conv_2")
    averagePooling2dLayer([2 2],"Name","avgpool2d_2","Padding","same","Stride",[2 2])
    fullyConnectedLayer(128,"Name","fc_1")
    fullyConnectedLayer(64,"Name","fc_2")
    fullyConnectedLayer(36,"Name","fc_3")
    softmaxLayer("Name","softmax")
    classificationLayer("Name","classoutput")];

% training�����ݽṹ�� [X, Y, channel, num]
trainingImages = reshape(USV, X_size(1), X_size(2), 1, []);
trainingLabels = categorical(T);

opts = trainingOptions('adam', ...
        'LearnRateSchedule', 'none', ...
        'LearnRateDropFactor', 0.99, ...
        'LearnRateDropPeriod', 1, ...
        'MaxEpochs', 500, ...
        'MiniBatchSize', 36, ...
        'Plots','training-progress');

Net = trainNetwork(trainingImages, trainingLabels, CNN_Graph, opts);

% ��ȡ���ڹ�����³��ˮӡͼ�����Ϣ����
 % ȡ��S2������ľ���F��ȡF��ÿһ��100��j��(j=1,2,��,36)Ϊһ�飬������i�飬������ƽ��ֵ��
 % ������СΪ36��36�ľ���G�����F��50��j�е�Ԫ�ش��ڵ�i��Ԫ��ƽ��ֵ����G��[i,j]Ԫ��Ϊ1������Ϊ0
 % �õ���GΪ���ڹ�����³��ˮӡ����Ϣ����
F = activations(Net, trainingImages, 5);

F = reshape(F, [], 36);

for i = 1:36
    for j = 1:36
        G(i, j) = sum(F((i-1)*100+(1:100), j))/100;
        if F(50, j) < G(i, j)
            G(i, j) = 1;
        else
            G(i, j) = 0;
        end
    end
end

% ������³��ˮӡͼ��
 % ����һ���õ�G��ԭʼ³��ˮӡ����������㣬�������³��ˮӡͼ��
zero_robust_seal = xor(G, I_robust_seal_chaos);
zero_robust_seal = mat2gray(zero_robust_seal);

