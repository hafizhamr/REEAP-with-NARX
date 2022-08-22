function ZC = jZC(X,threshold)
    % Mendeteksi berapa jumlah sinyal yang melewati sumbu X (Y = 0)
    % Zamzami(2020).

    N = length(X);  % Panjang sinyal
    ZC = 0;         % Inisialisasi nilai ZC
    for i=1:N-1
        % Jika melewati garis nol
        if ((X(i) > 0 && X(i+1) < 0) || (X(i) < 0 && X(i+1) > 0))
            % Jika panjang sinyal lebih dari threshold
            if (abs(X(i)-X(i+1)) >= threshold) 
                ZC = ZC + 1;            % Akumulasi nilai ZC
            end
        % Jika sinyal tidak melewati Nol
        elseif abs(X(i)) > abs(X(i+1)) 
            X(i+1) = X(i);              % Geser nilai
        end
    end
end
