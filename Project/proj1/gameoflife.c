/************************************************************************
**
** NAME:        gameoflife.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Justin Yokota - Starter Code
**				YOUR NAME HERE
**
**
** DATE:        2020-08-23
**
**************************************************************************/

#include "imageloader.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

void processCLI(int argc, char **argv, char **filename, uint32_t *rule) {
  if (argc != 3) {
    printf("usage: %s filename rule\n", argv[0]);
    printf("filename is an ASCII PPM file (type P3) with maximum value 255.\n");
    printf("rule is a hex number beginning with 0x; Life is 0x1808\n");
    exit(-1);
  }
  *filename = argv[1];
  *rule = (uint32_t)strtol(argv[2], NULL, 16);
}

int count_alive_neighbors(Image *image, int row, int col, int channel) {
  int count = 0;
  for (int i = -1; i <= 1; ++i) {
    for (int j = -1; j <= 1; ++j) {
      if (i == 0 && j == 0)
        continue;

      int r = (row + i + image->rows) % image->rows;
      int c = (col + j + image->cols) % image->cols;

      Color pixel = image->image[r][c];
      uint8_t val = 0;
      if (channel == 0)
        val = pixel.R;
      else if (channel == 1) {
        val = pixel.G;
      } else {
        val = pixel.B;
      }
      if (val > 0)
        count++;
    }
  }
  return count;
}

// Determines what color the cell at the given row/col should be. This function
// allocates space for a new Color. Note that you will need to read the eight
// neighbors of the cell in question. The grid "wraps", so we treat the top row
// as adjacent to the bottom row and the left column as adjacent to the right
// column.
Color *evaluateOneCell(Image *image, int row, int col, uint32_t rule) {
  if (!image) {
    return NULL;
  }
  Color *rule_based_color = malloc(sizeof(Color));
  Color current = image->image[row][col];

  uint8_t cur_vals[3] = {current.R, current.G, current.B};
  uint8_t next_vals[3];

  for (int i = 0; i < 3; ++i) {
    int neighbors = count_alive_neighbors(image, row, col, i);
    int is_alive = (cur_vals[i] > 0);

    int bit_pos = is_alive ? 9 + neighbors : neighbors;
    if ((rule >> bit_pos) & 1) {
      next_vals[i] = is_alive ? cur_vals[i] : 255;
    } else {
      next_vals[i] = 0;
    }
  }
  rule_based_color->R = next_vals[0];
  rule_based_color->G = next_vals[1];
  rule_based_color->B = next_vals[2];

  return rule_based_color;
}

// The main body of Life; given an image and a rule, computes one iteration of
// the Game of Life. You should be able to copy most of this from
// steganography.c
Image *life(Image *image, uint32_t rule) {
  if (!image)
    return NULL;
  Image *new_image = malloc(sizeof(Image));
  new_image->cols = image->cols;
  new_image->rows = image->rows;
  new_image->image = malloc(new_image->rows * sizeof(Color *));
  for (uint32_t row = 0; row < new_image->rows; ++row) {
    new_image->image[row] = malloc(new_image->cols * sizeof(Color));
    for (uint32_t col = 0; col < new_image->cols; ++col) {
      Color *temp_color = evaluateOneCell(image, row, col, rule);
      new_image->image[row][col] = *temp_color;
      free(temp_color);
    }
  }
  return new_image;
}

/*
Loads a .ppm from a file, computes the next iteration of the game of life, then
prints to stdout the new image.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a .ppm.
argv[2] should contain a hexadecimal number (such as 0x1808). Note that this
will be a string. You may find the function strtol useful for this conversion.
If the input is not correct, a malloc fails, or any other error occurs, you
should exit with code -1. Otherwise, you should return from main with code 0.
Make sure to free all memory before returning!

You may find it useful to copy the code from steganography.c, to start.
*/
int main(int argc, char **argv) {
  char *filename;
  uint32_t rule;
  processCLI(argc, argv, &filename, &rule);

  Image *image = readData(filename);
  if (!image)
    exit(-1);

  Image *next_gen = life(image, rule);
  if (!next_gen) {
    freeImage(image);
    exit(-1);
  }
  writeData(next_gen);
  freeImage(image);
  freeImage(next_gen);
  return 0;
}
