% function is to calculate remainder

function f1=remainder(finalMessage,CRC)
   len_CRC=length(CRC);
   temp=finalMessage(1:len_CRC);
   while (len_CRC<length(finalMessage))
       if (temp(1,1) == 1)
           temp=xor(CRC,temp);
           if(temp(1,1)==0)
               temp=[temp(2:length(CRC)),finalMessage(1,len_CRC+1)];
           end
       else
           temp=[temp(2:length(CRC)),finalMessage(1,len_CRC+1)];
       end
      
       len_CRC=len_CRC+1;
   end
   if (temp(1,1)==1)
       temp=xor(temp,CRC);  
       temp=temp(2:length(CRC));
   else
       temp=temp(2:length(CRC));
   end
   f1=temp;
end
