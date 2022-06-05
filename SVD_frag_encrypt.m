function semifragile_seal = SVD_frag_encrypt(I_original, I_semifragile_seal)
% ���ܴ���ˮӡ
I_original = imresize(I_original, [512,512]);
I_semifragile_seal = imresize(I_semifragile_seal, [64,64]);

% ��ԭʼ��ɫͼ�����ת��������ԭʼͼ�񣬽���ת��ΪYCbCrͼ�񣬲��ֽ��Y��Cb��Crͨ����

Red = I_original(:,:,1);
Green = I_original(:,:,2);
Blue = I_original(:,:,3);

Y = 0.299*Red + 0.587*Green + 0.114*Blue;
Cb = -0.1687*Red - 0.3313*Green + 0.5*Blue + 128;
Cr = 0.5*Red - 0.4187*Green - 0.0813*Blue + 128;

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

% ��ȡ���ڹ�������ˮӡͼ�����Ϣ����
 % ��LL3(i,j) �� LL3((i+1),j) �� LL3((i+2),j)ʱ����Ϣ�����Ԫ��Ϊ1������Ϊ0
 
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

% ����������ˮӡͼ��
 % ����Ϣ�����ԭʼ�����ˮӡ����������㣬����������ˮӡͼ��

semifragile_seal = xor(info, I_semifragile_seal);
semifragile_seal = mat2gray(semifragile_seal);

