%%% function for descrambling

% demod_output=demodulation output
% c_dash=pseudo random sequence used in scrammbling
% f6=gives descrambled output

function f6=descrambling(demod_output,c_dash)
    c__dash=c_dash.*2-1;
    for k=1:length(demod_output)
        if c__dash(k)==-1
            output(k)=demod_output(k);
        elseif c__dash(k)==1
            output(k)=-1*demod_output(k);
        end
    end
    f6=output;
end