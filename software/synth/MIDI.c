/*
 * MIDI.c
 *
 *  Created on: Apr 12, 2019
 *      Author: Matt
 */

#include "MIDI.h"

static alt_u32* const controls = SYNTH_CONTROLLER_0_BASE;

static char * CIN_names[] = {"Miscellaneous Function Code",
                            "Cable Event",
                            "2-Byte System Common Message",
                            "3-Byte System Common Message",
                            "SysEx Start or Continue",
                            "Single-Byte System Common Message OR SysEx ends with following single byte",
                            "SysEx ends with following two bytes",
                            "SysEx ends with following three bytes",
                            "Note-off",
                            "Note-on",
                            "Poly-KeyPress",
                            "Control Change",
                            "Program Change",
                            "Channel Pressure",
                            "Pitchbend Change",
                            "Single Byte"};

void initControls()
{
//	alt_u8* const freq = FREQ0_BASE;
//	alt_u16* const amp = AMP0_BASE;
//	alt_u8* const key_on =  KEY_ON_BASE;
//	alt_u8* const shape = SHAPESEL_BASE;
//	alt_u16* const attack = ATTACK_BASE;
//	alt_u16* const decay = DECAY_BASE;
//	alt_u16* const sustain = SUSTAIN_BASE;
//	alt_u16* const release = RELEASE0_BASE;
//
//
//	*freq = 0;
//	*amp = 0;
//	*key_on = 0;
//	*shape = 0;
//	*attack = 0x7FFF;
//	*decay = 0x7FFF;
//	*sustain = 0x7FFF;
//	*release = 0x7FFF;
}

void ProcessMIDIPacket(alt_u32 packet)
{

    alt_u8 bytes[4];
    for (int i = 0; i < 4; i ++) {
        //bytes[i] = (packet >> (8*(3-i))) & 0xff;
        bytes[i] = ((alt_u8*)&packet)[i];
//        printf("%02x", bytes[i]);
    }

//    printf("\n");

    alt_u8 CIN = bytes[0];
    alt_u8 note = bytes[2];
    alt_u8 velocity = bytes[3];
//    alt_u8 control = bytes[2];
//    long ADSR;

    switch(CIN) {
        case NOTE_ON:
        	controls[7] = 0x01;
    		controls[8] = (alt_u32)note;
    		//*hex = note;
    		controls[9] = (alt_u32)velocity << 8;
            break;
        case NOTE_OFF:
        	if (controls[8] == (alt_u32)note) {
        		//*hex = 0;
        		controls[7] = 0x00;
        	}
        	break;
//        case CONTROL_CHANGE:
//        	if (control == 0x18) {
//        		if (velocity == 0)
//        			*shape = *shape & ~0x01; // Clear the first bit
//        		else
//        			*shape = *shape | 0x01; // Set the first bit
//        	} else if (control == 0x19) {
//        		if (velocity == 0)
//        			*shape = *shape & ~0x02; // Clear the second bit
//        		else
//        			*shape = *shape | 0x02; // Set the second bit
//        	}else if (control == 0x1a) {
//        		if (velocity == 0)
//        		    *shape = *shape & ~0x04; // Clear the third bit
//        		else
//        		    *shape = *shape | 0x04; // Set the third bit
//        	}else if (control == 0x1b) {
//        		if (velocity == 0)
//        		    *shape = *shape & ~0x08; // Clear the fourth bit
//        		else
//        		    *shape = *shape | 0x08; // Set the fourth bit
//        	} else if (control == 0x01){ //attack
//        		ADSR = map((alt_u16)velocity, 0, 0x007F, 0, 0x7FFF);
//        		*attack = ADSR;
//        	} else if (control == 0x02){ //decay
//        		ADSR = map((alt_u16)velocity, 0, 0x007F, 0, 0x7FFF);
//        		*decay = ADSR;
//        	} else if (control == 0x03){ //sustain
//        		ADSR = map((alt_u16)velocity, 0, 0x007F, 0, 0x7FFF);
//        		*sustain = ADSR;
//        	} else if (control == 0x04){ //release
//        		ADSR = map((alt_u16)velocity, 0, 0x007F, 0, 0x7FFF);
//        		*release = ADSR;
//        	}




            for (int i = 0; i < 4; i ++) {
                printf("%02x", bytes[i]);
            }
            printf("\n");
        	break;

        default:
            printf("Got unsupported CIN %02x: %s\n", CIN, CIN_names[CIN]);
            break;
    }


}

alt_u16 map(alt_u16 x, alt_u16 in_min, alt_u16 in_max, alt_u16 out_min, alt_u16 out_max)
{
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

