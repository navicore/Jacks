/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
///                                               ///
/// todo: expose these in a sane less brittle way ///
///                                               ///
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
//redeclare from JackClient.h - don't expose the whole raw JackClient api
enum JACKSCRIPT_EVENT_TYPE {
    PROCESS, SESSION, ERR, SAMPLE_RATE_CHANGE, SHUTDOWN
};

//don't expose all of jack to the host lang - swig can't seem to find
//these files with %include <jack/transport.h> anyway :|

//redeclare from jack/transport.h
typedef enum {

	/* the order matters for binary compatibility */
	JackTransportStopped = 0,	/**< Transport halted */
	JackTransportRolling = 1,	/**< Transport playing */
	JackTransportLooping = 2,	/**< For OLD_TRANSPORT, now ignored */
	JackTransportStarting = 3	/**< Waiting for sync ready */

} jack_transport_state_t;

//redeclare from jack/types.h
enum JackPortFlags {

    JackPortIsInput = 0x1,
    JackPortIsOutput = 0x2,
    JackPortIsPhysical = 0x4, 
    JackPortCanMonitor = 0x8,
    JackPortIsTerminal = 0x10
};      

typedef float jack_default_audio_sample_t;

enum JackOptions {
     JackNullOption = 0x00,
     JackNoStartServer = 0x01,
     JackUseExactName = 0x02,
     JackServerName = 0x04,
     JackLoadName = 0x08,
     JackLoadInit = 0x10,
     JackSessionID = 0x20
};
typedef enum JackOptions jack_options_t;

//redeclare from jack/session.h
enum JackSessionEventType {

    JackSessionSave = 1,
    JackSessionSaveAndQuit = 2,
    JackSessionSaveTemplate = 3
};
typedef enum JackSessionEventType jack_session_event_type_t;

enum JackSessionFlags {
    JackSessionSaveError = 0x01,
    JackSessionNeedTerminal = 0x02
};
typedef enum JackSessionFlags jack_session_flags_t;

typedef uint32_t	     jack_nframes_t;

enum JackLatencyCallbackMode {

     JackCaptureLatency,
     JackPlaybackLatency
};

