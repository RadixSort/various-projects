#include <stdio.h>
#include <altera_up_sd_card_avalon_interface.h>

int main(void) {
	char buffer_name[10];
	short int handler;
	alt_up_sd_card_dev *device_reference = NULL;
	int connected = 0;
	device_reference = alt_up_sd_card_open_dev("/dev/SD_Card");

	if (device_reference != NULL) {
		while(1) {
			if ((connected == 0) && (alt_up_sd_card_is_Present())) {
			printf("Card connected.\n");
				if (alt_up_sd_card_is_FAT16()) {
					printf("FAT16 file system detected.\n");

					//Print out the list in the sd card
					handler = alt_up_sd_card_find_first("", buffer_name);
					printf("%s \n", buffer_name);
					while ((handler = alt_up_sd_card_find_next(buffer_name)) != -1)
						printf("%s \n", buffer_name);

				}else{
					printf("Unknown file system.\n");
				}
				connected = 1;
			} else if ((connected == 1) && (alt_up_sd_card_is_Present() == false)) {
				printf("Card disconnected.\n");
				connected = 0;
			}
		}
	}
	return 0;
}