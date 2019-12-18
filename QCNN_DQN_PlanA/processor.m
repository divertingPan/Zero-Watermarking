% 用此模块对图像作攻击，获得测试用例

%% 读取
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
legend('NC (robust seal)', 'TAF (robust seal)', 'Location','best');
saveas(gcf, 'test/gamma', 'svg');

% % 生成示例图
% tmp = imadjust(I_original, [], [], 0.5);
% imwrite(tmp, ['test/lena_gamma', num2str(0.5), '.bmp']);
% robust_seal = dec_func(tmp);
% imwrite(robust_seal, ['test/robust_seal_gamma', num2str(0.5), '.bmp']);


%% 旋转

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
xlabel('旋转角度/(°)');
ylabel('NC & TAF');
legend('NC (robust seal)', 'TAF (robust seal)');
saveas(gcf, 'test/rotate', 'svg');

% % 生成示例图
% tmp = imrotate(I_original, 30, 'bilinear', 'crop');
% imwrite(tmp, ['test/lena_rotate', num2str(30), '.bmp']);
% robust_seal = dec_func(tmp);
% imwrite(robust_seal, ['test/robust_seal_rotate', num2str(30), '.bmp']);



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
legend('NC (robust seal)', 'TAF (robust seal)', 'NC (semifragile seal)', 'TAF (semifragile seal)', 'Location','best');
saveas(gcf, 'test/gaussian', 'svg');

% % 生成示例图
% tmp = imnoise(I_original, 'gaussian', 0, 3);
% imwrite(tmp, ['test/lena_gaussian', num2str(3), '.bmp']);
% [robust_seal, semifragile_seal] = dec_func(tmp);
% imwrite(robust_seal, ['test/robust_seal_gaussian', num2str(3), '.bmp']);
% imwrite(semifragile_seal, ['test/semifragile_seal_gaussian', num2str(3), '.bmp']);


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

% % 生成示例图
% tmp = imnoise(I_original, 'salt & pepper', 0.03);
% imwrite(tmp, ['test/lena_saltpepper', num2str(0.03), '.bmp']);
% [robust_seal, semifragile_seal] = dec_func(tmp);
% imwrite(robust_seal, ['test/robust_seal_saltpepper', num2str(0.03), '.bmp']);
% imwrite(semifragile_seal, ['test/semifragile_seal_saltpepper', num2str(0.03), '.bmp']);


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
legend('NC (robust seal)', 'TAF (robust seal)', 'NC (semifragile seal)', 'TAF (semifragile seal)', 'Location','best');
saveas(gcf, 'test/medfilt', 'svg');

% % 生成示例图
% for i = 1:3
%     tmp(:,:,i) = medfilt2(I_original(:,:,i), [3, 3]);
% end
% imwrite(tmp, ['test/lena_medfilt', num2str(3), '.bmp']);
% [robust_seal, semifragile_seal] = dec_func(tmp);
% imwrite(robust_seal, ['test/robust_seal_medfilt', num2str(3), '.bmp']);
% imwrite(semifragile_seal, ['test/semifragile_seal_medfilt', num2str(3), '.bmp']);


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
legend('NC (robust seal)', 'TAF (robust seal)', 'NC (semifragile seal)', 'TAF (semifragile seal)', 'Location','best');
saveas(gcf, 'test/compressed', 'svg');

% % 生成示例图
% imwrite(I_original, ['test/lena_compressed_tmp', '.jpg'], 'Quality', 10);
% tmp = imread(['test/lena_compressed_tmp', '.jpg']);
% imwrite(tmp, ['test/lena_compressed', num2str(10), '.bmp']);
% [robust_seal, semifragile_seal] = dec_func(tmp);
% imwrite(robust_seal, ['test/robust_seal_compressed', num2str(10), '.bmp']);
% imwrite(semifragile_seal, ['test/semifragile_seal_compressed', num2str(10), '.bmp']);


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
legend('NC (robust seal)', 'TAF (robust seal)', 'NC (semifragile seal)', 'TAF (semifragile seal)', 'Location','best');
saveas(gcf, 'test/paste1', 'svg');

% % 生成示例图
% t = 10;
% tmp = I_original;
% tmp2 = tmp(1:w/50*t, h/2+1:h, :);
% tmp(1:w/50*t, h/2+1:h, :) = tmp(1:w/50*t, 1:h/2, :);
% tmp(1:w/50*t, 1:h/2, :) = tmp2;
% imwrite(tmp, ['test/lena_paste1_', num2str(t*2), '.bmp']);
% [robust_seal, semifragile_seal] = dec_func(tmp);
% imwrite(robust_seal, ['test/robust_seal_paste1_', num2str(t*2), '.bmp']);
% imwrite(semifragile_seal, ['test/semifragile_seal_paste1_', num2str(t*2), '.bmp']);


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

% % 生成示例图
% t = 45;
% tmp = I_original;
% tmp(1:w/50*t, :, :) = I_source(1:w/50*t, :, :);
% imwrite(tmp, ['test/lena_paste2_', num2str(t*2), '.bmp']);
% [robust_seal, semifragile_seal] = dec_func(tmp);
% imwrite(robust_seal, ['test/robust_seal_paste2_', num2str(t*2), '.bmp']);
% imwrite(semifragile_seal, ['test/semifragile_seal_paste2_', num2str(t*2), '.bmp']);


%% 剪切

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
legend('NC (robust seal)', 'TAF (robust seal)', 'NC (semifragile seal)', 'TAF (semifragile seal)', 'Location','best');
saveas(gcf, 'test/shear', 'svg');

% % 生成示例图
% tform = affine2d([1 0 0; 0.6 1 0; 0 0 1]);
% J = imwarp(I_original, tform, 'cubic');
% s = size(J);
% tmp = imcrop(J, [round(s(2)/2) - 256, 1, 511, 511]);
% imwrite(tmp, ['test/lena_shear', num2str(0.6), '.bmp']);
% [robust_seal, semifragile_seal] = dec_func(tmp);
% imwrite(robust_seal, ['test/robust_seal_shear', num2str(0.6), '.bmp']);
% imwrite(semifragile_seal, ['test/semifragile_shear', num2str(0.6), '.bmp']);


%% 其他测试

% I = imread('img/peppers.bmp');
% [robust_seal, semifragile_seal] = dec_func(I);

I = imread('img/lake.bmp');
[robust_seal, semifragile_seal] = dec_func(I);
subplot(1, 2, 1);imshow(robust_seal);
subplot(1, 2, 2);imshow(semifragile_seal);