function Pilot_values = scrambler_Zadoff_Chu(N, Root_index)

    n = 0:N-1;
    Pilot_values = exp((-1j*pi*Root_index*n.*(n+1))/N);

end
