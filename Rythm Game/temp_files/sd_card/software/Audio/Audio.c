#include <stdio.h>
#include <stdlib.h>
#include <sys/alt_irq.h>

#include <altera_up_sd_card_avalon_interface.h>
#include <altera_up_avalon_audio.h>
#include <altera_up_avalon_audio_and_video_config.h>

#define key1 (volatile char*) 0x00004480
#define key2 (volatile char*) 0x00004460

#define BUFFER_SIZE 96 //DO NOT CHANGE!
#define SONG_ONE "test.wav"

alt_up_audio_dev *audio;
alt_up_sd_card_dev *sd_card = NULL;

short int music_file;
long file_size;
long song_size; //song_size
unsigned int *audio_stream;
volatile long stream_position;

void av_config_setup(){
	printf("Configuring audio and video.\n");
	alt_up_av_config_dev * av_config = alt_up_av_config_open_dev("/dev/audio_and_video_config_0");
	while (!alt_up_av_config_read_ready(av_config));

	printf("Opening audio device.\n");

	audio = alt_up_audio_open_dev("/dev/audio_0");

	alt_up_audio_reset_audio_core(audio);
}


void audio_ISR() {
	alt_up_audio_write_fifo(audio, &audio_stream[stream_position], BUFFER_SIZE, ALT_UP_AUDIO_LEFT);
	alt_up_audio_write_fifo(audio, &audio_stream[stream_position], BUFFER_SIZE, ALT_UP_AUDIO_RIGHT);
	stream_position += BUFFER_SIZE;
	if (stream_position >= song_size - BUFFER_SIZE) {
		stream_position = 0;
	}
}


char openFileinSD(char* fileName, short int* file_handle_ptr){
	short int file_handle;
	char status = -1;

	sd_card = alt_up_sd_card_open_dev("/dev/SD_Card");

	if (sd_card != NULL){
		while(1){
			if (alt_up_sd_card_is_Present()){
				printf("Card connected.\n");
				if (alt_up_sd_card_is_FAT16()){
					printf("FAT16 confirmed.\n");
					file_handle = alt_up_sd_card_fopen( fileName, false );
					if ( file_handle == -1 )
						printf( "*** File cannot be opened.\n");
					else if ( file_handle == -2 )
						printf( "*** File already opeend.\n");
					else {
						*file_handle_ptr = file_handle;
						status = 0;
						printf( "File obtained.\n");
						return status;
					}
					printf("*** Error reading File.\n");
				} else {
					printf("*** Not FAT16.\n");
				}
			}
		}
	}
	printf("*** Storage Device may not found.\n");
	return status;
}


void load_song(){
	song_size = 0;

	if (openFileinSD(SONG_ONE, &music_file) == 0){
		char a;
		char b;
		char *data_str = "data";
		int i, j;

		for (i = 0; i < 45; i++) {
			a = (char) alt_up_sd_card_read(music_file);
			printf("%c\n", a);
			if (a == data_str[j]) {
				j++;
				if (j == 3) {
					printf("File size found.\n");
					alt_up_sd_card_read(music_file); // letter A
					char byte_0 = (char) alt_up_sd_card_read(music_file);
					char byte_1 = (char) alt_up_sd_card_read(music_file);
					char byte_2 = (char) alt_up_sd_card_read(music_file);
					char byte_3 = (char) alt_up_sd_card_read(music_file);
					file_size = ((unsigned char) byte_3 << 24)
							| ((unsigned char) byte_2 << 16)
							| ((unsigned char) byte_1 << 8)
							| (unsigned char) byte_0;
					printf("Music file size: %lu\n", file_size);
				}
			} else {
				j = 0;
				printf("we are in else\n");
			}
		}

		printf("Allocating memory space.\n");
		unsigned int WHY[file_size];
		audio_stream = WHY;
		if (audio_stream == NULL) {
			printf("*** Failed to allocate left audio stream!");
			exit(1);
		}

		printf("Reading music file.\n");
		short converter;
		while (song_size < file_size / 2) {
			b = (char) alt_up_sd_card_read(music_file);
			a = (char) alt_up_sd_card_read(music_file);
			converter = ((unsigned char) a << 8) | (unsigned char) b;
			converter = converter/2;
			audio_stream[song_size] = converter;
			song_size++;
		}

		printf("Starting music. \n");

		printf("Song Size: %lu, byte: 0x%08x\n", song_size,
				audio_stream[song_size - 41]);

		alt_irq_register(AUDIO_0_IRQ, 0, audio_ISR);
		//alt_irq_enable(AUDIO_0_IRQ);
		alt_up_audio_enable_write_interrupt(audio);

	}
	printf("*** Error Loading Song.\n");
	return;
}
int main() {
	while(1) {
		while (*key2 == 0) {
			printf("Key2 press awknowledged.\n");
			av_config_setup();
			load_song();
			while (*key2 == 0) {}
		}
	}
	return 0;
}
