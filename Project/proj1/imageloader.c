/************************************************************************
**
** NAME:        imageloader.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**              Justin Yokota - Starter Code
**				Smile Misaka
**
**
** DATE:        2020-08-15
**
**************************************************************************/

#include "imageloader.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Opens a .ppm P3 image file, and constructs an Image object.
// You may find the function fscanf useful.
// Make sure that you close the file with fclose before returning.
Image *readData(char *filename) {
  FILE *fp = fopen(filename, "r");
  if (!fp)
    return NULL;

  Image *img = malloc(sizeof(Image));
  char format[3];
  uint32_t maxColor;

  if (fscanf(fp, "%2s %u %u %u", format, &img->cols, &img->rows, &maxColor) !=
      4) {
    fclose(fp);
    free(img);
    return NULL;
  }
  img->image = malloc(img->rows * sizeof(Color *));
  for (uint32_t row = 0; row < img->rows; row++) {
    Color *img_row = malloc(img->cols * sizeof(Color));
    for (uint32_t col = 0; col < img->cols; col++) {
      fscanf(fp, "%hhu %hhu %hhu", &img_row[col].R, &img_row[col].G,
             &img_row[col].B);
    }
    img->image[row] = img_row;
  }

  fclose(fp);
  return img;
}

// Given an image, prints to stdout (e.g. with printf) a .ppm P3 file with the
// image's data.
void writeData(Image *image) {
  printf("P3\n%d %d\n255\n", image->cols, image->rows);
  for (uint32_t row = 0; row < image->rows; ++row) {
    for (uint32_t col = 0; col < image->cols; ++col) {
      Color pixel = image->image[row][col];
      printf("%3hhu %3hhu %3hhu", pixel.R, pixel.G, pixel.B);

      if (col < image->cols - 1)
        printf("   ");
    }
    printf("\n");
  }
}

// Frees an image
void freeImage(Image *image) {
  for (uint32_t row = 0; row < image->rows; row++) {
    free(image->image[row]);
  }
  free(image->image);
  // NOTE: the image is returned as a ptr on heap
  free(image);
}
