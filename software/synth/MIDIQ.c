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

static alt_u32* const filter_a0 = SYNTH_CONTROLLER_0_BASE + (13*4);
static alt_u32* const filter_a1 = SYNTH_CONTROLLER_0_BASE + (14*4);
static alt_u32* const filter_a2 = SYNTH_CONTROLLER_0_BASE + (15*4);
static alt_u32* const filter_b0 = SYNTH_CONTROLLER_0_BASE + (16*4);
static alt_u32* const filter_b1 = SYNTH_CONTROLLER_0_BASE + (17*4);
static alt_u32* const filter_b2 = SYNTH_CONTROLLER_0_BASE + (18*4);


static alt_u32* const key_on = SYNTH_CONTROLLER_0_BASE + (32*4);
static alt_u32* const freq = SYNTH_CONTROLLER_0_BASE + (40*4);
static alt_u32* const amp1 = SYNTH_CONTROLLER_0_BASE + (48*4);
static alt_u32* const amp0 = SYNTH_CONTROLLER_0_BASE + (56*4);
#endif

int16_t lpf_table [128][6] = {
{0x1002,0xe001,0x0ffd,0x0000,0x0000,0x0000},
{0x1002,0xe001,0x0ffd,0x0000,0x0000,0x0000},
{0x1002,0xe001,0x0ffd,0x0000,0x0000,0x0000},
{0x1002,0xe001,0x0ffd,0x0000,0x0000,0x0000},
{0x1002,0xe001,0x0ffd,0x0000,0x0000,0x0000},
{0x1002,0xe001,0x0ffd,0x0000,0x0000,0x0000},
{0x1003,0xe001,0x0ffc,0x0000,0x0000,0x0000},
{0x1003,0xe001,0x0ffc,0x0000,0x0000,0x0000},
{0x1003,0xe001,0x0ffc,0x0000,0x0000,0x0000},
{0x1003,0xe001,0x0ffc,0x0000,0x0000,0x0000},
{0x1003,0xe001,0x0ffc,0x0000,0x0000,0x0000},
{0x1004,0xe001,0x0ffb,0x0000,0x0000,0x0000},
{0x1004,0xe001,0x0ffb,0x0000,0x0000,0x0000},
{0x1004,0xe001,0x0ffb,0x0000,0x0000,0x0000},
{0x1004,0xe001,0x0ffb,0x0000,0x0000,0x0000},
{0x1005,0xe001,0x0ffa,0x0000,0x0000,0x0000},
{0x1005,0xe001,0x0ffa,0x0000,0x0000,0x0000},
{0x1005,0xe001,0x0ffa,0x0000,0x0000,0x0000},
{0x1006,0xe001,0x0ff9,0x0000,0x0000,0x0000},
{0x1006,0xe001,0x0ff9,0x0000,0x0000,0x0000},
{0x1006,0xe001,0x0ff9,0x0000,0x0000,0x0000},
{0x1007,0xe001,0x0ff8,0x0000,0x0000,0x0000},
{0x1007,0xe001,0x0ff8,0x0000,0x0000,0x0000},
{0x1008,0xe001,0x0ff7,0x0000,0x0000,0x0000},
{0x1008,0xe001,0x0ff7,0x0000,0x0000,0x0000},
{0x1009,0xe001,0x0ff6,0x0000,0x0000,0x0000},
{0x1009,0xe001,0x0ff6,0x0000,0x0000,0x0000},
{0x100a,0xe001,0x0ff5,0x0000,0x0000,0x0000},
{0x100b,0xe001,0x0ff4,0x0000,0x0000,0x0000},
{0x100b,0xe001,0x0ff4,0x0000,0x0000,0x0000},
{0x100c,0xe001,0x0ff3,0x0000,0x0000,0x0000},
{0x100d,0xe001,0x0ff2,0x0000,0x0000,0x0000},
{0x100d,0xe001,0x0ff2,0x0000,0x0000,0x0000},
{0x100e,0xe001,0x0ff1,0x0000,0x0000,0x0000},
{0x100f,0xe001,0x0ff0,0x0000,0x0000,0x0000},
{0x1010,0xe001,0x0fef,0x0000,0x0000,0x0000},
{0x1011,0xe001,0x0fee,0x0000,0x0000,0x0000},
{0x1012,0xe001,0x0fed,0x0000,0x0000,0x0000},
{0x1013,0xe001,0x0fec,0x0000,0x0000,0x0000},
{0x1014,0xe001,0x0feb,0x0000,0x0000,0x0000},
{0x1016,0xe001,0x0fe9,0x0000,0x0000,0x0000},
{0x1017,0xe001,0x0fe8,0x0000,0x0000,0x0000},
{0x1018,0xe001,0x0fe7,0x0000,0x0000,0x0000},
{0x101a,0xe001,0x0fe5,0x0000,0x0000,0x0000},
{0x101b,0xe001,0x0fe4,0x0000,0x0000,0x0000},
{0x101d,0xe001,0x0fe2,0x0000,0x0000,0x0000},
{0x101f,0xe001,0x0fe0,0x0000,0x0000,0x0000},
{0x1021,0xe002,0x0fde,0x0000,0x0000,0x0000},
{0x1023,0xe002,0x0fdc,0x0000,0x0000,0x0000},
{0x1025,0xe002,0x0fda,0x0000,0x0000,0x0000},
{0x1027,0xe002,0x0fd8,0x0000,0x0000,0x0000},
{0x1029,0xe002,0x0fd6,0x0000,0x0000,0x0000},
{0x102c,0xe002,0x0fd3,0x0000,0x0000,0x0000},
{0x102e,0xe003,0x0fd1,0x0000,0x0001,0x0000},
{0x1031,0xe003,0x0fce,0x0000,0x0001,0x0000},
{0x1034,0xe003,0x0fcb,0x0000,0x0001,0x0000},
{0x1037,0xe004,0x0fc8,0x0000,0x0001,0x0000},
{0x103a,0xe004,0x0fc5,0x0000,0x0001,0x0000},
{0x103e,0xe004,0x0fc1,0x0000,0x0001,0x0000},
{0x1042,0xe005,0x0fbd,0x0001,0x0002,0x0001},
{0x1046,0xe005,0x0fb9,0x0001,0x0002,0x0001},
{0x104a,0xe006,0x0fb5,0x0001,0x0002,0x0001},
{0x104e,0xe007,0x0fb1,0x0001,0x0003,0x0001},
{0x1053,0xe007,0x0fac,0x0001,0x0003,0x0001},
{0x1058,0xe008,0x0fa7,0x0001,0x0003,0x0001},
{0x105d,0xe009,0x0fa2,0x0002,0x0004,0x0002},
{0x1063,0xe00a,0x0f9c,0x0002,0x0004,0x0002},
{0x1069,0xe00b,0x0f96,0x0002,0x0005,0x0002},
{0x106f,0xe00d,0x0f90,0x0003,0x0006,0x0003},
{0x1075,0xe00e,0x0f8a,0x0003,0x0006,0x0003},
{0x107c,0xe010,0x0f83,0x0003,0x0007,0x0003},
{0x1084,0xe012,0x0f7b,0x0004,0x0008,0x0004},
{0x108c,0xe014,0x0f73,0x0004,0x0009,0x0004},
{0x1094,0xe016,0x0f6b,0x0005,0x000a,0x0005},
{0x109d,0xe019,0x0f62,0x0006,0x000c,0x0006},
{0x10a6,0xe01c,0x0f59,0x0006,0x000d,0x0006},
{0x10b0,0xe01f,0x0f4f,0x0007,0x000f,0x0007},
{0x10ba,0xe023,0x0f45,0x0008,0x0011,0x0008},
{0x10c6,0xe027,0x0f39,0x0009,0x0013,0x0009},
{0x10d1,0xe02c,0x0f2e,0x000a,0x0015,0x000a},
{0x10de,0xe031,0x0f21,0x000c,0x0018,0x000c},
{0x10eb,0xe037,0x0f14,0x000d,0x001b,0x000d},
{0x10f9,0xe03d,0x0f06,0x000f,0x001e,0x000f},
{0x1108,0xe045,0x0ef7,0x0011,0x0022,0x0011},
{0x1117,0xe04d,0x0ee8,0x0013,0x0026,0x0013},
{0x1128,0xe057,0x0ed7,0x0015,0x002b,0x0015},
{0x1139,0xe061,0x0ec6,0x0018,0x0030,0x0018},
{0x114c,0xe06d,0x0eb3,0x001b,0x0036,0x001b},
{0x115f,0xe07a,0x0ea0,0x001e,0x003c,0x001e},
{0x1174,0xe089,0x0e8b,0x0022,0x0044,0x0022},
{0x118a,0xe09a,0x0e75,0x0026,0x004c,0x0026},
{0x11a1,0xe0ac,0x0e5e,0x002a,0x0055,0x002a},
{0x11b9,0xe0c1,0x0e46,0x0030,0x0060,0x0030},
{0x11d3,0xe0d9,0x0e2c,0x0036,0x006c,0x0036},
{0x11ee,0xe0f3,0x0e11,0x003c,0x0079,0x003c},
{0x120b,0xe111,0x0df4,0x0044,0x0088,0x0044},
{0x122a,0xe132,0x0dd5,0x004c,0x0098,0x004c},
{0x124a,0xe157,0x0db5,0x0055,0x00ab,0x0055},
{0x126b,0xe181,0x0d94,0x0060,0x00c0,0x0060},
{0x128f,0xe1af,0x0d70,0x006b,0x00d7,0x006b},
{0x12b4,0xe1e4,0x0d4b,0x0078,0x00f1,0x0078},
{0x12dc,0xe21e,0x0d23,0x0087,0x010e,0x0087},
{0x1305,0xe260,0x0cfa,0x0097,0x012f,0x0097},
{0x1331,0xe2a9,0x0cce,0x00aa,0x0154,0x00aa},
{0x135e,0xe2fb,0x0ca1,0x00be,0x017d,0x00be},
{0x138e,0xe357,0x0c71,0x00d5,0x01ab,0x00d5},
{0x13c0,0xe3bd,0x0c3f,0x00ef,0x01de,0x00ef},
{0x13f4,0xe430,0x0c0b,0x010b,0x0217,0x010b},
{0x142a,0xe4b0,0x0bd5,0x012b,0x0257,0x012b},
{0x1463,0xe53f,0x0b9c,0x014f,0x029f,0x014f},
{0x149d,0xe5de,0x0b62,0x0177,0x02ee,0x0177},
{0x14da,0xe68f,0x0b25,0x01a3,0x0347,0x01a3},
{0x1518,0xe754,0x0ae7,0x01d4,0x03a9,0x01d4},
{0x1557,0xe830,0x0aa8,0x020b,0x0417,0x020b},
{0x1598,0xe923,0x0a67,0x0248,0x0491,0x0248},
{0x15da,0xea32,0x0a25,0x028c,0x0518,0x028c},
{0x161d,0xeb5d,0x09e2,0x02d7,0x05ae,0x02d7},
{0x165f,0xeca8,0x09a0,0x0329,0x0653,0x0329},
{0x16a0,0xee14,0x095f,0x0384,0x0709,0x0384},
{0x16e0,0xefa6,0x091f,0x03e9,0x07d2,0x03e9},
{0x171d,0xf15f,0x08e2,0x0457,0x08af,0x0457},
{0x1756,0xf341,0x08a9,0x04d0,0x09a0,0x04d0},
{0x178a,0xf54f,0x0875,0x0553,0x0aa7,0x0553},
{0x17b7,0xf78b,0x0848,0x05e2,0x0bc5,0x05e2},
{0x17db,0xf9f5,0x0824,0x067d,0x0cfa,0x067d},
{0x17f4,0xfc8e,0x080b,0x0723,0x0e46,0x0723},
{0x17ff,0xff55,0x0800,0x07d5,0x0faa,0x07d5},
{0x17fa,0x0246,0x0805,0x0891,0x1123,0x0891}};
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
	*filter_a0 = lpf_table[69][0];
	*filter_a1 = lpf_table[69][1];
	*filter_a2 = lpf_table[69][2];
	*filter_b0 = lpf_table[69][3];
	*filter_b1 = lpf_table[69][4];
	*filter_b2 = lpf_table[69][5];
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
