function [LiFi_signal, fading_signal_channel_out, h, Noise_Variance] = LiFi_Channel(x, x_channel, model, SNR)

%% parameter - single reflection 

Parameter.parameters

while 1

A = 0.0001;
phi_half = pi/4; 
Phi_half = pi/4; 
k = -log(2) / log(cos(Phi_half)); 

x_room = 5; % Size_Room [-20, 20] 
y_room = 5;
z_room = 5; %(x,y,z)

pos_R = [random('Uniform', -x_room/2, x_room/2), random('Uniform', -y_room/2, y_room/2), random('Uniform', 0, 1)]; %input - position of receiver

pos_T = [0, 0, z_room]; % Centre point

Phi = acos((z_room - pos_R(3)) / norm(pos_T - pos_R, 2));

d = norm(pos_T - pos_R, 2); 

user_angle_1 = random('Uniform', 0, 2*pi); 
user_angle_2 = random('Uniform', 0, random('Uniform', 0, pi/6));

User_direction = [cos(user_angle_1)*sin(user_angle_2), sin(user_angle_1) * sin(user_angle_2), cos(user_angle_2)]; 

theta = acos(dot(User_direction, pos_T - pos_R) / norm(pos_T - pos_R, 2));

d_TXS = norm([pos_T(1), y_room - pos_T(2), pos_T(3)] - pos_R, 2); 

Phi_TXS = acos((pos_R(3) - pos_T(3)) ./ d_TXS); 

theta_TXS = acos(dot(User_direction, [pos_T(1), 2 * (y_room/2 - pos_T(2)), z_room] - pos_R) / norm([pos_T(1), 2 * (y_room/2 - pos_T(2)), z_room] - pos_R, 2));

m_s = 1; % rough surface

alpha = 0.7; % 0.1 0.3 0.5 0.7 

Specular_point = [random('Uniform', -x_room/3, x_room/3), y_room/2, random('Uniform', 3*z_room/10, 7*z_room/10)]; 

V = norm(Specular_point - pos_R, 2); 

delay_diff = (norm(Specular_point - pos_T, 2) + V) / 3e8 * SampleRate; 

l = (Specular_point - pos_T) / norm(Specular_point - pos_T, 2); 

n = [0, -1, 0]; 

f = dot(2 * n, l) * n - l; 

sigma = pi - acos(dot(f, pos_R - Specular_point) / norm(Specular_point - pos_R, 2)); 

theta_Diffuse = acos(dot(User_direction, Specular_point - pos_R) / norm(Specular_point - pos_R, 2)); 

if cos(theta) >= cos(phi_half) && cos(theta_Diffuse) >= cos(phi_half) 

    break
    
end

end

%% LOS 

if model == 'L'

            if cos(theta) >= cos(phi_half) %&& theta >= 0 

                h = A * (k+1) * (cos(Phi)^k) * cos(theta) / (2 * pi * d^2); 

            else

                h = 0;

            end


%% Specular + LOS 

elseif model == 'S'

h = Channel.LiFi_channel_Specular(Num_of_FFT, length_of_CP, SampleRate, A, Phi, Phi_half, phi_half, d, theta, Phi_TXS, theta_TXS, d_TXS, alpha, blockage_probability); 

%% Diffuse + LOS

elseif model == 'D'

h = Channel.LiFi_channel_Diffuse(Num_of_FFT, length_of_CP, A, Phi, Phi_half, phi_half, d, theta, V, delay_diff, m_s, theta_Diffuse, sigma, alpha, blockage_probability); 

end

%% Noise 

h = real(h); 

fading_signal = conv(h, x); 
fading_signal_channel_out = conv(h, x_channel);
fading_signal = fading_signal(1:length(x));
fading_signal_channel_out = fading_signal_channel_out(1:length(x));

Noise_Variance = mean(abs(fading_signal) .^ 2) / (10 ^ (SNR / 10));
n = sqrt(Noise_Variance) * randn(length(fading_signal), 1); 

LiFi_signal = fading_signal + n; 
