#define BUILDING_NODE_EXTENSION
#include <node.h>
#include <iostream>
#include "JacksNjClient.h"
#include <JacksRbClient.h>

using namespace v8;

JacksNjClient::JacksNjClient(const char *name, 
                             const char *option_str, 
                             jack_options_t option) {
    impl_ = JacksRbClient_new(name, option_str, option);
};
JacksNjClient::~JacksNjClient() {
    JacksRbClient_free(&impl_);
};

void JacksNjClient::Init(Handle<Object> target) {

    // Prepare constructor template
    Local<FunctionTemplate> tpl = FunctionTemplate::New(New);
    tpl->SetClassName(String::NewSymbol("JacksNjClient"));
    tpl->InstanceTemplate()->SetInternalFieldCount(1);

    // Prototype
    tpl->PrototypeTemplate()->Set(String::NewSymbol("getEvent"),
                                  FunctionTemplate::New(GetEvent)->GetFunction());

    tpl->PrototypeTemplate()->Set(String::NewSymbol("getSampleRate"),
                                  FunctionTemplate::New(GetSampleRate)->GetFunction());

    tpl->PrototypeTemplate()->Set(String::NewSymbol("activate"),
                                  FunctionTemplate::New(Activate)->GetFunction());

    tpl->PrototypeTemplate()->Set(String::NewSymbol("getRbSize"),
                                  FunctionTemplate::New(GetRbSize)->GetFunction());

    Persistent<Function> constructor = Persistent<Function>::New(tpl->GetFunction());
    target->Set(String::NewSymbol("JacksNjClient"), constructor);
}

JacksRbClient JacksNjClient::getImpl() {
    return impl_;
}

Handle<Value> JacksNjClient::New(const Arguments& args) {
    HandleScope scope;

    if (args.Length() != 3) {
        ThrowException(Exception::TypeError(String::New("Wrong number of arguments")));
        return scope.Close(Undefined());
    }

    char *name;
    if (args[0]->IsUndefined()) {
        name = NULL;
    } else {
        v8::Local<v8::String> s = args[0]->ToString();
        name = new char[s->Length() + 1];
        s->WriteAscii((char*)name);
    }
    char *option_str;
    if (args[1]->IsUndefined()) {
        option_str = NULL;
    } else {
        v8::Local<v8::String> s = args[1]->ToString();
        option_str = new char[s->Length() + 1];
        s->WriteAscii((char*)option_str);
    }
    int options = args[2]->IsUndefined() ? 0 : args[2]->NumberValue();

    JacksNjClient* obj = new JacksNjClient(name, option_str, options, DEFAULT_RB_SIZE);
    obj->Wrap(args.This());

    if (name) {
        delete name;
    }

    if (option_str) {
        delete option_str;
    }

    return args.This();
}

Handle<Value> JacksNjClient::GetEvent(const Arguments& args) {
    HandleScope scope;

    JacksNjClient* obj = ObjectWrap::Unwrap<JacksNjClient>(args.This());
    JacksRbClient impl = obj->getImpl();

    long timeout = (long) args[0]->IsUndefined() ? 1 : args[0]->IntegerValue();

    JacksEvent e = JacksRbClient_get_event(impl, timeout);

    JacksNjEvent njevent = new JacksNjEvent(e);
    
    return scope.Close(njevent);
}

Handle<Value> JacksNjClient::GetSampleRate(const Arguments& args) {
    HandleScope scope;

    JacksNjClient* obj = ObjectWrap::Unwrap<JacksNjClient>(args.This());
    JacksRbClient impl = obj->getImpl();

    jack_nframes_t result = JacksRbClient_get_sample_rate(impl);

    return scope.Close(result);
}

Handle<Value> JacksNjClient::Activate(const Arguments& args) {
    HandleScope scope;

    JacksNjClient* obj = ObjectWrap::Unwrap<JacksNjClient>(args.This());
    JacksRbClient impl = obj->getImpl();

    JacksRbClient_activate(impl);

    return args.This();
}

Handle<Value> JacksNjClient::GetRbSize(const Arguments& args) {
    HandleScope scope;

    JacksNjClient* obj = ObjectWrap::Unwrap<JacksNjClient>(args.This());
    JacksRbClient impl = obj->getImpl();

    jack_nframes_t result = JacksRbClient_get_rb_size(impl);

    return scope.Close(result);
}

