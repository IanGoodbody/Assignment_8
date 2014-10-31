/*
 * lab4_bounce.c
 *
 *  Created on: Oct 21, 2014
 *      Author: C2C Ian Goodbody
 *    Function: Implements the B functionality
 * 		For this lab. Creates a single
 * 		ball that bounces around the screen
*/


#include <msp430g2553.h>
#include "Assn8_bounce.h"

void main()
{

	byte pattern[GHOST_WD] = {GHOST}; // Initialize the happy face pattern in memory
	ballStruct ball;


	//Initalize all the ball parameters
	ball.position.x = 5;
	ball.position.y = 5;
	ball.velocity.x = -1;
	ball.velocity.y = -1;

	ball.pattern = pattern;
	ball.width = GHOST_WD;

	ballStruct *ballPtr = &ball;


	// === Initialize system ================================================
	IFG1=0; /* clear interrupt flag1 */
	WDTCTL=WDTPW+WDTHOLD; /* stop WD */


	init();
	initNokia();
	initInterrupt();
	clearDisplay();
	drawBall(ballPtr);


	while(1)
	{

		if(!(TACTL & (BIT5|BIT4)))		// The program uses the Memory Control register to check if there is an inturrupt, an inturrupt has occured with the clock has stopped
		{
			clearDisplay();
			moveBall(ballPtr);
			drawBall(ballPtr);
			TACTL |= MC_1;				// Reset the Memory Control register to count up mode and resume (this process is fairly nice as it slows down the refresh speed)
		}
	}

}


