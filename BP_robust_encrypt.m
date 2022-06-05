function [seal, bp_net] = BP_robust_encrypt(I_original, I_robust_seal)
% ����³��ˮӡ
I_original = imresize(I_original, [512,512]);
I_robust_seal = imresize(I_robust_seal, [36,36]);

% ����³��ˮӡͼ�񣬲�����Arnold�任�������ҡ�
a = 1;
b = 1;
N = 30;

I_robust_seal_chaos = arnold(I_robust_seal, a, b, N);

% ��ȡ������ͼƬ���иȡ��ͼ����ֵ��ƽ��ֵ
I_original = rgb2gray(I_original);
I_original = im2double(I_original);
[height, width] = size(I_original);
seperate_size_h = height / 36;
seperate_size_w = width / 36;

k = 1;
for i = 1:seperate_size_h:height
    for j = 1:seperate_size_w:width
        sub_img(:,:,k) = I_original((floor(i/seperate_size_h)*floor(seperate_size_h) + 1) : (floor(i/seperate_size_h)*floor(seperate_size_h) + 3), ...
                                    (floor(j/seperate_size_w)*floor(seperate_size_w) + 1) : (floor(j/seperate_size_w)*floor(seperate_size_w) + 3));
        k = k + 1;
    end
end

for i = 1:1296
    tmp = sub_img(:,:,i);
    S(i) = tmp(2, 2);
    Ave(i) = mean2(tmp);
end

% BP���粿��
% *********************** ѵ�� ************************ %
T = Ave;

% ֱ���������ȡ3x3����ͼ�鼴�ɣ������ͼ��Ҫ�ڵ�������ƴ����
image = sub_img;

% Ԥ��������
P = reshape(image, 9, []);

% ��������ṹ
bp_net = newff(P, T, 50);

bp_net.trainParam.goal = 0;
bp_net.trainParam.epochs = 10000;
bp_net.trainParam.mc = 0.95;
bp_net.trainParam.lr = 0.05;
bp_net.trainParam.min_grad = 0;
bp_net.trainParam.showWindow = 1;
bp_net.divideFcn = '';

bp_net = train(bp_net, P, T);
% save('encryption/bp_net.mat', 'bp_net');

% ����B���������õ�ˮӡ
for i = 1:1296
    if S(i) < Ave(i)
        B(i) = 0;
    else
        B(i) = 1;
    end
end

B = reshape(B, 36, 36);
seal = xor(I_robust_seal_chaos, B);
seal = mat2gray(seal);
% imwrite(mat2gray(seal), 'encryption/bp_seal.bmp');
% imshow(seal, []);