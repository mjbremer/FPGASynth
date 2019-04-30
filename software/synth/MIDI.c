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

    alt_u8 bytes[4];
    for (int i = 0; i < 4; i ++) {
        bytes[i] = ((alt_u8*)&packet)[i];
    }

    alt_u8 CIN = bytes[0];
    alt_u8 note = bytes[2];
    alt_u8 velocity = bytes[3];
    alt_u16 Pitch = ((bytes[2]<<8) | bytes[3]);

    switch(CIN) {
        case NOTE_ON:
        	NoteOnHandler(note, velocity, HEAD);
//        	printf("Note on\n");
            break;
        case NOTE_OFF:
        	NoteOffHandler(note);
//        	printf("Note off\n");
        	break;
        case CONTROL_CHANGE:
        	ControlHandler(note, velocity);
//            for (int i = 0; i < 4; i ++) {
//                printf("%02x", bytes[i]);
//            }
            printf("\n");
        	break;
        case PITCHBEND_CHANGE:
			PitchbendHandler(Pitch);
			            for (int i = 0; i < 4; i ++) {
			                printf("%02x", bytes[i]);
			            }
			            printf("\n");
        	break;
        case PROGRAM_CHANGE:
        	program = bytes[2];

        	break;
        default:
            printf("Got unsupported CIN %02x: %s\n", CIN, CIN_names[CIN]);
            for (int i = 0; i < 4; i ++) {
                 printf("%02x", bytes[i]);
             }
             printf("\n");
            break;
    }
}

