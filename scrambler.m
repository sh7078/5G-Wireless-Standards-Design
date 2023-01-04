%%% function for scrambling

% Scrambler input= input for scrambling
% f4= gives scrambled output
% f5= gives pseudo random sequence 

function [f4,f5]=scrambler(scramblerInput)
    x1=zeros(1,length(scramblerInput)+1600); %--added 1600 samples because we have to remove first 1600 samples according to standard
    x2=zeros(1,length(scramblerInput)+1600); %--added 1600 samples because we have to remove first 1600 samples according to standard
    for i=0:30
        if i==0
            x1(1,i+1)=1;
            x2(1,i+1)=1;
        elseif i>0&&i<=7
            x2(1,i+1)=1;
        end
    end
    for j=1:length(scramblerInput)+1600-31
        x1(1,j+31)=xor(x1(1,j+3),x1(1,j));
        a=xor(x2(1,j+3),x2(1,j+2));
        b=xor(x2(1,j+1),x2(1,j));
        x2(1,j+31)=xor(a,b);
    end
    c=xor(x1,x2);
    c_dash=c(1601:length(scramblerInput)+1600); %--removing 1600 samples
    f4=xor(c_dash,scramblerInput);
    f5=c_dash;
end