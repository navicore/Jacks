#ifndef JACKSNJEVENT_H
#define JACKSNJEVENT_H

#include <node.h>
#include "JacksEvent.h"

class JacksNjEvent : public node::ObjectWrap {
 public:
  static void Init(v8::Handle<v8::Object> target);
  JacksEvent getImpl();

 protected:
  JacksNjEvent(JacksEvent);
  ~JacksNjEvent();

  static v8::Handle<v8::Value> New      (const v8::Arguments& args);
  static v8::Handle<v8::Value> Complete (const v8::Arguments& args);
  static v8::Handle<v8::Value> GetData  (const v8::Arguments& args);
  static v8::Handle<v8::Value> GetType  (const v8::Arguments& args);

  JacksEvent impl_;
};

#endif

