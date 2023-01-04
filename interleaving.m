%%%-------------Function for Interleaving---------------------%%%

% Interleaving_input= rate matching output
% E= length of interleaving input=length of rate matching output
% Q= modulation index (Here Q=2)
% f5=returns interleaving output

function f5=interleaving(interleaving_input,E,Q)
    interleaverOut=[];
    interleaver=reshape(interleaving_input,[E/Q,Q]).'; % reshaping of rate matching ouput
    for m=1:E/Q
        interleaverOut=[interleaverOut interleaver(1,m) interleaver(2,m)];
    end
    f5=interleaverOut;
end