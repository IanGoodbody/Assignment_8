Granted this is probably way more complicated than it needs to be. In any event 
this should do the trick. You can control the speed using the interrupt 
function in Assn8_Goodbody.c. Fine movement in the program is default and I
still can't get multiple balls to not run over each other which is beginning
to get to me.

As far as functionality goes. The interrupt function is seperate from the main
which leads to some scoping problems. Ideally the interrupt subroutine woudld 
call the move ball function and call it a day but unfortunately it can't. I 
circumvented this problem by having the interrupt routine change the memory 
control register to 00 which effectively stops the timer. The while loop then
checks those two MC bits constantly and when they go to zero makes a call to 
the move funciton, redraws, then resets the MC back to MC_1.
