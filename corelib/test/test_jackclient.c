#include "JacksRbClient.h"
#include <assert.h>
#include "config.h"
#include "jack/jack.h"

int main(void) {
  JacksRbClient cl = JacksRbClient_new("myclient", NULL, JackNullOption, NULL);
  assert(cl);
  JacksRbClient_activate(cl, 1);
  JacksRbClient_free(&cl);
}
