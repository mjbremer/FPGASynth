/*
 * MIDI.h
 *
 *  Created on: Apr 12, 2019
 *      Author: Matt
 */


//https://www.usb.org/sites/default/files/midi10.pdf

#ifndef MIDI_H_
#define MIDI_H_

#include <stdio.h>
#include "system.h"
#include "alt_types.h"

#define NOTE_OFF            (0x8)
#define NOTE_ON             (0x9)
#define POLY_KEYPRESS       (0xA)
#define CONTROL_CHANGE      (0xB)
#define PROGRAM_CHANGE      (0xC)
#define CHANNEL_PRESSURE    (0xD)
#define PITCHBEND_CHANGE    (0xE)
#define SINGLE_BYTE         (0xF)

void initControls();
void ProcessMIDIPacket();
alt_u16 map(alt_u16 x, alt_u16 in_min, alt_u16 in_max, alt_u16 out_min, alt_u16 out_max);

#endif /* MIDI_H_ */
