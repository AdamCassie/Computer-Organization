/*Program to animate eight small filled rectangles moving continuously and 
“bouncing” off the edges of the screen*/

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
	// declare other variables
	// initialize location and direction of rectangles
	int x_box[8];
	int y_box[8];
	int dx_box[8];
	int dy_box[8];
	int colour_box[8];
	short int colour_list[7] = {0xF800, 0x07E0, 0x001F, 0xFFFF, 0xFFE0, 0xF81F, 0x07FF};
	
	for (int i = 0; i < 8; ++i) {
		x_box[i] = rand() % 320;
		y_box[i] = rand() % 240;
		colour_box[i] = colour_list[rand() % 7];
		dx_box[i] = rand() % 2 * 2 - 1;
		dy_box[i] = rand() % 2 * 2 - 1;
	}
	
	/* set front pixel buffer to start of FPGA On-chip memory */
	*(pixel_ctrl_ptr + 1) = 0xC8000000; // first store the address in the
										// back buffer
	
	/* now, swap the front/back buffers, to set the front buffer location */
	wait_for_vsync();
	/* initialize a pointer to the pixel buffer, used by drawing functions */
	pixel_buffer_start = *pixel_ctrl_ptr;
	clear_screen(); // pixel_buffer_start points to the pixel buffer
	/* set back pixel buffer to start of SDRAM memory */
	*(pixel_ctrl_ptr + 1) = 0xC0000000;
	pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
	
	while (1) {
	/* Erase any boxes and lines that were drawn in the last iteration */
	clear_screen();
	
	// code for drawing the boxes and lines
	// code for updating the locations of boxes 
		for (int i = 0; i < 8; ++i) {
			plot_pixel(x_box[i], y_box[i], colour_box[i]);

			if (i < 7) {
				draw_line(x_box[i], y_box[i], x_box[i+1], y_box[i+1], 0xFFFF);
			} else {
				draw_line(x_box[i], y_box[i], x_box[0], y_box[0], 0XFFFF);
			}
				
			if (x_box[i] == 0) {
				dx_box[i] = 1;
			} else if (x_box[i] == 319) {
				dx_box[i] = -1;
			}
			
			if (y_box[i] == 0) {
				dy_box[i] = 1;
			} else if (y_box[i] == 239) {
				dy_box[i] = -1;
			}
			
			x_box[i] += dx_box[i];
			y_box[i] += dy_box[i];
		}
		
		wait_for_vsync(); // swap front and back buffers on VGA vertical sync
		pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
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
	volatile int* pixel_ctrl_ptr = (int* )0xFF203020; // Pixel controller
	register int status;
	
	*pixel_ctrl_ptr = 1; // Start the synchronization process
	
	status = *(pixel_ctrl_ptr + 3);
	while ((status & 0x01) != 0) {
		status = *(pixel_ctrl_ptr + 3);
	}
}