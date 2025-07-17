function Transmitted_Signal = DCO_OFDM_Transmitter_for_channel(Pilot_value, Frame_size, Num_of_FFT, CP_Size)

% Pilot inserted

Data_out = Pilot_value * ones(Num_of_FFT, Frame_size); 

% IFFT
data_in_CP = ifft(Data_out); 
data_in_CP = sqrt(Num_of_FFT) * data_in_CP;
% CP
Signal_from_baseband = [data_in_CP(Num_of_FFT - CP_Size + 1 : end, :); data_in_CP];

% P2S
Transmitted_Signal = reshape(Signal_from_baseband, [], 1); 
