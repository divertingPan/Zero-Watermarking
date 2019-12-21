% 用此模块对图像作攻击，获得测试用例

%% 读取
I_original = imread('img/lena.bmp');
I_zero_robust_seal = imread('img/E.bmp');
I_semifragile_seal = imread('img/seal.bmp');


%% Gamma

for t = 1:50
    tmp = imadjust(I_original, [], [], 0.1*t);
    
    [robust_seal, semifragile_seal] = dec_func(tmp);
    NC_r(t) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t) = TAF(I_zero_robust_seal, robust_seal);
    NC_f(t) = nc(I_semifragile_seal, semifragile_seal);
    TAF_f(t) = TAF(I_semifragile_seal, semifragile_seal);
end

x = linspace(0.1, 5, 50);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
plot(x, NC_f, '-+');hold on;
plot(x, TAF_f, '-.');hold on;
grid on;
xlabel('Gamma');
ylabel('NC & TAF');
legend('NC (robust seal)', 'TAF (robust seal)', 'NC (semifragile seal)', 'TAF (semifragile seal)', 'Location','best');
saveas(gcf, 'test/gamma', 'svg');

% 生成示例图
t = 0.3;
tmp = imadjust(I_original, [], [], t);
imwrite(tmp, ['test/lena_gamma', num2str(t), '.bmp']);
[robust_seal, semifragile_seal] = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_gamma', num2str(t), '.bmp']);
imwrite(semifragile_seal, ['test/semifragile_seal_gamma', num2str(t), '.bmp']);


%% 旋转

% I_rotate(:,:,:,1) = I_original;
for t = 0:50
    tmp = imrotate(I_original, 2*t, 'bilinear', 'crop');
%     I_rotate(:,:,:,t+1) = tmp;
    
    [robust_seal, semifragile_seal] = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);
    NC_f(t+1) = nc(I_semifragile_seal, semifragile_seal);
    TAF_f(t+1) = TAF(I_semifragile_seal, semifragile_seal);
end

x = linspace(0, 100, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
plot(x, NC_f, '-+');hold on;
plot(x, TAF_f, '-.');hold on;
grid on;
xlabel('旋转角度/(°)');
ylabel('NC & TAF');
legend('NC (鲁棒水印)', 'TAF (鲁棒水印)', 'NC (半脆弱水印)', 'TAF (半脆弱水印)', 'Location','best');
saveas(gcf, 'test/rotate', 'svg');

% 生成示例图
t = 0.3;
tmp = imrotate(I_original, t, 'bilinear', 'crop');
imwrite(tmp, ['test/lena_rotate', num2str(t), '.bmp']);
[robust_seal, semifragile_seal] = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_rotate', num2str(t), '.bmp']);
imwrite(semifragile_seal, ['test/semifragile_seal_rotate', num2str(t), '.bmp']);


%% 高斯噪声

% I_gaussian(:,:,:,1) = I_original;
for t = 0:50
    tmp = imnoise(I_original, 'gaussian', 0, 0.02*t);
%     I_gaussian(:,:,:,t+1) = tmp;
    
    [robust_seal, semifragile_seal] = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);
    NC_f(t+1) = nc(I_semifragile_seal, semifragile_seal);
    TAF_f(t+1) = TAF(I_semifragile_seal, semifragile_seal);
end

x = linspace(0, 1, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
plot(x, NC_f, '-+');hold on;
plot(x, TAF_f, '-.');hold on;
grid on;
xlabel('噪声方差');
ylabel('NC & TAF');
legend('NC (鲁棒水印)', 'TAF (鲁棒水印)', 'NC (半脆弱水印)', 'TAF (半脆弱水印)', 'Location','best');
saveas(gcf, 'test/gaussian', 'svg');

% 生成示例图
t = 3;
tmp = imnoise(I_original, 'gaussian', 0, t);
imwrite(tmp, ['test/lena_gaussian', num2str(t), '.bmp']);
[robust_seal, semifragile_seal] = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_gaussian', num2str(t), '.bmp']);
imwrite(semifragile_seal, ['test/semifragile_seal_gaussian', num2str(t), '.bmp']);


%% 椒盐噪声

% I_saltpepper(:,:,:,1) = I_original;
for t = 0:50
    tmp = imnoise(I_original, 'salt & pepper', 0.02*t);
%     I_saltpepper(:,:,:,t+1) = tmp;

    [robust_seal, semifragile_seal] = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);
    NC_f(t+1) = nc(I_semifragile_seal, semifragile_seal);
    TAF_f(t+1) = TAF(I_semifragile_seal, semifragile_seal);
end

x = linspace(0, 1, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
plot(x, NC_f, '-+');hold on;
plot(x, TAF_f, '-.');hold on;
grid on;
xlabel('噪声方差');
ylabel('NC & TAF');
legend('NC (robust seal)', 'TAF (robust seal)', 'NC (semifragile seal)', 'TAF (semifragile seal)', 'Location','best');
saveas(gcf, 'test/saltpepper', 'svg');

% 生成示例图
t = 0.3;
tmp = imnoise(I_original, 'salt & pepper', t);
imwrite(tmp, ['test/lena_saltpepper', num2str(t), '.bmp']);
[robust_seal, semifragile_seal] = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_saltpepper', num2str(t), '.bmp']);
imwrite(semifragile_seal, ['test/semifragile_seal_saltpepper', num2str(t), '.bmp']);


%% 中值滤波

NC_r(1) = 1;
NC_f(1) = 1;
TAF_r(1) = 0;
TAF_f(1) = 0;

% I_medfilt(:,:,:,1) = I_original;
for t = 1:50
    for i = 1:3
        tmp(:,:,i) = medfilt2(I_original(:,:,i), [2*t, 2*t]);
    end
%     I_medfilt(:,:,:,t+1) = tmp;

    [robust_seal, semifragile_seal] = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);
    NC_f(t+1) = nc(I_semifragile_seal, semifragile_seal);
    TAF_f(t+1) = TAF(I_semifragile_seal, semifragile_seal);
end

x = linspace(0, 100, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
plot(x, NC_f, '-+');hold on;
plot(x, TAF_f, '-.');hold on;
grid on;
xlabel('滤波器尺寸');
ylabel('NC & TAF');
legend('NC (鲁棒水印)', 'TAF (鲁棒水印)', 'NC (半脆弱水印)', 'TAF (半脆弱水印)', 'Location','best');
saveas(gcf, 'test/medfilt', 'svg');

% 生成示例图
t = 30;
for i = 1:3
    tmp(:,:,i) = medfilt2(I_original(:,:,i), [t, t]);
end
imwrite(tmp, ['test/lena_medfilt', num2str(t), '.bmp']);
[robust_seal, semifragile_seal] = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_medfilt', num2str(t), '.bmp']);
imwrite(semifragile_seal, ['test/semifragile_seal_medfilt', num2str(t), '.bmp']);


%% JPEG压缩

% I_compressed(:,:,:,1) = I_original;
for t = 0:50
    imwrite(I_original, ['test/lena_compressed_tmp', '.jpg'], 'Quality', 2*t);
%     I_compressed(:,:,:,t+1) = imread(['test/lena_compressed', num2str(10*t), '.jpg']);
    tmp = imread(['test/lena_compressed_tmp', '.jpg']);
    
    [robust_seal, semifragile_seal] = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);
    NC_f(t+1) = nc(I_semifragile_seal, semifragile_seal);
    TAF_f(t+1) = TAF(I_semifragile_seal, semifragile_seal);
end

x = linspace(0, 100, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
plot(x, NC_f, '-+');hold on;
plot(x, TAF_f, '-.');hold on;
grid on;
xlabel('质量因子');
ylabel('NC & TAF');
legend('NC (鲁棒水印)', 'TAF (鲁棒水印)', 'NC (半脆弱水印)', 'TAF (半脆弱水印)', 'Location','best');
saveas(gcf, 'test/compressed', 'svg');

% 生成示例图
t = 30;
imwrite(I_original, ['test/lena_compressed_tmp', '.jpg'], 'Quality', t);
tmp = imread(['test/lena_compressed_tmp', '.jpg']);
imwrite(tmp, ['test/lena_compressed', num2str(t), '.bmp']);
[robust_seal, semifragile_seal] = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_compressed', num2str(t), '.bmp']);
imwrite(semifragile_seal, ['test/semifragile_seal_compressed', num2str(t), '.bmp']);


%% 拼贴1

NC_r(1) = 1;
NC_f(1) = 1;
TAF_r(1) = 0;
TAF_f(1) = 0;

% I_paste1(:,:,:,1) = I_original;
s = size(I_original);
w = s(1) - mod(s(1), 50);
h = s(2);
for t = 1:50
    tmp = I_original;
    tmp2 = tmp(1:w/50*t, h/2+1:h, :);
    tmp(1:w/50*t, h/2+1:h, :) = tmp(1:w/50*t, 1:h/2, :);
    tmp(1:w/50*t, 1:h/2, :) = tmp2;
%     I_paste1(:,:,:,t+1) = tmp;
    
    [robust_seal, semifragile_seal] = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);
    NC_f(t+1) = nc(I_semifragile_seal, semifragile_seal);
    TAF_f(t+1) = TAF(I_semifragile_seal, semifragile_seal);
end

x = linspace(0, 100, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
plot(x, NC_f, '-+');hold on;
plot(x, TAF_f, '-.');hold on;
grid on;
xlabel('比例');
ylabel('NC & TAF');
legend('NC (鲁棒水印)', 'TAF (鲁棒水印)', 'NC (半脆弱水印)', 'TAF (半脆弱水印)', 'Location','best');
saveas(gcf, 'test/paste1', 'svg');

% 生成示例图
t = 25;
tmp = I_original;
tmp2 = tmp(1:w/50*t, h/2+1:h, :);
tmp(1:w/50*t, h/2+1:h, :) = tmp(1:w/50*t, 1:h/2, :);
tmp(1:w/50*t, 1:h/2, :) = tmp2;
imwrite(tmp, ['test/lena_paste1_', num2str(t*2), '.bmp']);
[robust_seal, semifragile_seal] = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_paste1_', num2str(t*2), '.bmp']);
imwrite(semifragile_seal, ['test/semifragile_seal_paste1_', num2str(t*2), '.bmp']);


%% 拼贴2

NC_r(1) = 1;
NC_f(1) = 1;
TAF_r(1) = 0;
TAF_f(1) = 0;

% I_paste2(:,:,:,1) = I_original;
I_source = imread('img/peppers.bmp');
s = size(I_original);
w = s(1) - mod(s(1), 50);
h = s(2);
for t = 1:50
    tmp = I_original;
    tmp(1:w/50*t, :, :) = I_source(1:w/50*t, :, :);
%     I_paste2(:,:,:,t+1) = tmp;
    
    [robust_seal, semifragile_seal] = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);
    NC_f(t+1) = nc(I_semifragile_seal, semifragile_seal);
    TAF_f(t+1) = TAF(I_semifragile_seal, semifragile_seal);
end

x = linspace(0, 100, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
plot(x, NC_f, '-+');hold on;
plot(x, TAF_f, '-.');hold on;
grid on;
xlabel('比例');
ylabel('NC & TAF');
legend('NC (robust seal)', 'TAF (robust seal)', 'NC (semifragile seal)', 'TAF (semifragile seal)', 'Location','best');
saveas(gcf, 'test/paste2', 'svg');

% 生成示例图
t = 25;
tmp = I_original;
tmp(1:w/50*t, :, :) = I_source(1:w/50*t, :, :);
imwrite(tmp, ['test/lena_paste2_', num2str(t*2), '.bmp']);
[robust_seal, semifragile_seal] = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_paste2_', num2str(t*2), '.bmp']);
imwrite(semifragile_seal, ['test/semifragile_seal_paste2_', num2str(t*2), '.bmp']);


%% 剪切 (shear)

for t = 0:50
    tform = affine2d([1 0 0; t*0.02 1 0; 0 0 1]);
	J = imwarp(I_original, tform, 'cubic');
    s = size(J);
    tmp = imcrop(J, [round(s(2)/2) - 255, 1, 511, 511]);
    
    [robust_seal, semifragile_seal] = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);
    NC_f(t+1) = nc(I_semifragile_seal, semifragile_seal);
    TAF_f(t+1) = TAF(I_semifragile_seal, semifragile_seal);
end

x = linspace(0, 1, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
plot(x, NC_f, '-+');hold on;
plot(x, TAF_f, '-.');hold on;
grid on;
xlabel('剪切强度');
ylabel('NC & TAF');
legend('NC (鲁棒水印)', 'TAF (鲁棒水印)', 'NC (半脆弱水印)', 'TAF (半脆弱水印)', 'Location','best');
saveas(gcf, 'test/shear', 'svg');

% 生成示例图
t = 0.6;
tform = affine2d([1 0 0; t 1 0; 0 0 1]);
J = imwarp(I_original, tform, 'cubic');
s = size(J);
tmp = imcrop(J, [round(s(2)/2) - 256, 1, 511, 511]);
imwrite(tmp, ['test/lena_shear', num2str(t), '.bmp']);
[robust_seal, semifragile_seal] = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_shear', num2str(t), '.bmp']);
imwrite(semifragile_seal, ['test/semifragile_shear', num2str(t), '.bmp']);


%% 剪切 (crop)

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
    
    [robust_seal, semifragile_seal] = dec_func(tmp);
    NC_r(t+1) = nc(I_zero_robust_seal, robust_seal);
    TAF_r(t+1) = TAF(I_zero_robust_seal, robust_seal);
    NC_f(t+1) = nc(I_semifragile_seal, semifragile_seal);
    TAF_f(t+1) = TAF(I_semifragile_seal, semifragile_seal);
end

x = linspace(0, 100, 51);
plot(x, NC_r, '-o');hold on;
plot(x, TAF_r, '-');hold on;
plot(x, NC_f, '-+');hold on;
plot(x, TAF_f, '-.');hold on;
grid on;
xlabel('比例');
ylabel('NC & TAF');
legend('NC (robust seal)', 'TAF (robust seal)', 'NC (semifragile seal)', 'TAF (semifragile seal)', 'Location','best');
saveas(gcf, 'test/crop', 'svg');

% 生成示例图
t = 45;
tmp = I_original;
tmp(1:w/50*t, :, :) = 0;
imwrite(tmp, ['test/lena_crop', num2str(t*2), '.bmp']);
[robust_seal, semifragile_seal] = dec_func(tmp);
imwrite(robust_seal, ['test/robust_seal_crop', num2str(t*2), '.bmp']);
imwrite(semifragile_seal, ['test/semifragile_seal_crop', num2str(t*2), '.bmp']);


%% 其他测试

% I = imread('img/peppers.bmp');
% [robust_seal, semifragile_seal] = dec_func(I);

I = imread('img/lake.bmp');
[robust_seal, semifragile_seal] = dec_func(I);
subplot(1, 2, 1);imshow(robust_seal);
subplot(1, 2, 2);imshow(semifragile_seal);