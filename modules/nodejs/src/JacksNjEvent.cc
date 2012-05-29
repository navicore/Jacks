#define BUILDING_NODE_EXTENSION
#include <node.h>
#include <iostream>
#include "JacksNjEvent.h"
#include "JacksEvent.h"

using namespace v8;

JacksNjEvent::JacksNjEvent(JacksEvent e) {

    impl_ = e;
};
JacksNjEvent::~JacksNjEvent() {
    JacksEvent(&impl_);
};

void JacksNjEvent::Init(Handle<Object> target) {

    // Prepare constructor template
    Local<FunctionTemplate> tpl = FunctionTemplate::New(New);
    tpl->SetClassName(String::NewSymbol("JacksNjEvent"));
    tpl->InstanceTemplate()->SetInternalFieldCount(1);

    // Prototype
    tpl->PrototypeTemplate()->Set(String::NewSymbol("complete"),
                                  FunctionTemplate::New(Complete)->GetFunction());

    tpl->PrototypeTemplate()->Set(String::NewSymbol("getType"),
                                  FunctionTemplate::New(GetType)->GetFunction());

    tpl->PrototypeTemplate()->Set(String::NewSymbol("getData"),
                                  FunctionTemplate::New(GetData)->GetFunction());

    //Persistent<Function> constructor = Persistent<Function>::New(tpl->GetFunction());
    target->Set(String::NewSymbol("JacksNjEvent"), constructor);
}

JacksEvent JacksNjEvent::getImpl() {
    return impl_;
}

/*
Handle<Value> JacksNjEvent::New(const Arguments& args) {
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

    JacksNjEvent* obj = new JacksNjEvent(name, option_str, options, DEFAULT_RB_SIZE);
    obj->Wrap(args.This());

    if (name) {
        delete name;
    }

    if (option_str) {
        delete option_str;
    }

    return args.This();
}
*/

Handle<Value> JacksNjEvent::Complete(const Arguments& args) {
    HandleScope scope;

    JacksNjEvent* obj = ObjectWrap::Unwrap<JacksNjEvent>(args.This());
    JacksEvent impl = obj->getImpl();

    JacksEvent_complete(impl);

    return args.This();
}

Handle<Value> JacksNjEvent::GetType(const Arguments& args) {
    HandleScope scope;

    JacksNjEvent* obj = ObjectWrap::Unwrap<JacksNjEvent>(args.This());
    JacksEvent impl = obj->getImpl();

    long timeout = (long) args[0]->IsUndefined() ? 1 : args[0]->IntegerValue();

    int t = JacksEvent_get_type(impl);

    return scope.Close(t);
}

Handle<Value> JacksNjEvent::GetData(const Arguments& args) {
    HandleScope scope;

    JacksNjEvent* obj = ObjectWrap::Unwrap<JacksNjEvent>(args.This());
    JacksEvent impl = obj->getImpl();

    void *result = JacksEvent_get_data(impl);

    return scope.Close(result);
}

