/************************************************************************
**
** NAME:        steganography.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**				Justin Yokota - Starter Code
**				Smile Misaka
**
** DATE:        2020-08-23
**
**************************************************************************/

#include "imageloader.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

// Determines what color the cell at the given row/col should be. This should
// not affect Image, and should allocate space for a new Color.
Color *evaluateOnePixel(Image *image, int row, int col) {
  if (!image)
    return NULL;

  Color *c = malloc(sizeof(Color));
  if ((image->image[row][col].B & 1) == 1) {
    *c = (Color){255, 255, 255};
  } else {
    *c = (Color){0, 0, 0};
  }
  return c;
}

// Given an image, creates a new image extracting the LSB of the B channel.
Image *steganography(Image *image) {
  if (!image)
    return NULL;

  Image *new_image = malloc(sizeof(Image));
  new_image->cols = image->cols;
  new_image->rows = image->rows;
  new_image->image = malloc(new_image->rows * sizeof(Color *));
  for (uint32_t row = 0; row < new_image->rows; ++row) {
    new_image->image[row] = malloc(new_image->cols * sizeof(Color));
    for (uint32_t col = 0; col < new_image->cols; ++col) {
      Color *temp_color = evaluateOnePixel(image, row, col);
      new_image->image[row][col] = *temp_color;
      free(temp_color);
    }
  }
  return new_image;
}

/*
Loads a file of ppm P3 format from a file, and prints to stdout (e.g. with
printf) a new image, where each pixel is black if the LSB of the B channel is 0,
and white if the LSB of the B channel is 1.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a file of ppm P3 format (not
necessarily with .ppm file extension). If the input is not correct, a malloc
fails, or any other error occurs, you should exit with code -1. Otherwise, you
should return from main with code 0. Make sure to free all memory before
returning!
*/
int main(int argc, char **argv) {
  Image *image;
  Image *decoded_image;
  char *filename;
  if (argc != 2) {
    printf("usage: %s filename\n", argv[0]);
    printf("filename is an ASCII PPM file (type P3) with maximum value 255.\n");
    exit(-1);
  }
  filename = argv[1];
  image = readData(filename);
  if (!image)
    exit(-1);
  decoded_image = steganography(image);
  if (!decoded_image)
    exit(-1);
  writeData(decoded_image);
  freeImage(image);
  freeImage(decoded_image);
  return 0;
}
