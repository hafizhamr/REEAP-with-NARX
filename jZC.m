function ZC = jZC(X,threshold)
%% Fungsi Zero Crossing.
% Mendeteksi berapa jumlah sinyal yang melewati sumbu X (Y = 0).
% Jika sinyal mengandung noise, kita bisa menetapkan threshold
% sebagai pengganti lebar sumbu X, sehingga jika sinyal tersebut
% di dalam batas nilai treshold, maka tidak dihitung melewati
% sumbu X
%
% Input berupa:
% X = sinyal. vector sinyal
% threshold. skalar,nilai threshold
%
% Example:
% zz = randn(1, 10, 'single');
% plot(zz)
% Zc =jZC(zz, 1.2)
%

%% create by mohyusuf. Email: mohammad.yusuf.zamzami2016@fst.unair.ac.id
%%
N=length(X); % hitung panjang sinyal
ZC=0; %inisialisasi nilai ZC
for i=1:N-1 %looping i=1 s/d N-1
    if ((X(i) > 0 && X(i+1) < 0) || (X(i) < 0 && X(i+1) > 0))
%Sinyal melewati garis Nol?
        if (abs(X(i)-X(i+1)) >= threshold) %panjang sinyal lebih dari threshold?
            ZC = ZC + 1; % akumulasi ZC
        end
    elseif abs(X(i)) > abs(X(i+1)) %Sinyal tidak melewati Nol
        X(i+1) = X(i); % geser nilai
    end
end % akhir loopings
end