function [LL, LH, HL, HH] = DWT(input, wavelet)

    [C, S] = wavedec2(input, 3, wavelet);
    [LH, HL, HH] = detcoef2('all', C, S, 3);
    LL = appcoef2(C, S, wavelet, 3);

end