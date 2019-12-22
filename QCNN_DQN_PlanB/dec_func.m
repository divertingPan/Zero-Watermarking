function I_robust_seal = dec_func(I_test)
I_zero_robust_seal = imread('encryption/zero_robust_seal.bmp');
[height, width, channel] = size(I_test);
seperate_size_h = height / 6;
seperate_size_w = width / 6;

batch = 1;
for i = 1:seperate_size_h:height
    for j = 1:seperate_size_w:width
        sub_img(batch,:,:,:) = I_test((floor(i/seperate_size_h)*floor(seperate_size_h) + 1) : (floor(i/seperate_size_h)*floor(seperate_size_h) + 56), ...
                                      (floor(j/seperate_size_w)*floor(seperate_size_w) + 1) : (floor(j/seperate_size_w)*floor(seperate_size_w) + 56), ...
                                      :);
        batch = batch + 1;
    end
end

X = sub_img;

save('tmp/test_input.mat', 'X');

[status, cmdout] = dos('QCNN_decrypt.bat');
if status == 0
    disp('predicting QCNN done!');
end
load('tmp/test_meddle_layer.mat');

for batch = 1:36
    for tmp = 1:36
        center = F(batch, 4, 4, tmp);
        ave = mean2(reshape(F(batch, :,:,tmp), 7, 7));
        if center > ave
            G(batch, tmp) = 0;
        else
            G(batch, tmp) = 1;
        end
    end
end

robust_seal = xor(G, I_zero_robust_seal);
a = 1;
b = 1;
N = 30;

I_robust_seal = arnold(robust_seal, a, b, N);
I_robust_seal = mat2gray(I_robust_seal);
