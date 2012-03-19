#include "JacksClient.h"
#include <assert.h>
#include "config.h"
#include "jack/jack.h"

int main(void) {
  JacksClient cl = JacksClient_new("myclient", NULL, JackNullOption);
  assert(cl);
  JacksClient_activate(cl, 1);
  JacksClient_free(&cl);
}
