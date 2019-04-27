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

static alt_u32* const key_on = SYNTH_CONTROLLER_0_BASE + (32*4);
static alt_u32* const freq = SYNTH_CONTROLLER_0_BASE + (40*4);
static alt_u32* const amp1 = SYNTH_CONTROLLER_0_BASE + (48*4);
static alt_u32* const amp0 = SYNTH_CONTROLLER_0_BASE + (56*4);
#endif

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
		*arp_time = 6000 - (value * 36);
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
