function Unrecovered_Signal = DCO_OFDM_Receiver(Received_Signal, FFT_Size, Length_of_CP, Length_of_symbol)

% S2P
Received_Signal = Received_Signal - mean(Received_Signal);
Received_Signal = reshape(Received_Signal, Length_of_symbol, []);

% Remove CP
Received_signal_removed_CP = Received_Signal(Length_of_CP + 1 : end, :);

% FFT
Unrecovered_Signal = fft(Received_signal_removed_CP);
Unrecovered_Signal = (1 / sqrt(FFT_Size)) * Unrecovered_Signal;
