#ifndef __MIDIQ_H__
#define __MIDIQ_H__

#include <stdio.h>
#include <stdint.h>

#define DEBUG 1

#if DEBUG

#else
#include <system.h>
#include <alt_types.h>
#endif

#define NUM_VOICES     (4)
#define NUM_KEYS     (128)

#define VOICE_NOKEY     (255)

#define KEY_INACTIVE    (0)
#define KEY_PLAYING     (1)
#define KEY_WAITING     (2)

#define KEY_OFF            (0)
#define KEY_ON            (1)

typedef enum {HEAD,TAIL} PopVoiceLocation;
typedef enum {VOICE_ACTIVE, VOICE_INACTIVE} voiceState;

typedef enum {SYNTH_MODE_POLY, SYNTH_MODE_MONO, SYNTH_MODE_GLIDE} synthMode;


typedef struct voice_t {
    voiceState status;
    uint32_t *freq, *key_on;
    uint32_t *amp1, *amp0;

    uint8_t key_num;

    struct voice_t* prev, *next;
} voice_t;

typedef struct midikey_t {
    uint8_t key_num;
    uint8_t status;
    uint8_t velocity;
    voice_t* osc;
    struct midikey_t* prev, *next;
} midikey_t;



void removeVoice(voice_t ** head, voice_t ** tail, voice_t * v);
void initControls();
void ControlHandler(uint8_t control, uint8_t value);
void NoteOnHandler(uint8_t note, uint8_t vel, PopVoiceLocation from);
void NoteOffHandler(uint8_t note);
void initStructures(uint8_t voicesInUse);

voice_t * PopVoice(voice_t ** head, voice_t ** tail, PopVoiceLocation from);
void PushVoice(voice_t ** head, voice_t ** tail, PopVoiceLocation from, voice_t * v);
void removeWaiting(midikey_t ** head, midikey_t ** tail, midikey_t * v);
void PushWaiting(midikey_t ** head, midikey_t ** tail, PopVoiceLocation from, midikey_t * v);
midikey_t * PopWaiting(midikey_t ** head, midikey_t ** tail, PopVoiceLocation from);

void InitVoice(voice_t * v, uint8_t note, uint8_t vel);
void MuteVoice(voice_t * v);
int CountVoices(voice_t * head);
#endif
