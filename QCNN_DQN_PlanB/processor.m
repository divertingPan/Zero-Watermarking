% �ô�ģ���ͼ������������ò�������

%% ��ȡ
I_original = imread('img/lena.bmp');
I_zero_robust_seal = imread('img/E.bmp');


%% Gamma

for t = 1:50
    tmp = imadjust(I_original, [], [], 0.1*t);
    
    robust_seal = dec_func(tmp);
    NC_r(t) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t) = TAF(I_zero_robust_seal, robust_seal);
    
    disp(['Gamma: ', num2str(t)]);
end

x = linspace(0.1, 5, 50);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
grid on;
xlabel('Gamma');
ylabel('NC & TAF');
legend('NC', 'TAF', 'Location','best');
saveas(gcf, 'test/gamma', 'svg');

% ����ʾ��ͼ
tmp = imadjust(I_original, [], [], 0.5);
imwrite(tmp, ['test/lena_gamma', num2str(0.5), '.bmp']);
robust_seal = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_gamma', num2str(0.5), '.bmp']);


%% ��ת

for t = 0:50
    tmp = imrotate(I_original, 2*t, 'bilinear', 'crop');
    
    robust_seal = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);
    
    disp(['rotate: ', num2str(2*t)]);
end

x = linspace(0, 100, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
grid on;
xlabel('��ת�Ƕ�/(��)');
ylabel('NC & TAF');
legend('NC', 'TAF', 'Location','best');
saveas(gcf, 'test/rotate', 'svg');

% ����ʾ��ͼ
tmp = imrotate(I_original, 30, 'bilinear', 'crop');
imwrite(tmp, ['test/lena_rotate', num2str(30), '.bmp']);
robust_seal = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_rotate', num2str(30), '.bmp']);


%% ��˹����

for t = 0:50
    tmp = imnoise(I_original, 'gaussian', 0, 0.02*t);

    robust_seal = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);

    disp(['gaussian: ', num2str(0.02*t)]);
end

x = linspace(0, 1, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
grid on;
xlabel('��������');
ylabel('NC & TAF');
legend('NC', 'TAF', 'Location','best');
saveas(gcf, 'test/gaussian', 'svg');

% ����ʾ��ͼ
tmp = imnoise(I_original, 'gaussian', 0, 3);
imwrite(tmp, ['test/lena_gaussian', num2str(3), '.bmp']);
robust_seal = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_gaussian', num2str(3), '.bmp']);


%% ��������

for t = 0:50
    tmp = imnoise(I_original, 'salt & pepper', 0.02*t);

    robust_seal = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);

    disp(['salt & pepper: ', num2str(0.02*t)]);
end

x = linspace(0, 1, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
grid on;
xlabel('��������');
ylabel('NC & TAF');
legend('NC', 'TAF', 'Location','best');
saveas(gcf, 'test/saltpepper', 'svg');

% ����ʾ��ͼ
tmp = imnoise(I_original, 'salt & pepper', 0.03);
imwrite(tmp, ['test/lena_saltpepper', num2str(0.03), '.bmp']);
robust_seal = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_saltpepper', num2str(0.03), '.bmp']);


%% ��ֵ�˲�

NC_r(1) = 1;
NC_f(1) = 1;
TAF_r(1) = 0;
TAF_f(1) = 0;

for t = 1:50
    for i = 1:3
        tmp(:,:,i) = medfilt2(I_original(:,:,i), [2*t, 2*t]);
    end

    robust_seal = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);

    disp(['medfilt: ', num2str(2*t)]);
end

x = linspace(0, 100, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
grid on;
xlabel('�˲����ߴ�');
ylabel('NC & TAF');
legend('NC', 'TAF', 'Location','best');
saveas(gcf, 'test/medfilt', 'svg');

% ����ʾ��ͼ
for i = 1:3
    tmp(:,:,i) = medfilt2(I_original(:,:,i), [3, 3]);
end
imwrite(tmp, ['test/lena_medfilt', num2str(3), '.bmp']);
robust_seal = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_medfilt', num2str(3), '.bmp']);


%% JPEGѹ��

for t = 0:50
    imwrite(I_original, ['test/lena_compressed_tmp', '.jpg'], 'Quality', 2*t);
    tmp = imread(['test/lena_compressed_tmp', '.jpg']);
    
    robust_seal = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);
    
    disp(['compressed: ', num2str(2*t)]);
end

x = linspace(0, 100, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
grid on;
xlabel('��������');
ylabel('NC & TAF');
legend('NC', 'TAF', 'Location','best');
saveas(gcf, 'test/compressed', 'svg');

% ����ʾ��ͼ
imwrite(I_original, ['test/lena_compressed_tmp', '.jpg'], 'Quality', 10);
tmp = imread(['test/lena_compressed_tmp', '.jpg']);
imwrite(tmp, ['test/lena_compressed', num2str(10), '.bmp']);
robust_seal = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_compressed', num2str(10), '.bmp']);


%% ƴ��1

NC_r(1) = 1;
NC_f(1) = 1;
TAF_r(1) = 0;
TAF_f(1) = 0;

s = size(I_original);
w = s(1) - mod(s(1), 50);
h = s(2);
for t = 1:50
    tmp = I_original;
    tmp2 = tmp(1:w/50*t, h/2+1:h, :);
    tmp(1:w/50*t, h/2+1:h, :) = tmp(1:w/50*t, 1:h/2, :);
    tmp(1:w/50*t, 1:h/2, :) = tmp2;
    
    robust_seal = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);
    
    disp(['paste1: ', num2str(2*t)]);
end

x = linspace(0, 100, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
grid on;
xlabel('����');
ylabel('NC & TAF');
legend('NC', 'TAF', 'Location','best');
saveas(gcf, 'test/paste1', 'svg');

% ����ʾ��ͼ
t = 10;
tmp = I_original;
tmp2 = tmp(1:w/50*t, h/2+1:h, :);
tmp(1:w/50*t, h/2+1:h, :) = tmp(1:w/50*t, 1:h/2, :);
tmp(1:w/50*t, 1:h/2, :) = tmp2;
imwrite(tmp, ['test/lena_paste1_', num2str(t*2), '.bmp']);
robust_seal = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_paste1_', num2str(t*2), '.bmp']);


%% ƴ��2

NC_r(1) = 1;
NC_f(1) = 1;
TAF_r(1) = 0;
TAF_f(1) = 0;

I_source = imread('img/peppers.bmp');
s = size(I_original);
w = s(1) - mod(s(1), 50);
h = s(2);
for t = 1:50
    tmp = I_original;
    tmp(1:w/50*t, :, :) = I_source(1:w/50*t, :, :);
    
    robust_seal = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);

    disp(['paste2: ', num2str(2*t)]);
end

x = linspace(0, 100, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
grid on;
xlabel('����');
ylabel('NC & TAF');
legend('NC', 'TAF', 'Location','best');
saveas(gcf, 'test/paste2', 'svg');

% ����ʾ��ͼ
t = 45;
tmp = I_original;
tmp(1:w/50*t, :, :) = I_source(1:w/50*t, :, :);
imwrite(tmp, ['test/lena_paste2_', num2str(t*2), '.bmp']);
robust_seal = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_paste2_', num2str(t*2), '.bmp']);


%% ���� (shear)

for t = 0:50
    tform = affine2d([1 0 0; t*0.02 1 0; 0 0 1]);
	J = imwarp(I_original, tform, 'cubic');
    s = size(J);
    tmp = imcrop(J, [round(s(2)/2) - 255, 1, 511, 511]);
    
    robust_seal = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);

    disp(['shear: ', num2str(0.02*t)]);
end

x = linspace(0, 1, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
grid on;
xlabel('����ǿ��');
ylabel('NC & TAF');
legend('NC', 'TAF', 'Location','best');
saveas(gcf, 'test/shear', 'svg');

% ����ʾ��ͼ
tform = affine2d([1 0 0; 0.6 1 0; 0 0 1]);
J = imwarp(I_original, tform, 'cubic');
s = size(J);
tmp = imcrop(J, [round(s(2)/2) - 256, 1, 511, 511]);
imwrite(tmp, ['test/lena_shear', num2str(0.6), '.bmp']);
robust_seal = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_shear', num2str(0.6), '.bmp']);


%% ���� (crop)

NC_r(1) = 1;
NC_f(1) = 1;
TAF_r(1) = 0;
TAF_f(1) = 0;

s = size(I_original);
w = s(1) - mod(s(1), 50);
h = s(2);
for t = 1:50
    tmp = I_original;
    tmp(1:w/50*t, :, :) = 0;
    
    robust_seal = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);
    
    disp(['crop: ', num2str(2*t)]);
end

x = linspace(0, 100, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
grid on;
xlabel('����');
ylabel('NC & TAF');
legend('NC', 'TAF', 'Location','best');
saveas(gcf, 'test/crop', 'svg');

% ����ʾ��ͼ
t = 45;
tmp = I_original;
tmp(1:w/50*t, :, :) = 0;
imwrite(tmp, ['test/lena_crop', num2str(t*2), '.bmp']);
robust_seal = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_crop', num2str(t*2), '.bmp']);


%% ��������

I = imread('img/peppers.bmp');
robust_seal = dec_func(I);
imshow(robust_seal);

% I = imread('img/lake.bmp');
% robust_seal = dec_func(I);
% imshow(robust_seal);