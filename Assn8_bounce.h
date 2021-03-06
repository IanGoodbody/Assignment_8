/*
 * lab4_bounce.h
 *
 *  Created on: Oct 21, 2014
 *      Author: C16Ian.Goodbody
 */

#ifndef LAB4_BOUNCE_H_
#define LAB4_BOUNCE_H_

#define	HAPPY		0x3C, 0x42, 0x95, 0xA1, 0xA1, 0x95, 0x42, 0x3C // data for the happy face pattern
#define HAPPY_WD	8

#define	BLOCK 		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF // data for block pattern
#define BLOCK_WD	8

#define GHOST		0xFE, 0x7F, 0xFB, 0x7F, 0xFB, 0x7E // data for the ghost pattern
#define GHOST_WD	6

#define CREEPY		0xFF, 0xF9, 0x89, 0xC7, 0xC7, 0x89, 0xF9, 0xFF // data for creeper face
#define CREEPY_WD	8

typedef unsigned char byte;

extern void init();
extern void initNokia();
extern void clearDisplay();
extern void waitNLoops(unsigned short nLoops);
extern void drawPattern(unsigned short y, unsigned short x, byte *paternStartPtr, unsigned short patternWidth);

typedef struct vector {
	signed short x;
	signed short y;
} vectorStruct;

typedef struct ballThing { 			// It is not necessarily a ball, sorry but this naming convention is easier for me
	vectorStruct position;
	vectorStruct velocity;
	unsigned short width;
	byte *pattern;
} ballStruct;

void initInterrupt();

void drawBall(ballStruct *ballPtr);

void moveBall(ballStruct *ballPtr);

//Collesion detection methods
byte hitRight(ballStruct *ballPtr);
byte hitLeft(ballStruct *ballPtr);
byte hitTop(ballStruct *ballPtr);
byte hitBottom(ballStruct *ballPtr);

#define		SCREEN_HEIGHT	68
#define		SCREEN_WIDTH	96

#endif /* LAB4_BOUNCE_H_ */
