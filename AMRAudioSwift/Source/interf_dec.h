
#ifndef OPENCORE_AMRNB_INTERF_DEC_H
#define OPENCORE_AMRNB_INTERF_DEC_H

#ifdef __cplusplus
extern "C" {
#endif

void *Decoder_Interface_init(void);
void Decoder_Interface_exit(void *state);
void Decoder_Interface_Decode(void *state, const unsigned char *in, short *out, int bfi);

#ifdef __cplusplus
}
#endif

#endif
