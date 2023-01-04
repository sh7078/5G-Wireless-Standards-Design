
%------ QPSK Modulation and Demodulation with the consideration of noise--------

function f3=mod_demod(data)


data_NZR=2*data-1; % Data Represented at NZR form for QPSK modulation
s_p_data=reshape(data_NZR,2,length(data)/2);  % S/P convertion of data


br=10.^6; %Let us transmission bit rate  1000000
f=br; % minimum carrier frequency
T=1/br; % bit duration
t=T/99:T/99:T; % Time vector for one bit information



% -------------------------------- QPSK modulation------------------------------ 
y=[];
y_in=[];
y_qd=[];
for i=1:length(data)/2
    y1=s_p_data(1,i)*cos(2*pi*f*t); % inphase component
    y2=s_p_data(2,i)*sin(2*pi*f*t) ;% Quadrature component
    y_in=[y_in y1]; % inphase signal vector
    y_qd=[y_qd y2]; %qua rature signal vector
    y=[y y1+y2]; % modulated signal vector
end
Tx_sig=y; % transmitting signal after modulation

% ----------------------------Adding noise after modulation----------------------- 

    noise_power = (10^-5);
    noise = sqrt(noise_power)*randn(size(Tx_sig));
    rx_sig = Tx_sig + noise;

% -------------------------------- QPSK demodulation------------------------------ 
Rx_data=[];
Rx_sig=Tx_sig; % Received signal
for i=1:1:length(data)/2

    % ------------ inphase coherent dector---------
    Z_in=Rx_sig((i-1)*length(t)+1:i*length(t)).*cos(2*pi*f*t); 
    % above line indicat multiplication of received & inphase carred signal
    Z_in_intg=(trapz(t,Z_in))*(2/T);% integration using trapizodial rull

    
    % ------------ Quadrature coherent dector ------------
    Z_qd=Rx_sig((i-1)*length(t)+1:i*length(t)).*sin(2*pi*f*t);
    %above line indicat multiplication ofreceived & Quadphase carred signal    
    Z_qd_intg=(trapz(t,Z_qd))*(2/T);%integration using trapizodial rull

    Rx_data=[Rx_data  Z_in_intg  Z_qd_intg]; % Received Data vector
end

f3=Rx_data;
end

    