#define BUILDING_NODE_EXTENSION
#include <node.h>
#include "JsClient.h"
#include "JsPort.h"
#include "JsEvent.h"
#include "JsLatencyRange.h"
#include "JsPortBuffer.h"

using namespace v8;

void InitAll(Handle<Object> target) {
  JsClient::Init(target);
  JsPort::Init(target);
  JsEvent::Init(target);
  JsLatencyRange::Init(target);
  JsPortBuffer::Init(target);
}

NODE_MODULE(jacks, InitAll)

