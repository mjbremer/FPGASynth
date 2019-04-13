/*---------------------------------------------------------------------------
  --      main.c                                                    	   --
  --      Christine Chen                                                   --
  --      Ref. DE2-115 Demonstrations by Terasic Technologies Inc.         --
  --      Fall 2014                                                        --
  --                                                                       --
  --      For use with ECE 298 Experiment 7                                --
  --      UIUC ECE Department                                              --
  ---------------------------------------------------------------------------*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <io.h>
#include <fcntl.h>

#include "system.h"
#include "alt_types.h"
#include <unistd.h>  // usleep 
#include "sys/alt_irq.h"
#include "io_handler.h"

#include "cy7c67200.h"
#include "usb.h"
#include "lcp_cmd.h"
#include "lcp_data.h"
#include "MIDI.h"


//----------------------------------------------------------------------------------------//
//
//                                Main function
//
//----------------------------------------------------------------------------------------//
int main(void)
{

	alt_u8 toggle = 0;
	alt_u32 last_midi_msg = 0, new_midi_msg = 0;

	UsbSetupMIDI();

	//-----------------------------------get keycode value------------------------------------------------//
	usleep(10000);
	while(1)
	{
		toggle++;
		do {
			UsbGetMIDIMsg(toggle);
		} while (!(IO_read(HPI_STATUS) & HPI_STATUS_SIE1msg_FLAG)); //read sie1 msg register

		UsbWaitTDListDone();

		new_midi_msg = (UsbRead(0x51e) << 16) | UsbRead(0x51c);

		if (new_midi_msg != last_midi_msg) {
//			printf("%08x\n", new_midi_msg);
			last_midi_msg = new_midi_msg;
			ProcessMIDIPacket(new_midi_msg);
		}


		UsbCheckUnplug();
		usleep(1000);
	}
	return 0;
}

