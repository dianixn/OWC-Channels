function [Transmitted_Signal, Data_location] = DCO_OFDM_Transmitter(Pilot_value, Pilot_location_symbols, Pilot_location, Frame_size, Num_of_FFT, CP_Size, bias_level, QPSK_signal)

% Pilot inserted
Data_out = zeros(Num_of_FFT, Frame_size);

for Pilot_location_symbol = Pilot_location_symbols
    Pilot_location_frequency = Pilot_location(:, Pilot_location_symbol == Pilot_location_symbols);
    Data_out(Pilot_location_frequency, Pilot_location_symbol) = Pilot_value;
end

Data_location = 1 : Frame_size;
Data_location(Pilot_location_symbols) = [];

Data_out(2:(Num_of_FFT/2), Data_location) = QPSK_signal;

Data_out((Num_of_FFT/2 + 2):Num_of_FFT, Data_location) = flip(conj(QPSK_signal)); 

Data_out((Num_of_FFT/2 + 2):Num_of_FFT, Pilot_location_symbols) = flip(conj(Data_out(2:(Num_of_FFT/2), Pilot_location_symbols)));

Data_out([1, (Num_of_FFT/2 + 1)], :) = 0; 

% IFFT
data_in_CP = ifft(Data_out); 
data_in_CP = sqrt(Num_of_FFT) * data_in_CP;
% CP
Signal_from_baseband = [data_in_CP(Num_of_FFT - CP_Size + 1 : end, :); data_in_CP];

% P2S
Transmitted_Signal = reshape(Signal_from_baseband, [], 1);

% Add bias

bias_level = 10^(bias_level/10);
bias = bias_level * sqrt(mean(Transmitted_Signal.^2, 'all'));
Transmitted_Signal = Transmitted_Signal + bias;
