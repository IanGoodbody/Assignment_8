/*
 * Assn8_bounce.c
 *
 *  Created on: Oct 30, 2014
 *      Author: C2C Ian Goodbody
 *    Function: Provides the supporting functions for
 *    			a bouncing ball program
*/


#include <msp430g2553.h>
#include "Assn8_bounce.h"

/*
 * Initializes the interrupt registers
 */
void initInterrupt()
{
	TA0CCR0 = 0xFFFF;						// TA0CCR0 set fairly aribtrairly
	TACTL &= ~TAIFG;
	TACTL = ID_3 | TASSEL_2 | MC_1 | TAIE;	// USE the ID register to set the speed.

	_enable_interrupt();
}

#pragma vector = TIMER0_A1_VECTOR
__interrupt void timeOverflow(void)
{
	TACTL &= ~(BIT4|BIT5); 	// Clear the two memory controll bits and set so the timer no longer counts
	TACTL &= ~TAIFG;		// Clear teh pesky flag.
}

/*
 * drawBall(ballStruct *ballPtr)
 * 		A wrapper function for the draw pattern function
 */
void drawBall(ballStruct *ballPtr)
{
	drawPattern(ballPtr->position.y, ballPtr->position.x, ballPtr->pattern, ballPtr->width);
}

/*
 * moveBall(ballStruct *ballPtr)
 * 		Moves the ball at ballPtr by it's velocity vectors
 */
void moveBall(ballStruct *ballPtr)
{
	if(hitTop(ballPtr) || hitBottom(ballPtr))
		ballPtr->velocity.y = 0 - ballPtr->velocity.y;
	if(hitLeft(ballPtr) || hitRight(ballPtr))
		ballPtr->velocity.x = 0 - ballPtr->velocity.x;

	ballPtr->position.x += ballPtr->velocity.x;
	ballPtr->position.y += ballPtr->velocity.y;
}

/*
 * hitRight(ballStruct *ballPtr)
 * 		Returns a logical true if the ball has collided with the top
 * 		of the screen and is headed off the screen
 */
byte hitTop(ballStruct *ballPtr)
{
	if(ballPtr->position.y <= 0 && ballPtr->velocity.y < 0) return 1;
	else return 0;
}

/*
 * hitLeft(ballStruct *ballPtr)
 * 		Reutns a logical true if the ball has collided with the left of
 * 		the screen
 */
byte hitLeft(ballStruct *ballPtr)
{
	if(ballPtr->position.x <= 0 && ballPtr->velocity.x < 0) return 1;
	else return 0;
}

/*
 * hitRight(ballStruct *ballPtr)
 * 		Reutns a logical true if the ball has collided with the right of
 * 		the screen
 */
byte hitRight(ballStruct *ballPtr)
{
	if(ballPtr->position.x >= SCREEN_WIDTH-ballPtr->width && ballPtr->velocity.x > 0) return 1;
	else return 0;
}

/*
 * hitBottom(ballStruct *ballPtr)
 * 		Reutns a logical true if the ball has collided with the bottom of
 * 		the screen
 */
byte hitBottom(ballStruct *ballPtr)
{
	if(ballPtr->position.y >= SCREEN_HEIGHT-8 && ballPtr->velocity.y > 0) return 1;
	else return 0;
}
