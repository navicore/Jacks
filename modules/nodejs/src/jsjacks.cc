#define BUILDING_NODE_EXTENSION
#include <node.h>
#include "JacksNjClient.h"
#include "JacksNjPort.h"
#include "JacksNjEvent.h"
#include "JacksNjLatencyRange.h"
#include "JacksNjPortBuffer.h"

using namespace v8;

void InitAll(Handle<Object> target) {
  JacksNjClient::Init(target);
  //JacksNjPort::Init(target);
  //JacksNjEvent::Init(target);
  //JacksNjLatencyRange::Init(target);
  //JacksNjPortBuffer::Init(target);
}

NODE_MODULE(jacks, InitAll)

