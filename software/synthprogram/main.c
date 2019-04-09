///*
// * main.c
// *
// *  Created on: Mar 28, 2019
// *      Author: Matt
// */
//
//#include "system.h"
//#include <stdint.h>
//#include <stdio.h>
//
//const uint16_t* amp = AMP_BASE;
//const uint32_t* freq = FREQ_BASE;
//const uint16_t* pll = SAMPLE_CLK_BASE;
//
//
//int main()
//{
//	for (;;) {
//		for (int i = 0; i < 10000000; i++);
//		printf("%04x\n", *pll);
//	}
//
//	return 0;
//}


// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng


int main()
{
	int i = 0;
	volatile unsigned int *LED_PIO = (unsigned int*)0x490; //make a pointer to access the PIO block
	*LED_PIO = 0; //clear all LEDs
	unsigned int result;

	while ( (1+1) != 3) //infinite loop
	{
		for (i = 0; i < 100000; i++); //software delay
		*LED_PIO |= 0x1; //set LSB
		for (i = 0; i < 100000; i++); //software delay
		*LED_PIO &= ~0x1; //clear LSB



	}
	return 1; //never gets here
}
