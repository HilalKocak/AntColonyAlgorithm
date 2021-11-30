function j=RouletteWheelSelection(P)
    r=rand; % (0,1) random number
    
    C=cumsum(P);
    
   
    j=find(r<=C,1,'first');
end

