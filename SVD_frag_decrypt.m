function semifragile_seal = SVD_frag_decrypt(I_test, zero_semifragile_seal)
% ���ܴ���ˮӡ
I_test = imresize(I_test, [512,512]);
zero_semifragile_seal = imresize(zero_semifragile_seal, [64,64]);

Red = I_test(:,:,1);
Green = I_test(:,:,2);
Blue = I_test(:,:,3);

Y = 0.299*Red + 0.587*Green + 0.114*Blue;
Cb = -0.1687*Red - 0.3313*Green + 0.5*Blue + 128;
Cr = 0.5*Red - 0.4187*Green - 0.0813*Blue + 128;

% �Դ����ͼ���Y*��Cb*��Cr*ͨ���ֱ�������߶ȵġ�db1����ɢС���任������������ֵ�ֽ⡣

[coefficient_subband(:,:,1), coefficient_subband(:,:,2), coefficient_subband(:,:,3), coefficient_subband(:,:,4)] = DWT(Y, 'db1');
[coefficient_subband(:,:,5), coefficient_subband(:,:,6), coefficient_subband(:,:,7), coefficient_subband(:,:,8)] = DWT(Cb, 'db1');
[coefficient_subband(:,:,9), coefficient_subband(:,:,10), coefficient_subband(:,:,11), coefficient_subband(:,:,12)] = DWT(Cr, 'db1');

% ����������ȡ�����ˮӡͼ�����Ϣ����

LL3 = coefficient_subband(:,:,1);
LL3_size = size(LL3);

for i = 0:LL3_size(1)-1
    for j = 0:LL3_size(2)-1
        if (LL3(i+1, j+1) >= LL3(mod(i+1, LL3_size(1))+1, j+1)) && ...
                (LL3(mod(i+1, LL3_size(1))+1, j+1) >= LL3(mod(i+2, LL3_size(1))+1, j+1))
            info(i+1, j+1) = 1;
        else
            info(i+1, j+1) = 0;
        end
    end
end

% ��ȡ�����ˮӡͼ��
 % ����һ��õ�����Ϣ�����������ˮӡ����������㣬��õ���ȡ�İ����ˮӡͼ��

semifragile_seal = xor(info, zero_semifragile_seal);
semifragile_seal = mat2gray(semifragile_seal);
