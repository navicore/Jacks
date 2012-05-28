#ifndef JACKSNJCLIENT_H
#define JACKSNJCLIENT_H

#include <node.h>
#include "JacksRbClient.h"

class JacksNjClient : public node::ObjectWrap {
 public:
  static void Init(v8::Handle<v8::Object> target);
  JacksRbClient getImpl();

 protected:
  JacksNjClient();
  ~JacksNjClient();

  static v8::Handle<v8::Value> New              (const v8::Arguments& args);
  static v8::Handle<v8::Value> GetEvent         (const v8::Arguments& args);
  static v8::Handle<v8::Value> GetSampleRate    (const v8::Arguments& args);
  static v8::Handle<v8::Value> Activate         (const v8::Arguments& args);
  static v8::Handle<v8::Value> GetName          (const v8::Arguments& args);
  static v8::Handle<v8::Value> GetRbSize        (const v8::Arguments& args);

  JacksRbClient impl_;
};

#endif

