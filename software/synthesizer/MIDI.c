/*
 * MIDI.c
 *
 *  Created on: Apr 12, 2019
 *      Author: Matt
 */

#include "MIDI.h"

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
	alt_u8* const freq = FREQ_BASE;
	alt_u16* const amp = AMP_BASE;
	alt_u8* const key_on =  KEY_ON_BASE;
	alt_u8* const shape = SHAPESEL_BASE;
	alt_u8* const attack = ATTACK_BASE;
	alt_u8* const decay = DECAY_BASE;
	alt_u8* const sustain = SUSTAIN_BASE;
	alt_u8* const release = RELEASE0_BASE;


	*freq = 0;
	*amp = 0;
	*key_on = 0;
	*shape = 0;
	*attack = 0x7F;
	*decay = 0x7F;
	*sustain = 0x7F;
	*release = 0x7F;
}

void ProcessMIDIPacket(alt_u32 packet)
{
	//alt_u8* const hex = KEYCODE_BASE;
	alt_u8* const freq = FREQ_BASE;
	alt_u16* const amp = AMP_BASE;
	alt_u8* const key_on =  KEY_ON_BASE;
	alt_u8* const shape = SHAPESEL_BASE;
	alt_u8* const attack = ATTACK_BASE;
	alt_u8* const decay = DECAY_BASE;
	alt_u8* const sustain = SUSTAIN_BASE;
	alt_u8* const release = RELEASE0_BASE;
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
    alt_u8 control = bytes[2];

    switch(CIN) {
        case NOTE_ON:
        	*key_on = 0x00;
    		*freq = (alt_u8)note;
    		//*hex = note;
    		*amp = (alt_u16)velocity << 8;
    		*key_on = 0x01;
            break;
        case NOTE_OFF:
        	if (*freq == note) {
        		//*hex = 0;
        		*key_on = 0x00;
        	}
        	break;
        case CONTROL_CHANGE:
        	if (control == 0x18) {
        		if (velocity == 0)
        			*shape = *shape & 0x01; // Clear all but the first bit
        		else
        			*shape = *shape | 0x02; // Set the second bit
        	} else if (control == 0x19) {
        		if (velocity == 0)
        			*shape = *shape & 0x02; // Clear all but the second bit
        		else
        			*shape = *shape | 0x01; // Set the first bit
        	} else if (control == 0x01){
        		*attack = velocity;
        	} else if (control == 0x02){
        		*decay = velocity;
        	} else if (control == 0x03){
        		*sustain = velocity;
        	} else if (control == 0x04){
        		*release = velocity;
        	}




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

