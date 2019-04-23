#include "MIDIQ.h"

static alt_u32* const shape1 = SYNTH_CONTROLLER_0_BASE;
static alt_u32* const shape0 = SYNTH_CONTROLLER_0_BASE + (1*4);
static alt_u32* const attack = SYNTH_CONTROLLER_0_BASE + (2*4);
static alt_u32* const decay = SYNTH_CONTROLLER_0_BASE + (3*4);
static alt_u32* const sustain = SYNTH_CONTROLLER_0_BASE + (4*4);
static alt_u32* const release = SYNTH_CONTROLLER_0_BASE + (5*4);

static alt_u32* const key_on = SYNTH_CONTROLLER_0_BASE + (32*4);
static alt_u32* const freq = SYNTH_CONTROLLER_0_BASE + (40*4);
static alt_u32* const amp1 = SYNTH_CONTROLLER_0_BASE + (48*4);
static alt_u32* const amp0 = SYNTH_CONTROLLER_0_BASE + (56*4);

static voice_t voices [NUM_VOICES];

static midikey_t keys [NUM_KEYS];

static voice_t *freeVoicesHead, *freeVoicesTail;
//static voice_t *activeVoicesHead, *activeVoicesTail;

void initControls()
{
	*shape1 = 0;
	*shape0 = 0;
	*attack = 0x7FFF;
	*decay  = 0x7FFF;
	*sustain = 0x7FFF;
	*release = 0x7FFF;

	for (int i = 0; i < NUM_VOICES; i++) {
		key_on[i] = 0x00;
		freq[i] = 0;
		amp1[i] = 0;
		amp0[i] = 0;
	}

}

void ControlHandler(uint8_t control, uint8_t value)
{
	// TODO: CBT me.
}


void InitVoice(voice_t * v, uint8_t note, uint8_t vel)
{
    *v->freq = note;
    *v->vel = vel << 6;
    *v->key_on = 0x01;
    v->status = VOICE_ACTIVE;
}

void MuteVoice(voice_t * v)
{
    *v->key_on = 0x00;
    v->status = VOICE_INACTIVE;
}


void NoteOnHandler(uint8_t note, uint8_t vel)
{
    voice_t * new = PopVoice(&freeVoicesHead, &freeVoicesTail,HEAD);
    if (new == NULL)
        return; // for now...
    
    InitVoice(new, note, vel);

    midikey_t * m = &(keys[note]);

    m->status = KEY_PLAYING;
    m->osc = new;
}

void NoteOffHandler(uint8_t note)
{
    midikey_t * m = &(keys[note]);
    voice_t * v = m->osc;

    m->status = KEY_INACTIVE;
    m->osc = NULL;

    // Just in case NULL check
    if (v != NULL) {
        MuteVoice(v);
        PushVoice(&freeVoicesHead, &freeVoicesTail,TAIL, v);
    }

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

void initStructures()
{
    int i;
    voice_t* v;
    midikey_t* m;
    freeVoicesHead = NULL;
    freeVoicesTail = NULL;

    for (i = 0; i < NUM_VOICES; i++) {
        v = &(voices[i]);
        v->status = VOICE_INACTIVE;
        v->freq = &(freq[i]);
        v->vel = &(amp1[i]);
        v->key_on = &(key_on[i]);
        PushVoice(&freeVoicesHead, &freeVoicesTail,TAIL, v);
        printf("%d\n",CountActiveVoices());
    }

    for (i = 0; i < NUM_KEYS; i++) {
        m = &(keys[i]);
        m->key_num = i;
        m->status = KEY_INACTIVE;
    }
}


int CountActiveVoices()
{
    int count = 0;
    for (voice_t * v = freeVoicesHead; v != NULL; v = v->next) {
        count++;
    }
    return count;
}
