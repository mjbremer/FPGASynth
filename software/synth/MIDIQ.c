#include "MIDIQ.h"

#if DEBUG
static uint32_t shape1[1];
static uint32_t shape0[1];
static uint32_t attack[1];
static uint32_t decay[1];
static uint32_t sustain[1];
static uint32_t release[1];

static uint32_t key_on[NUM_VOICES];
static uint32_t freq[NUM_VOICES];
static uint32_t amp1[NUM_VOICES];
static uint32_t amp0[NUM_VOICES];
#else
static alt_u32* const shape1 = SYNTH_CONTROLLER_0_BASE;
static alt_u32* const shape0 = SYNTH_CONTROLLER_0_BASE + (1*4);
static alt_u32* const attack = SYNTH_CONTROLLER_0_BASE + (2*4);
static alt_u32* const decay = SYNTH_CONTROLLER_0_BASE + (3*4);
static alt_u32* const sustain = SYNTH_CONTROLLER_0_BASE + (4*4);
static alt_u32* const release = SYNTH_CONTROLLER_0_BASE + (5*4);

static alt_u32* const glide_en = SYNTH_CONTROLLER_0_BASE + (6*4);
static alt_u32* const glide_rate = SYNTH_CONTROLLER_0_BASE + (7*4);
static alt_u32* const arp_en = SYNTH_CONTROLLER_0_BASE + (8*4);
static alt_u32* const arp_time = SYNTH_CONTROLLER_0_BASE + (9*4);
static alt_u32* const pingpong = SYNTH_CONTROLLER_0_BASE + (10*4);
static alt_u32* const panning = SYNTH_CONTROLLER_0_BASE + (11*4);
static alt_u32* const auto_pan_en = SYNTH_CONTROLLER_0_BASE + (12*4);

static alt_u32* const filter_en = SYNTH_CONTROLLER_0_BASE + (13*4);
static alt_u32* const filter_a0 = SYNTH_CONTROLLER_0_BASE + (14*4);
static alt_u32* const filter_a1 = SYNTH_CONTROLLER_0_BASE + (15*4);
static alt_u32* const filter_a2 = SYNTH_CONTROLLER_0_BASE + (16*4);
static alt_u32* const filter_b0 = SYNTH_CONTROLLER_0_BASE + (17*4);
static alt_u32* const filter_b1 = SYNTH_CONTROLLER_0_BASE + (18*4);
static alt_u32* const filter_b2 = SYNTH_CONTROLLER_0_BASE + (19*4);

static alt_u32* const delay_en = SYNTH_CONTROLLER_0_BASE + (20*4);
static alt_u32* const delay_feedback = SYNTH_CONTROLLER_0_BASE + (21*4);
static alt_u32* const delay_time = SYNTH_CONTROLLER_0_BASE + (22*4);

static alt_u32* const key_on = SYNTH_CONTROLLER_0_BASE + (32*4);
static alt_u32* const freq = SYNTH_CONTROLLER_0_BASE + (40*4);
static alt_u32* const amp1 = SYNTH_CONTROLLER_0_BASE + (48*4);
static alt_u32* const amp0 = SYNTH_CONTROLLER_0_BASE + (56*4);
#endif

int16_t lpf_table [128][6] = {
{0x2004,0x3fff,0xe005,0x0000,0x0000,0x0000},
{0x2004,0x3fff,0xe005,0x0000,0x0000,0x0000},
{0x2004,0x3fff,0xe005,0x0000,0x0000,0x0000},
{0x2005,0x3fff,0xe006,0x0000,0x0000,0x0000},
{0x2005,0x3fff,0xe006,0x0000,0x0000,0x0000},
{0x2005,0x3fff,0xe006,0x0000,0x0000,0x0000},
{0x2006,0x3fff,0xe007,0x0000,0x0000,0x0000},
{0x2006,0x3fff,0xe007,0x0000,0x0000,0x0000},
{0x2006,0x3fff,0xe007,0x0000,0x0000,0x0000},
{0x2007,0x3fff,0xe008,0x0000,0x0000,0x0000},
{0x2007,0x3fff,0xe008,0x0000,0x0000,0x0000},
{0x2008,0x3fff,0xe009,0x0000,0x0000,0x0000},
{0x2008,0x3fff,0xe009,0x0000,0x0000,0x0000},
{0x2009,0x3fff,0xe00a,0x0000,0x0000,0x0000},
{0x2009,0x3fff,0xe00a,0x0000,0x0000,0x0000},
{0x200a,0x3fff,0xe00b,0x0000,0x0000,0x0000},
{0x200b,0x3fff,0xe00c,0x0000,0x0000,0x0000},
{0x200b,0x3fff,0xe00c,0x0000,0x0000,0x0000},
{0x200c,0x3fff,0xe00d,0x0000,0x0000,0x0000},
{0x200d,0x3fff,0xe00e,0x0000,0x0000,0x0000},
{0x200d,0x3fff,0xe00e,0x0000,0x0000,0x0000},
{0x200e,0x3fff,0xe00f,0x0000,0x0000,0x0000},
{0x200f,0x3fff,0xe010,0x0000,0x0000,0x0000},
{0x2010,0x3fff,0xe011,0x0000,0x0000,0x0000},
{0x2011,0x3fff,0xe012,0x0000,0x0000,0x0000},
{0x2012,0x3fff,0xe013,0x0000,0x0000,0x0000},
{0x2013,0x3fff,0xe014,0x0000,0x0000,0x0000},
{0x2014,0x3fff,0xe015,0x0000,0x0000,0x0000},
{0x2016,0x3fff,0xe017,0x0000,0x0000,0x0000},
{0x2017,0x3fff,0xe018,0x0000,0x0000,0x0000},
{0x2018,0x3fff,0xe019,0x0000,0x0000,0x0000},
{0x201a,0x3fff,0xe01b,0x0000,0x0000,0x0000},
{0x201b,0x3fff,0xe01c,0x0000,0x0000,0x0000},
{0x201d,0x3fff,0xe01e,0x0000,0x0000,0x0000},
{0x201f,0x3fff,0xe020,0x0000,0x0000,0x0000},
{0x2021,0x3fff,0xe022,0x0000,0x0000,0x0000},
{0x2023,0x3fff,0xe024,0x0000,0x0000,0x0000},
{0x2025,0x3fff,0xe026,0x0000,0x0000,0x0000},
{0x2027,0x3fff,0xe028,0x0000,0x0000,0x0000},
{0x2029,0x3fff,0xe02a,0x0000,0x0000,0x0000},
{0x202c,0x3fff,0xe02d,0x0000,0x0000,0x0000},
{0x202e,0x3ffe,0xe02f,0x0000,0x0000,0x0000},
{0x2031,0x3ffe,0xe032,0x0000,0x0000,0x0000},
{0x2034,0x3ffe,0xe035,0x0000,0x0000,0x0000},
{0x2037,0x3ffe,0xe038,0x0000,0x0000,0x0000},
{0x203a,0x3ffe,0xe03b,0x0000,0x0000,0x0000},
{0x203e,0x3ffe,0xe03f,0x0000,0x0000,0x0000},
{0x2042,0x3ffd,0xe043,0x0000,0x0001,0x0000},
{0x2046,0x3ffd,0xe047,0x0000,0x0001,0x0000},
{0x204a,0x3ffd,0xe04b,0x0000,0x0001,0x0000},
{0x204e,0x3ffc,0xe04f,0x0000,0x0001,0x0000},
{0x2053,0x3ffc,0xe054,0x0000,0x0001,0x0000},
{0x2058,0x3ffc,0xe059,0x0000,0x0001,0x0000},
{0x205d,0x3ffb,0xe05e,0x0001,0x0002,0x0001},
{0x2063,0x3ffb,0xe064,0x0001,0x0002,0x0001},
{0x2069,0x3ffa,0xe06a,0x0001,0x0002,0x0001},
{0x206f,0x3ff9,0xe070,0x0001,0x0003,0x0001},
{0x2075,0x3ff9,0xe076,0x0001,0x0003,0x0001},
{0x207c,0x3ff8,0xe07d,0x0001,0x0003,0x0001},
{0x2084,0x3ff7,0xe085,0x0002,0x0004,0x0002},
{0x208c,0x3ff6,0xe08d,0x0002,0x0004,0x0002},
{0x2094,0x3ff5,0xe095,0x0002,0x0005,0x0002},
{0x209d,0x3ff3,0xe09e,0x0003,0x0006,0x0003},
{0x20a6,0x3ff2,0xe0a7,0x0003,0x0006,0x0003},
{0x20b0,0x3ff0,0xe0b1,0x0003,0x0007,0x0003},
{0x20bb,0x3fee,0xe0bc,0x0004,0x0008,0x0004},
{0x20c6,0x3fec,0xe0c7,0x0004,0x0009,0x0004},
{0x20d2,0x3fea,0xe0d3,0x0005,0x000a,0x0005},
{0x20de,0x3fe7,0xe0df,0x0006,0x000c,0x0006},
{0x20eb,0x3fe4,0xe0ec,0x0006,0x000d,0x0006},
{0x20f9,0x3fe1,0xe0fa,0x0007,0x000f,0x0007},
{0x2108,0x3fdd,0xe109,0x0008,0x0011,0x0008},
{0x2118,0x3fd9,0xe119,0x0009,0x0013,0x0009},
{0x2128,0x3fd4,0xe129,0x000a,0x0015,0x000a},
{0x213a,0x3fcf,0xe13b,0x000c,0x0018,0x000c},
{0x214d,0x3fc9,0xe14e,0x000d,0x001b,0x000d},
{0x2161,0x3fc3,0xe162,0x000f,0x001e,0x000f},
{0x2175,0x3fbb,0xe176,0x0011,0x0022,0x0011},
{0x218c,0x3fb3,0xe18d,0x0013,0x0026,0x0013},
{0x21a3,0x3fa9,0xe1a4,0x0015,0x002b,0x0015},
{0x21bc,0x3f9f,0xe1bd,0x0018,0x0030,0x0018},
{0x21d6,0x3f93,0xe1d7,0x001b,0x0036,0x001b},
{0x21f2,0x3f86,0xe1f3,0x001e,0x003c,0x001e},
{0x2210,0x3f77,0xe211,0x0022,0x0044,0x0022},
{0x222f,0x3f66,0xe230,0x0026,0x004c,0x0026},
{0x2250,0x3f53,0xe251,0x002b,0x0056,0x002b},
{0x2273,0x3f3e,0xe274,0x0030,0x0060,0x0030},
{0x2298,0x3f27,0xe299,0x0036,0x006c,0x0036},
{0x22bf,0x3f0c,0xe2c0,0x003c,0x0079,0x003c},
{0x22e8,0x3eee,0xe2e9,0x0044,0x0088,0x0044},
{0x2314,0x3ecd,0xe315,0x004c,0x0099,0x004c},
{0x2342,0x3ea8,0xe343,0x0055,0x00ab,0x0055},
{0x2373,0x3e7e,0xe374,0x0060,0x00c0,0x0060},
{0x23a7,0x3e4f,0xe3a8,0x006c,0x00d8,0x006c},
{0x23dd,0x3e1a,0xe3de,0x0079,0x00f2,0x0079},
{0x2417,0x3ddf,0xe418,0x0088,0x0110,0x0088},
{0x2454,0x3d9c,0xe455,0x0098,0x0131,0x0098},
{0x2494,0x3d52,0xe495,0x00ab,0x0156,0x00ab},
{0x24d7,0x3cff,0xe4d8,0x00c0,0x0180,0x00c0},
{0x251f,0x3ca2,0xe520,0x00d7,0x01ae,0x00d7},
{0x2569,0x3c39,0xe56a,0x00f1,0x01e3,0x00f1},
{0x25b8,0x3bc4,0xe5b9,0x010e,0x021d,0x010e},
{0x260b,0x3b41,0xe60c,0x012f,0x025f,0x012f},
{0x2662,0x3aae,0xe663,0x0154,0x02a8,0x0154},
{0x26bd,0x3a0a,0xe6be,0x017d,0x02fa,0x017d},
{0x271d,0x3953,0xe71e,0x01ab,0x0356,0x01ab},
{0x2781,0x3886,0xe782,0x01de,0x03bc,0x01de},
{0x27e9,0x37a1,0xe7ea,0x0217,0x042f,0x0217},
{0x2855,0x36a1,0xe856,0x0257,0x04af,0x0257},
{0x28c6,0x3583,0xe8c7,0x029f,0x053e,0x029f},
{0x293b,0x3445,0xe93c,0x02ee,0x05dd,0x02ee},
{0x29b4,0x32e2,0xe9b5,0x0347,0x068e,0x0347},
{0x2a30,0x3158,0xea31,0x03a9,0x0753,0x03a9},
{0x2aaf,0x2fa1,0xeab0,0x0417,0x082f,0x0417},
{0x2b31,0x2dba,0xeb32,0x0491,0x0922,0x0491},
{0x2bb5,0x2b9d,0xebb6,0x0518,0x0a31,0x0518},
{0x2c3a,0x2947,0xec3b,0x05ae,0x0b5c,0x05ae},
{0x2cbe,0x26b1,0xecbf,0x0653,0x0ca7,0x0653},
{0x2d41,0x23d8,0xed42,0x0709,0x0e13,0x0709},
{0x2dc0,0x20b5,0xedc1,0x07d2,0x0fa5,0x07d2},
{0x2e3a,0x1d43,0xee3b,0x08af,0x115e,0x08af},
{0x2eac,0x197e,0xeead,0x09a0,0x1340,0x09a0},
{0x2f14,0x1562,0xef15,0x0aa7,0x154e,0x0aa7},
{0x2f6e,0x10eb,0xef6f,0x0bc5,0x178a,0x0bc5},
{0x2fb6,0x0c17,0xefb7,0x0cfa,0x19f4,0x0cfa},
{0x2fe8,0x06e5,0xefe9,0x0e46,0x1c8d,0x0e46},
{0x2fff,0x0157,0xf000,0x0faa,0x1f54,0x0faa},
{0x2ff5,0xfb73,0xeff6,0x1123,0x2246,0x1123}};

static voice_t voices [NUM_VOICES];

static midikey_t keys [NUM_KEYS];

static uint8_t mix;
static synthMode mode;

static voice_t *freeVoicesHead, *freeVoicesTail;
static voice_t *activeVoicesHead, *activeVoicesTail;
static midikey_t *waitingHead, *waitingTail;

void initControls()
{

	// Want attack and release to be 5 ms minimum (according to Haken)
	// So we take 5 ms * 48 samples/ms to get 240 samples.
	// Then we just do 0x7FFF / 0d240 to get a rate of 0x88.
	*shape1 = 0;
	*shape0 = 0;
	*attack = 0x88;
	*decay  = 0x7FFF;
	*sustain = 0x7FFF;
	*release = 0x88;
	*glide_en = 0;
	*glide_rate = 0x01;	// Slowest
	*arp_en = 0;
	*arp_time = 3600; // ~ 100 bpm
	*panning = 0x4000;
	*auto_pan_en = 0;
	*pingpong = 0;
	*filter_en = 0;
	*filter_a0 = lpf_table[49][0];
	*filter_a1 = lpf_table[49][1];
	*filter_a2 = lpf_table[49][2];
	*filter_b0 = lpf_table[49][3];
	*filter_b1 = lpf_table[49][4];
	*filter_b2 = lpf_table[49][5];
	*delay_en = 1;
	*delay_feedback = 0x7fff;
	*delay_time = 960;
	// Arp time range 1500 to 6000

    mode = SYNTH_MODE_POLY;
	mix = 0x40;

	for (int i = 0; i < NUM_VOICES; i++) {
		key_on[i] = 0x00;
		freq[i] = 0;
		amp1[i] = 0;
		amp0[i] = 0;
	}

}

void ControlHandler(uint8_t control, uint8_t value)
{

	switch (control) {

	case 0x14:
		if (value == 0) {

			if (mode == SYNTH_MODE_GLIDE) {
				printf("Turn glide off first");
			} else {
			mode = SYNTH_MODE_POLY;
			initStructures(NUM_VOICES);
			}
		}
		else {
			mode = SYNTH_MODE_MONO;
			initStructures(1);
		}
		break;
	case 0x15:
		if (value == 0) {
			if (mode == SYNTH_MODE_GLIDE) {
			mode = SYNTH_MODE_MONO;
			initStructures(1);
			}
		}
		else {

			if (mode == SYNTH_MODE_MONO) {
				mode = SYNTH_MODE_GLIDE;
				*glide_en = 1;
			}
			else {
				printf("Switch to Mono voicing first");
			}

		}
		break;
	case 0x16:
		break;
	case 0x17:
			if (value == 0) {
				*auto_pan_en = 0;
			}
			else
				*auto_pan_en = 1;
		break;

	case 0x18:
		if (value == 0)
			*shape1 = *shape1 & ~0x01; // Clear the first bit
		else
			*shape1 = *shape1 | 0x01; // Set the first bit

		break;
	case 0x19:
		if (value == 0)
			*shape1 = *shape1 & ~0x02; // Clear the second bit
		else
			*shape1 = *shape1 | 0x02; // Set the second bit

		break;
	case 0x1a:
		if (value == 0)
		    *shape0 = *shape0 & ~0x01; // Clear the third bit
		else
		    *shape0 = *shape0 | 0x01; // Set the third bit

		break;
	case 0x1b:
		if (value == 0)
		    *shape0 = *shape0 & ~0x02; // Clear the fourth bit
		else
		    *shape0 = *shape0 | 0x02; // Set the fourth bit

		break;
	case 0x20:
		if (value == 0)
			*arp_en = 0x00;
		else
			*arp_en = 0x01;
		break;
	case 0x21:
		if (value == 0)
			*pingpong = 0x00;
		else
			*pingpong = 0x01;
		break;
	case 0x01: //attack
		*attack = value + 1;
		break;
	case 0x02: // decay
		*decay = value + 1;
		break;
	case 0x03: // sustain
		*sustain = (value << 8) + 0xff;
		break;
	case 0x04: // release
		*release = value + 1;
		break;
	case 0x05:
		mix = value;
		break;
	case 0x06:
		*glide_rate = value;
		break;
	case 0x07:
		*arp_time = 48000;
		break;
	default:
		break;
	}
}



void InitVoice(voice_t * v, uint8_t note, uint8_t vel)
{
    *v->freq = note;
    *v->amp1 = (vel) * (0x7f - mix);
    *v->amp0 = (vel) * mix;
    *v->key_on = 0x01;
    v->status = VOICE_ACTIVE;
    v->key_num = note;
}

void MuteVoice(voice_t * v)
{
    *v->key_on = 0x00;
    v->status = VOICE_INACTIVE;
}


void NoteOnHandler(uint8_t note, uint8_t vel, PopVoiceLocation priority)
{
    midikey_t * m = &(keys[note]);
    midikey_t * toWait;

    // Make sure the note isn't already playing
    if (m->osc != NULL) {
    	return;
    }

	voice_t * new = PopVoice(&freeVoicesHead, &freeVoicesTail,HEAD);
    if (new == NULL) {
        new = PopVoice(&activeVoicesHead, &activeVoicesTail,TAIL);
        toWait = &keys[new->key_num];
        toWait->status = KEY_WAITING;
        toWait->osc = NULL;
        PushWaiting(&waitingHead, &waitingTail, HEAD, toWait);
        
        // Since glide module can't distinguish between a "real" note off and an instant switch
        if (mode != SYNTH_MODE_GLIDE) {
            MuteVoice(new);
        }
    }
    
    InitVoice(new, note, vel);

    PushVoice(&activeVoicesHead, &activeVoicesTail, priority, new);
    m->status = KEY_PLAYING;
    m->osc = new;
    m->velocity = vel;
}

void NoteOffHandler(uint8_t note)
{
    midikey_t * m = &(keys[note]);
    voice_t * v = m->osc;


    if (m->status == KEY_WAITING) {
        removeWaiting(&waitingHead, &waitingTail, m);
        return;
    }

    midikey_t * waiting = PopWaiting(&waitingHead, &waitingTail, HEAD);

    m->status = KEY_INACTIVE;
    m->osc = NULL;

    // Just in case NULL check
    if (v != NULL) {

        // Since glide module can't distinguish between a "real" note off and an instant switch
        if (waiting == NULL || mode != SYNTH_MODE_GLIDE) {
            MuteVoice(v);
        }

        removeVoice(&activeVoicesHead, &activeVoicesTail, v);

        PushVoice(&freeVoicesHead, &freeVoicesTail,TAIL, v);

        if (waiting != NULL) {
            NoteOnHandler(waiting->key_num, waiting->velocity, TAIL);
        }
    }
}


void removeVoice(voice_t ** head, voice_t ** tail, voice_t * v)  
{  
    /* base case */
    if (*head == NULL || *tail == NULL ||  v == NULL)  
        return;  
  
    /* If node to be deleted is head node */
    if (*head == v)  
        *head = v->next;

    if (*tail == v)
        *tail = v->prev;  
  
    /* Change next only if node to be  
    deleted is NOT the last node */
    if (v->next != NULL)  
        v->next->prev = v->prev;  
    /* Change prev only if node to be  
    deleted is NOT the first node */
    if (v->prev != NULL)  
        v->prev->next = v->next;  
  
}

// Pop a voice from one of the doubly linked lists and return its pointer
void PushVoice(voice_t ** head, voice_t ** tail, PopVoiceLocation from, voice_t * v)
{
    voice_t *temp;
    if (from == HEAD) {
        // If our list is empty, update head and tail
        if (*head == NULL) {
            v->next = NULL;
            v->prev = NULL;
            *head = v;
            *tail = v;
        } else { // If there are multiple available voices, take the one at head
            temp = *head;
            v->next = temp;
            v->prev = NULL;
            temp->prev = v;
            *head = v;
        }

    } else {
        // If our list is empty, update head and tail
        if (*tail == NULL) {
            v->next = NULL;
            v->prev = NULL;
            *head = v;
            *tail = v;
        } else { // If there are multiple available voices, take the one at tail
            temp = *tail;
            v->prev = temp;
            v->next = NULL;
            temp->next = v;
            *tail = v;
        }
    }
}

// Pop a voice from one of the doubly linked lists and return its pointer
voice_t * PopVoice(voice_t ** head, voice_t ** tail, PopVoiceLocation from)
{
    voice_t * ret, *temp;
    if (from == HEAD) {
        // If our list is empty, do nothing (later, use voice stealing)
        if (*head == NULL) {
            return NULL;
        } else if (*head == *tail) { // If we only have one voice, set head & tail to null
            ret = *head;
            *head = NULL;
            *tail = NULL;
        } else { // If there are multiple available voices, take the one at head
            ret = *head;
            temp = ret->next;
            temp->prev = NULL;
            *head = temp;
        }

    } else {
        // If our list is empty, do nothing (later, use voice stealing)
        if (*tail == NULL) {
            return NULL;
        } else if (*head == *tail) { // If we only have one voice, set head & tail to null
            ret = *tail;
            *head = NULL;
            *tail = NULL;
        } else { // If there are multiple available voices, take the one at head
            ret = *tail;
            temp = ret->prev;
            temp->next = NULL;
            *tail = temp;
        }
    }
    return ret;
}

void removeWaiting(midikey_t ** head, midikey_t ** tail, midikey_t * v)  
{  
    /* base case */
    if (*head == NULL || *tail == NULL ||  v == NULL)  
        return;  
  
    /* If node to be deleted is head node */
    if (*head == v)  
        *head = v->next;

    if (*tail == v)
        *tail = v->prev;  
  
    /* Change next only if node to be  
    deleted is NOT the last node */
    if (v->next != NULL)  
        v->next->prev = v->prev;  
    /* Change prev only if node to be  
    deleted is NOT the first node */
    if (v->prev != NULL)  
        v->prev->next = v->next;  
  
}

// Pop a voice from one of the doubly linked lists and return its pointer
void PushWaiting(midikey_t ** head, midikey_t ** tail, PopVoiceLocation from, midikey_t * v)
{
    midikey_t *temp;
    if (from == HEAD) {
        // If our list is empty, update head and tail
        if (*head == NULL) {
            v->next = NULL;
            v->prev = NULL;
            *head = v;
            *tail = v;
        } else { // If there are multiple available voices, take the one at head
            temp = *head;
            v->next = temp;
            v->prev = NULL;
            temp->prev = v;
            *head = v;
        }

    } else {
        // If our list is empty, update head and tail
        if (*tail == NULL) {
            v->next = NULL;
            v->prev = NULL;
            *head = v;
            *tail = v;
        } else { // If there are multiple available voices, take the one at tail
            temp = *tail;
            v->prev = temp;
            v->next = NULL;
            temp->next = v;
            *tail = v;
        }
    }
}

// Pop a voice from one of the doubly linked lists and return its pointer
midikey_t * PopWaiting(midikey_t ** head, midikey_t ** tail, PopVoiceLocation from)
{
    midikey_t * ret, *temp;
    if (from == HEAD) {
        // If our list is empty, do nothing (later, use voice stealing)
        if (*head == NULL) {
            return NULL;
        } else if (*head == *tail) { // If we only have one voice, set head & tail to null
            ret = *head;
            *head = NULL;
            *tail = NULL;
        } else { // If there are multiple available voices, take the one at head
            ret = *head;
            temp = ret->next;
            temp->prev = NULL;
            *head = temp;
        }

    } else {
        // If our list is empty, do nothing (later, use voice stealing)
        if (*tail == NULL) {
            return NULL;
        } else if (*head == *tail) { // If we only have one voice, set head & tail to null
            ret = *tail;
            *head = NULL;
            *tail = NULL;
        } else { // If there are multiple available voices, take the one at head
            ret = *tail;
            temp = ret->prev;
            temp->next = NULL;
            *tail = temp;
        }
    }
    return ret;
}

void initStructures(uint8_t voicesInUse)
{
    int i;
    voice_t* v;
    midikey_t* m;
    freeVoicesHead = NULL;
    freeVoicesTail = NULL;
    activeVoicesHead = NULL;
    activeVoicesTail = NULL;
    waitingHead = NULL;
    waitingTail = NULL;

    for (i = 0; i < voicesInUse; i++) {
        v = &(voices[i]);
        v->status = VOICE_INACTIVE;
        v->freq = &(freq[i]);
        v->amp1 = &(amp1[i]);
        v->amp0 = &(amp0[i]);
        v->key_on = &(key_on[i]);
        v->key_num = VOICE_NOKEY;
        PushVoice(&freeVoicesHead, &freeVoicesTail,TAIL, v);
        printf("%d, %d\n",CountVoices(freeVoicesHead),CountVoices(activeVoicesHead) );
    }

    for (i = 0; i < NUM_KEYS; i++) {
        m = &(keys[i]);
        m->key_num = i;
        m->status = KEY_INACTIVE;
        m->osc = NULL;
        m->prev = NULL;
        m->next = NULL;
        m->velocity = 0;
    }
}



int CountVoices(voice_t * head)
{
    int count = 0;
    for (voice_t * v = head; v != NULL; v = v->next) {
        count++;
    }
    return count;
}

void PrintVoiceInfo(voice_t * head)
{
    for (voice_t * v = head; v != NULL; v = v->next) {
        printf("Active 0x%x\n", v->key_num);
    }
}


void PrintWaitingInfo(midikey_t * head)
{
    for (midikey_t * v = head; v != NULL; v = v->next) {
        printf("Waiting 0x%x\n", v->key_num);
    }
}


int CountWaiting()
{
    int count = 0;
    for (midikey_t * v  = waitingHead; v != NULL; v = v->next) {
        count++;
    }
    return count;
}

void PitchbendHandler(uint16_t Pitch)
{
	*panning = Pitch;
}

#if DEBUG
int main()
{

    initControls();
	initStructures(1);

    NoteOnHandler(0x0a, 0xFF, HEAD);

    printf("%d Free, %d Active, %d Waiting\n",CountVoices(freeVoicesHead),CountVoices(activeVoicesHead), CountWaiting());
    PrintVoiceInfo(activeVoicesHead);
    PrintWaitingInfo(waitingHead);

	initStructures(4);


    printf("%d Free, %d Active, %d Waiting\n",CountVoices(freeVoicesHead),CountVoices(activeVoicesHead), CountWaiting());
    PrintVoiceInfo(activeVoicesHead);
    PrintWaitingInfo(waitingHead);


    NoteOnHandler(0x0b, 0xFF, HEAD);

    printf("%d Free, %d Active, %d Waiting\n",CountVoices(freeVoicesHead),CountVoices(activeVoicesHead), CountWaiting());
    PrintVoiceInfo(activeVoicesHead);
    PrintWaitingInfo(waitingHead);

    NoteOnHandler(0x0c, 0xFF, HEAD);

    printf("%d Free, %d Active, %d Waiting\n",CountVoices(freeVoicesHead),CountVoices(activeVoicesHead), CountWaiting());
    PrintVoiceInfo(activeVoicesHead);
    PrintWaitingInfo(waitingHead);

    NoteOnHandler(0x0d, 0xFF, HEAD);

    printf("%d Free, %d Active, %d Waiting\n",CountVoices(freeVoicesHead),CountVoices(activeVoicesHead), CountWaiting());
    PrintVoiceInfo(activeVoicesHead);
    PrintWaitingInfo(waitingHead);

    NoteOnHandler(0x0e, 0xFF, HEAD);

    printf("%d Free, %d Active, %d Waiting\n",CountVoices(freeVoicesHead),CountVoices(activeVoicesHead), CountWaiting());
    PrintVoiceInfo(activeVoicesHead);
    PrintWaitingInfo(waitingHead);


    NoteOffHandler(0x0c);

    printf("%d Free, %d Active, %d Waiting\n",CountVoices(freeVoicesHead),CountVoices(activeVoicesHead), CountWaiting());
    PrintVoiceInfo(activeVoicesHead);
    PrintWaitingInfo(waitingHead);

    NoteOnHandler(0x40, 0xFF, HEAD);

    printf("%d Free, %d Active, %d Waiting\n",CountVoices(freeVoicesHead),CountVoices(activeVoicesHead), CountWaiting());
    PrintVoiceInfo(activeVoicesHead);
    PrintWaitingInfo(waitingHead);
    return 0;
}
#endif
