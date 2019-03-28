### Game description
This is a Whack-a-mole simulation game, player will press the corresponding switch when the led light
on.

![image](https://drive.google.com/uc?export=view&id=1QtCn3fQ-uGEPSDyrX9Q-StpWDHnFVptz)

### How to play
When the player press reset switch, the game will start and show a back and forth led patten
toindicate player the game is ready to start in any time.  
The player then hold any of the four switch at least one second to start the game. A different led
patten will indicate the game is start. 
A random led will turn on, the player will initially have 2.5 second to press the corresponding
switch, if the switch was press correct, the respond time will decreas in smaller amount to increase 
the diffculty.
During the game, if the switch was press incorrect, the game will fail and end, a score will display by
led using binary representation. If the player keep press the correct switch 15 times, the game will win
and display the player's score.
	
### Problems, obstacles
The logic beside this game is not complicated, however the problem being stop me is the error A1284E,
literal pool too distant, which will limit my code lenght. The other problem is relocation out of range, it
is the same issue with previous problem. To slove this two problem, I have to write my code coupe times to 
make it short by using subroutine call to prevent redundant code. Also change the location of some code to
make it become a bridge to help relocation on the range. I implemented all basic features, no additional 
feature added.

### Adjustment
	No adjustment allowed due to the limited code lenght. 
	



 
