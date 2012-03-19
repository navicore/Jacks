#include "config.h"
#include "JacksEvent.h"
#include "JacksEventQueue.h"
#include "JacksLatch.h"
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <assert.h>

#define TEST_EVENT_TYPE 99

int main(void) {

    JacksLatch mylatch = JacksLatch_new();
    assert(mylatch);
    //JacksLatch_get(mylatch); //this will block forever until post
    JacksLatch_post(mylatch);
    JacksLatch_get(mylatch);

    JacksEvent e = JacksEvent_new(TEST_EVENT_TYPE, JacksLatch_post, mylatch);
    assert(e);
    JacksEvent_complete(e);
    JacksLatch_get(mylatch);

    JacksEventQueue equeue = JacksEventQueue_new();
    assert(equeue);

    JacksEvent qevent = JacksEvent_new(TEST_EVENT_TYPE, JacksLatch_post, mylatch);
    assert(qevent);

    JacksEventQueue_put(equeue, qevent);
    JacksEvent qevent2 =  JacksEventQueue_get(equeue, -1);
    assert(qevent2);
    JacksEvent_complete(qevent2);
    JacksLatch_get(mylatch);

    JacksLatch_free(&mylatch);
    JacksEvent_free(&e);
    JacksEventQueue_free(&equeue);
    JacksEvent_free(&qevent);

}

