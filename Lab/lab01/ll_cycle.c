#include "ll_cycle.h"
#include <stddef.h>

int ll_has_cycle(node *head) {
  node *tortoise = head;
  node *hare = head;
  while (1) {
    for (int i = 0; i < 2; ++i) {
      if (hare == NULL)
        return 0;
      hare = hare->next;
    }
    // NOTE: we don't need to check whether tortoise is NULL
    // since the node is checked when updating hare
    tortoise = tortoise->next;
    if (hare == tortoise)
      return 1;
  }
}
