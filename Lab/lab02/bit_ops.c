#include "bit_ops.h"
#include <stdio.h>

// Return the nth bit of x.
// Assume 0 <= n <= 31
unsigned get_bit(unsigned x, unsigned n) {
  // YOUR CODE HERE
  // Returning -1 is a placeholder (it makes
  // no sense, because get_bit only returns
  // 0 or 1)
  // return -1;
  return (x >> n) & 1;
}
// Set the nth bit of the value of x to v.
// Assume 0 <= n <= 31, and v is 0 or 1
void set_bit(unsigned *x, unsigned n, unsigned v) {
  // YOUR CODE HERE
  // HACK: creating a mask whose n-th bit is 0 and other bits are 1
  unsigned mask = ~(1 << n);
  *x = *x & mask;
  *x = *x | (v << n);
}
// Flip the nth bit of the value of x.
// Assume 0 <= n <= 31
void flip_bit(unsigned *x, unsigned n) {
  unsigned mask = 1 << n;
  *x ^= mask;
}
