/* Program that moves a horizontal line up and down on the screen and “bounces” the line
off the top and bottom edges of the display*/

#include <stdbool.h>
#include <stdlib.h>

volatile int pixel_buffer_start; // global variable

// Function prototypes
void clear_screen();
void draw_line(int x0, int y0, int x1, int y1, short int colour);
void swap(int* a, int* b);
void plot_pixel(int x, int y, short int line_color);
void wait_for_vsync();


int main(void) {
	volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
	
	/* Read location of the pixel buffer from the pixel buffer controller */
	pixel_buffer_start = *pixel_ctrl_ptr;
	
	/*Ensure back buffer register stores pixel buffer address*/
	*(pixel_ctrl_ptr + 1) = pixel_buffer_start;
	
	clear_screen();
	
	int y = 0;
	int deltay = 1;
	
	while (1) {
		draw_line(0, y, 319, y, 0xFFFF); // Draw white horizontal line in row y
		wait_for_vsync();
		draw_line(0, y, 319, y, 0x0000); // Erase white horizontal line in row y

		if (y == 0) {
			deltay = 1;
		} else if (y == 239) {
			deltay = -1;
		}
		
		y = y + deltay;
		
	}
	
	return 0;
}


void clear_screen() {
	for (int x = 0; x < 320; x++) {
		for (int y = 0; y < 240; y++) {
			plot_pixel(x, y, 0x0000);
		}
	}
}


void draw_line (int x0, int y0, int x1, int y1, short int colour) {
	bool is_steep = ((abs(y1 - y0)) > (abs(x1 - x0)));
	if (is_steep) {
		swap(&x0, &y0);
		swap(&x1, &y1);
	}
	if (x0 > x1) {
		swap(&x0, &x1);
		swap(&y0, &y1);
	}
	
	int deltax = x1 - x0;
	int deltay = abs(y1 - y0);
	int error = -(deltax / 2);
	int y = y0;
	int y_step;
	if (y0 < y1) {
		y_step = 1;
	} else {
		y_step = -1;
	}
	
	for (int x = x0; x <= x1; x++) {
		if (is_steep) {
			plot_pixel(y, x, colour);
		} else {
			plot_pixel(x,y, colour);
		}
		error = error + deltay;
		if (error >= 0) {
			y = y + y_step;
			error = error - deltax;
		}
	}
}


void swap (int* a, int* b) {
	int c = *a;
	*a = *b;
	*b = c;
}


void plot_pixel(int x, int y, short int line_color) {
	*(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}


void wait_for_vsync() {
	volatile int* pixel_ctrl_ptr = (int*) 0xFF203020; // Pixel controller
	register int status;
	
	*pixel_ctrl_ptr = 1; // Start the synchronization process
	
	status = *(pixel_ctrl_ptr + 3);
	while ((status & 0x01) != 0) {
		status = *(pixel_ctrl_ptr + 3);
	}
}