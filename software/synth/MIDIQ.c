#include "MIDIQ.h"


static voice_t voices [NUM_VOICES];

static midikey_t keys [NUM_KEYS];

static voice_t *freeVoicesHead, *freeVoicesTail;
//static voice_t *activeVoicesHead, *activeVoicesTail;

static uint8_t freq[NUM_VOICES];
static uint8_t key_on;
static uint8_t vel[NUM_VOICES];


void InitVoice(voice_t * v, uint8_t note, uint8_t vel)
{
    *v->freq = note;
    *v->vel = vel;
    key_on = key_on | (0x01 << v->key_on);
    v->status = VOICE_ACTIVE;
}

void MuteVoice(voice_t * v)
{
    key_on = key_on & ~(0x01 << v->key_on);
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

void InitStructures()
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
        v->vel = &(vel[i]);
        v->key_on = i;
        PushVoice(&freeVoicesHead, &freeVoicesTail,TAIL, v);
        printf("%d\n",CountActiveOscs());
    }

    for (i = 0; i < NUM_KEYS; i++) {
        m = &(keys[i]);
        m->key_num = i;
        m->status = KEY_INACTIVE;
    }
}


int CountActiveOscs()
{
    int count = 0;
    for (voice_t * v = freeVoicesHead; v != NULL; v = v->next) {
        count++;
    }
    return count;
}

//int main()
//{
//    InitStructures();
//    //printf("%d\n", CountActiveOscs());
//
//    NoteOnHandler(0x00, 0xFF);
//    printf("%d\n", CountActiveOscs());
//        NoteOnHandler(0x00, 0xFF);
//    printf("%d\n", CountActiveOscs());
//        NoteOnHandler(0x01, 0xFF);
//    printf("%d\n", CountActiveOscs());
//        NoteOnHandler(0x02, 0xFF);
//    printf("%d\n", CountActiveOscs());
//        NoteOnHandler(0x03, 0xFF);
//    printf("%d\n", CountActiveOscs());
//        NoteOnHandler(0x04, 0xFF);
//    printf("%d\n", CountActiveOscs());
//        NoteOnHandler(0x05, 0xFF);
//    printf("%d\n", CountActiveOscs());
//        NoteOnHandler(0x06, 0xFF);
//    printf("%d\n", CountActiveOscs());
//        NoteOnHandler(0x07, 0xFF);
//    printf("%d\n", CountActiveOscs());
//        NoteOnHandler(0x08, 0xFF);
//    printf("%d\n", CountActiveOscs());
//
//    NoteOffHandler(0x00);
//
//           NoteOnHandler(0x08, 0xFF);
//    printf("%d\n", CountActiveOscs());
//
//    printf("%d\n", CountActiveOscs());
//    return 0;
//}
