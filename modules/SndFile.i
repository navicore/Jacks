/*
 *  Copyright (C) 2012 Ed Sweeney
 *  
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation; either version 2.1 of the License, or
 *  (at your option) any later version.
 *  
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *  
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program; if not, write to the Free Software 
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

%module sndfile

%{
#include "config.h"
#include "JacksSndFile.h"
#include <sndfile.h>
#include <jack/jack.h>
%}

%include "jack_exceptions.h"

typedef struct {
    %extend {
        SndFile(int sample_rate, int channels, int bitdepth, char *path) {

            SndFile *holder;
            holder = malloc(sizeof(SndFile));

            SF_INFO sf_info;
            int short_mask;

            sf_info.samplerate = sample_rate;
            sf_info.channels = channels;

            switch (bitdepth) {
                case 8: short_mask = SF_FORMAT_PCM_U8;
                    break;
                case 16: short_mask = SF_FORMAT_PCM_16;
                     break;
                case 24: short_mask = SF_FORMAT_PCM_24;
                     break;
                case 32: short_mask = SF_FORMAT_PCM_32;
                     break;
                default: short_mask = SF_FORMAT_PCM_16;
                     break;
            }		 
            sf_info.format = SF_FORMAT_WAV|short_mask;

            if ((holder->sf = sf_open (path, SFM_WRITE, &sf_info)) == NULL) {
                throw_exception("cannot open sndfile");
            }
            return holder;
        }
        ~SndFile() {
            free($self);
        }

        //void setSampleRate(int sample_rate) {
        //todo
        //}

        void writeFloat(char *framebuf, int cnt) {

            const size_t sample_size = sizeof(jack_default_audio_sample_t);

            jack_nframes_t samples_per_frame = $self->channels;
            size_t bytes_per_frame = samples_per_frame * sample_size;

			if (sf_writef_float ($self->sf, framebuf, cnt) != 1) {
                throw_exception("cannot write sndfile");
			}
		}
	}
} SndFile;

