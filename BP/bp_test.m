%% ����ˮӡ

% ����³��ˮӡͼ�񣬲�����Arnold�任�������ҡ�
I_robust_seal = imread('img/E.bmp');
a = 1;
b = 1;
N = 30;

I_robust_seal_chaos = arnold(I_robust_seal, a, b, N);

% ��ȡ������ͼƬ���иȡ��ͼ����ֵ��ƽ��ֵ
I_original = imread('img/lena.bmp');
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
% ��������ǩ����T������ÿ����������ķ��򣬻������Ϊһ����һ��batch
% ֱ���滻��������Լ���T����
T = Ave;

% ������16������ͼ���ṹͬ��
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
save('encryption/bp_net.mat', 'bp_net');

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
imwrite(mat2gray(seal), 'encryption/bp_seal.bmp');
imshow(seal, []);


%% ����ˮӡ

% ��ȡ������ͼƬ���иȡ��ͼ����ֵ��ƽ��ֵ
I_original = imread('img/lena.bmp');
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
end

% *********************** Ԥ�� ************************ %
% ������һ��ͼ
% �������ȡ��ͼ�飬����Ԥ�����ֵ������ά��ͬ��
image_predict = sub_img;

% Ԥ��������
P_predict = reshape(image_predict, 9, []);

load('encryption/bp_net.mat');
output = sim(bp_net, P_predict);

% ����B
for i = 1:1296
    if S(i) < output(i)
        B(i) = 0;
    else
        B(i) = 1;
    end
end

% B��ˮӡ��򣬵õ���ˮӡ
B = reshape(B, 36, 36);
encrypt_seal = imread('encryption/bp_seal.bmp');
seal = xor(encrypt_seal, B);

a = 1;
b = 1;
N = 30;
seal = arnold(seal, a, b, N);

imshow(seal, []);
