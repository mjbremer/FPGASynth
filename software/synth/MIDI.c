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



void ProcessMIDIPacket(alt_u32 packet)
{
	//alt_u8* const hex = KEYCODE_BASE;
	alt_u8* const freq = FREQ_BASE;
	alt_u16* const amp = AMP_BASE;
	alt_u8* const key_on =  KEY_ON_BASE;
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

    switch(CIN) {
        case NOTE_ON:
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

        default:
            printf("Got unsupported CIN %02x: %s\n", CIN, CIN_names[CIN]);
            break;
    }


}

