function h = LiFi_channel_Specular(Num_of_FFT, length_of_CP, SampleRate, A, Phi, Phi_half, phi_half, d, theta, Phi_TXS, theta_TXS, d_TXS, alpha, blockage_probability)

k = -log(2) / log(cos(Phi_half)); 

h_Specular_tr = zeros(size(theta_TXS)); 

if theta <= phi_half && theta >= 0 
    
    h_Los_tr = A * (k+1) * (cos(Phi)^k) * cos(theta) / (2 * pi * d^2); 

else

    h_Los_tr = 0;

end

for i = 1:length(Phi_TXS)

    h_Specular_tr(i) = alpha * A * (k+1) * (cos(Phi_TXS(i))^k) * cos(theta_TXS(i)) / (2 * pi * d_TXS(i)^2); 

end

h_Specular_tr = sum(h_Specular_tr, 'all'); 

tau = d_TXS / 3e8 * SampleRate; 

if rand < blockage_probability

    AveragePathGains = h_Los_tr; 
    PathDelays = 0; 

else 

    AveragePathGains = [h_Los_tr, h_Specular_tr]; 
    PathDelays = [0, tau]; 

end

n = 1 : Num_of_FFT - 1;

h = zeros(Num_of_FFT, 1);

h_temp = zeros(Num_of_FFT, 1);

for i = 1:size(PathDelays, 2)

    if PathDelays(i) == 0
    
        h_temp(1) = AveragePathGains(i) * exp(-1j * pi / Num_of_FFT * ((Num_of_FFT - 1) * PathDelays(i))) .* Num_of_FFT;
    
    else

        h_temp(1) = AveragePathGains(i) * exp(-1j * pi / Num_of_FFT * ((Num_of_FFT - 1) * PathDelays(i))) .* (sin(pi * PathDelays(i)) ./ sin(pi / Num_of_FFT * (PathDelays(i))));

    end

    h_temp(2:end) = AveragePathGains(i) * exp(-1j * pi / Num_of_FFT * (n + (Num_of_FFT - 1) * PathDelays(i))) .* (sin(pi * PathDelays(i)) ./ sin(pi / Num_of_FFT * (PathDelays(i) - n)));

    h = h + h_temp; 

end

h = h(1:length_of_CP); 
