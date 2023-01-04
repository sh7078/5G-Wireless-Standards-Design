%clc;
clear all;
num_PRBs=input('Enter the number of PRBs(Example=100): ');
modulationIndex=input('Enter the modulation number(Example:Q=2(for MCS-9)): ');
transportBlockSize=num_PRBs*modulationIndex*162;
%---------- Enter the size of transport block without CRC (Ex.-20496)------
transportBlockLength=input('Enter the size of Transport Block(Example=20496): '); 
%---------- Created transport block message -------------------------------
transport_block_msg=randi([0 1],1,transportBlockLength);
%---------- Created transport block CRC -----------------------------------
transportBlock_CRC=input('Enter the non zero index of generate polynomial(Ex:[24,23,6,5,1,0])): ');
disp('Wait for a few seconds...');
gen_Polynomial=0;
for i=1:length(transportBlock_CRC)
   gen_Polynomial(1,transportBlock_CRC(1,i)+1)=1;
end
%------ generated appended zeros for transport block and code bloc---------
appendData=zeros(1,length(gen_Polynomial)-1);
%-- remainder is a function used to calculate remainder when message is divided by generated polynomil--------------
transport_block_CRC=remainder([transport_block_msg,appendData],gen_Polynomial);
crc_length=length(transport_block_CRC);
%------- appended transport block crc to transport block message-----------
transportBlock=[transport_block_msg transport_block_CRC];

B=transportBlockLength+crc_length;  %--B= transport block length with CRC--  
no_codeBlock=ceil(B/(8448-24));     %-- number of code block--
total_transportBlockLength=24*no_codeBlock+B;   %--effective transport block length--
length_codeBlock=total_transportBlockLength/no_codeBlock;   %-- length of each code block--

Zc=[2:16 18:2:32 36:4:64 72:8:128 144:16:256 288:32:384];   %-- limiting factor table--

%---- calculate K for calculating length of code block with filler bits----
for i=1:length(Zc)
    if(22*Zc(1,i)>=length_codeBlock)
        z=Zc(1,i);
        K=22*Zc(1,i);
        break
    end
end
%------ filler bits length------------
filler_bits_length=K-length_codeBlock;
filler_bits=zeros(1,filler_bits_length);

codeBlock=0;
final_codeBlock=0; 

nbg = 1; % Base graph 1
nldpcdecits = 25; % Decode with maximum no of iteration

concatenate_codeBlocks=[];  %initialization for concatenation output of LDPC decoder
k=0;
scramb_input=[]; %initialization to give scrambling output
rateMatchingLength=transportBlockSize/no_codeBlock;
%--Loop for encode and Rate recovey of each code block and conctenation for modulation---
for i=1:no_codeBlock
    codeBlock=transportBlock((k+1):(k+length_codeBlock-24)); % segmentation of code block without CRC and filer bits
    codeBlock_CRC=remainder([codeBlock,appendData],gen_Polynomial); %CRC calculation each code block
    
    final_codeBlock=[codeBlock,codeBlock_CRC,filler_bits];  %append CRC and filler bits to code block
    code_block=final_codeBlock.';   %transpose of final code block to give input to LDPC encoder
    k=k+length_codeBlock-24;

  
    %-----------------------------LDPC encoding----------------------------
  
    ldpc_coded_bits = double(LDPCEncode(code_block,nbg)); 
    
    % For 100 PRBs total transport block size=100*(12*14-6)*2{2 for MCS-9}=32400
    % size of code block=32400/3=10800
    
    ldpc_coded_bits=ldpc_coded_bits.';
  
    %--------------Interleaving and Rate matching--------------------------
    rate_output=interleaving(ldpc_coded_bits(1:rateMatchingLength),rateMatchingLength,modulationIndex);
    %-----------------Concatenation after interleaving---------------------
    scramb_input=[scramb_input rate_output];
end
%---------------------------Scrambling-------------------------------------
     [scramblingOutput,c]=scrambler(scramb_input);

%-------------Soft Modulation and Demodulation with noise------------------

    demod_output=mod_demod(scramblingOutput);
    demod_output=demod_output.';
    
    llr0 =  abs(-1 + demod_output);   % Soft demod
    llr1 =  abs(1 + demod_output);    % Soft demod

    llr = log(llr0./llr1);      % ldpc decoder requires log(p(r/0)/p(r/1))
    demod_output = llr;
    output = demod_output.';
%-------------------Descrambling after concatenation-----------------------
    deScrambling=descrambling(output,c);

%---Deinterleaving, Rate Recovery and LDPC decoding of each code block-----
k=0;
l=0;

for i=1:no_codeBlock
    %-------------------------DeInterleaving-------------------------------
    de_interleacingInput=deScrambling((k+1):(k+rateMatchingLength));
    k=k+rateMatchingLength;
    de_interleaving=reshape(de_interleacingInput,[modulationIndex,rateMatchingLength/modulationIndex]);
    de_interleavingOutput=[];
    for j=1:modulationIndex
        de_interleavingOutput=[de_interleavingOutput de_interleaving(j,:)];
    end
    %------------------------- Rate Recovery-------------------------------
    rate_recovery_output=[de_interleavingOutput zeros(1,(66*z-rateMatchingLength))]; %---appending zeros for rate recovery---      

    %------------------------- LDPC decoding-------------------------------

    outputbits = double(LDPCDecode(rate_recovery_output.',nbg,nldpcdecits));
    fprintf('error in %d codeBlock',i);
    outputbits_transpose=outputbits.';
    %errors = find(outputbits_transpose(1:length(codeBlock)) - transportBlock((l+1):(l+length_codeBlock-24))) %-- check for LDPC encoder input and LDPC decoder output--
    l=l+length_codeBlock-24;

    %-------Code Block validation after LDPC decoding for each block-------
    codeBlock_val= remainder(outputbits_transpose(1:length_codeBlock),gen_Polynomial);
    disp(codeBlock_val);

    %----Concatenate codeBlocks by removing filler bits and  CodeBlock-CRC-----
    concatenate_codeBlocks=[concatenate_codeBlocks, outputbits_transpose(1:(length_codeBlock-24))];
    
end    



disp('*********************************************************************************************');
if concatenate_codeBlocks==transportBlock
    disp('-----------Concated of output code block is same as transmitted block with CRC-----------');
    disp('True');
else
    disp('-----------Concated of output code block is same as transmitted block with CRC-----------');
    disp('false')
end

%----------------------------------Transport Block validation----------------------- -----------------
transportBlock_val=remainder(concatenate_codeBlocks,gen_Polynomial);
%disp(transportBlock_val);
disp('*********************************************************************************************');
if (transportBlock_val==zeros(length(gen_Polynomial)-1))
    disp("Transport block CRC validate");
else
    disp("Transport block CRC not validate");
end

%----------------------------------Transport Block CRC removal----------------------- -----------------
receivedMsg=concatenate_codeBlocks(1:(B-crc_length));
disp('*********************************************************************************************');
if receivedMsg==transport_block_msg
    disp('Received message is equals to transmitted message');
end