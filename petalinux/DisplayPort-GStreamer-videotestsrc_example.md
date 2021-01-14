# DisplayPort GStreamer videotestsrc example

Use the GStreamer videotestsrc element to generate a test pattern on the ZynqMPSoC Processor Subsystem DisplayPort Interface

## GOAL:
- Use GStreamer + 'videotestsrc' to send a test pattern to a DisplayPort Display
- Review the gstreamer pipeline elements

```-> [VIDEOTESTSRC] -> [QUEUE] -> [KMSSINK]```

### Notes:
- Step through building the example pipeline above
- During construction of the pipeline, we will use the 'fakesink' element for testing purposes
- 'fakesink' provides a dummy connection for pads to pass data to (no processing takes place on this data)


## Stage 1: Create a GStreamer test pattern with 'videotestsrc'
- Review videotestsrc syntax and patterns

```bash
root@vcu_uz7ev_cc:~# gst-inspect-1.0 videotestsrc

Factory Details:
...
Pad Templates:
  SRC template: 'src'
    Availability: Always
    Capabilities:
      video/x-raw
                 format: { (string)I420, (string)YV12, (string)YUY2, (string)UYVY, (string)AYUV, (string)RGBx, (string)BGRx, (string)xRGB, (stri}
                  width: [ 1, 2147483647 ]
                 height: [ 1, 2147483647 ]
              framerate: [ 0/1, 2147483647/1 ]
         multiview-mode: { (string)mono, (string)left, (string)right }
...
Pads:
  SRC: 'src'
    Pad Template: 'src'

Element Properties:
...
  pattern             : Type of test pattern to generate
                        flags: readable, writable
                        Enum "GstVideoTestSrcPattern" Default: 0, "smpte"
                           (0): smpte            - SMPTE 100% color bars
                           (1): snow             - Random (television snow)
                           (2): black            - 100% Black
                           (3): white            - 100% White
                           (4): red              - Red
                           (5): green            - Green
                           (6): blue             - Blue
                           (7): checkers-1       - Checkers 1px
                           (8): checkers-2       - Checkers 2px
                           (9): checkers-4       - Checkers 4px
                           (10): checkers-8       - Checkers 8px
                           (11): circular         - Circular
                           (12): blink            - Blink
                           (13): smpte75          - SMPTE 75% color bars
                           (14): zone-plate       - Zone plate
                           (15): gamut            - Gamut checkers
                           (16): chroma-zone-plate - Chroma zone plate
                           (17): solid-color      - Solid color
                           (18): ball             - Moving ball
                           (19): smpte100         - SMPTE 100% color bars
                           (20): bar              - Bar
                           (21): pinwheel         - Pinwheel
                           (22): spokes           - Spokes
                           (23): gradient         - Gradient
                           (24): colors           - Colors
...
```

- Construct, add and test the next step in the pipeline
- Example: Select test pattern '0', but won't specify any parameters
- ***Note: This pipeline will run until cancelled manually using <CTRL-C>***

```bash
root@vcu_uz7ev_cc:~# gst-launch-1.0 -v videotestsrc pattern=0 ! \
fakesink                                                                         

Setting pipeline to PAUSED ...
Pipeline is PREROLLING ...
/GstPipeline:pipeline0/GstVideoTestSrc:videotestsrc0.GstPad:src: caps = video/x-raw, format=(string)I420, width=(int)320, height=(int)240, framee
/GstPipeline:pipeline0/GstFakeSink:fakesink0.GstPad:sink: caps = video/x-raw, format=(string)I420, width=(int)320, height=(int)240, framerate=(fe
Pipeline is PREROLLED ...
Setting pipeline to PLAYING ...
New clock: GstSystemClock
^Chandling interrupt.
Interrupt: Stopping pipeline ...
Execution ended after 0:00:02.823296408
Setting pipeline to PAUSED ...
Setting pipeline to READY ...
Setting pipeline to NULL ...
Freeing pipeline ...
```

- Specify the resolution and framerate for test pattern '0'
- We are purposefully not configuring the data format (we will let this be auto-negotiated)
- ***Note: This pipeline will run until cancelled manually using <CTRL-C>***


```bash
root@vcu_uz7ev_cc:~# gst-launch-1.0 -v videotestsrc pattern=0 ! video/x-raw,width=1920,height=1080,framerate=15/1 ! \
fakesink

Setting pipeline to PAUSED ...
Pipeline is PREROLLING ...
/GstPipeline:pipeline0/GstVideoTestSrc:videotestsrc0.GstPad:src: caps = video/x-raw, format=(string)I420, width=(int)1920, height=(int)1080, frae
/GstPipeline:pipeline0/GstCapsFilter:capsfilter0.GstPad:src: caps = video/x-raw, format=(string)I420, width=(int)1920, height=(int)1080, framerae
/GstPipeline:pipeline0/GstFakeSink:fakesink0.GstPad:sink: caps = video/x-raw, format=(string)I420, width=(int)1920, height=(int)1080, framerate=e
/GstPipeline:pipeline0/GstCapsFilter:capsfilter0.GstPad:sink: caps = video/x-raw, format=(string)I420, width=(int)1920, height=(int)1080, framere
Pipeline is PREROLLED ...
Setting pipeline to PLAYING ...
New clock: GstSystemClock
^Chandling interrupt.
Interrupt: Stopping pipeline ...
Execution ended after 0:00:03.837391620
Setting pipeline to PAUSED ...
Setting pipeline to READY ...
Setting pipeline to NULL ...
Freeing pipeline ...
```


## Stage 2: Queue the video test pattern
- Inspect the queue element

```bash
root@vcu_uz7ev_cc:~# gst-inspect-1.0 queue

Factory Details:
  Rank                     none (0)
  Long-name                Queue
  Klass                    Generic
  Description              Simple data queue
  Author                   Erik Walthinsen <omega@cse.ogi.edu>

Plugin Details:
  Name                     coreelements
  Description              GStreamer core elements
...
Pad Templates:
  SINK template: 'sink'
    Availability: Always
    Capabilities:
      ANY

  SRC template: 'src'
    Availability: Always
    Capabilities:
      ANY
...
Pads:
  SINK: 'sink'
    Pad Template: 'sink'
  SRC: 'src'
    Pad Template: 'src'

Element Properties:
...
  max-size-buffers    : Max. number of buffers in the queue (0=disable)
                        flags: readable, writable, changeable in NULL, READY, PAUSED or PLAYING state
                        Unsigned Integer. Range: 0 - 4294967295 Default: 200 
  max-size-bytes      : Max. amount of data in the queue (bytes, 0=disable)
                        flags: readable, writable, changeable in NULL, READY, PAUSED or PLAYING state
                        Unsigned Integer. Range: 0 - 4294967295 Default: 10485760 
...
  flush-on-eos        : Discard all data in the queue when an EOS event is received
                        flags: readable, writable, changeable in NULL, READY, PAUSED or PLAYING state
                        Boolean. Default: false
...
```

- Construct, add and test the addition of a queue element to the previous step in the pipeline
- ***Note: This pipeline will run until cancelled manually using <CTRL-C>***

```bash
root@vcu_uz7ev_cc:~# gst-launch-1.0 -v videotestsrc pattern=0 ! video/x-raw,width=1920,height=1080,framerate=15/1 ! \
queue ! \
fakesink

Setting pipeline to PAUSED ...
Pipeline is PREROLLING ...
/GstPipeline:pipeline0/GstVideoTestSrc:videotestsrc0.GstPad:src: caps = video/x-raw, format=(string)I420, width=(int)1920, height=(int)1080, frae
/GstPipeline:pipeline0/GstCapsFilter:capsfilter0.GstPad:src: caps = video/x-raw, format=(string)I420, width=(int)1920, height=(int)1080, framerae
/GstPipeline:pipeline0/GstQueue:queue0.GstPad:sink: caps = video/x-raw, format=(string)I420, width=(int)1920, height=(int)1080, framerate=(fracte
/GstPipeline:pipeline0/GstQueue:queue0.GstPad:sink: caps = video/x-raw, format=(string)I420, width=(int)1920, height=(int)1080, framerate=(fracte
/GstPipeline:pipeline0/GstFakeSink:fakesink0.GstPad:sink: caps = video/x-raw, format=(string)I420, width=(int)1920, height=(int)1080, framerate=e
/GstPipeline:pipeline0/GstFakeSink:fakesink0.GstPad:sink: caps = video/x-raw, format=(string)I420, width=(int)1920, height=(int)1080, framerate=e
Pipeline is PREROLLED ...
Setting pipeline to PLAYING ...
New clock: GstSystemClock
^Chandling interrupt.
Interrupt: Stopping pipeline ...
Execution ended after 0:00:03.214558471
Setting pipeline to PAUSED ...
Setting pipeline to READY ...
Setting pipeline to NULL ...
Freeing pipeline ...
```

## STAGE 3: Send video out to the KMSSINK (Display Output)
- Note: we did not configure the data format caps, and the auto-negotiation of capabilities was able to properly discover capabilities
- use the 'kmssink' element to send decoded video to the display
- Use gstreamer element properties to allow fullscreen-overlay (if native resolution is higher)

```bash
root@vcu_uz7ev_cc:~# gst-inspect-1.0 kmssink

Factory Details:
  Rank                     secondary (128)
  Long-name                KMS video sink
  Klass                    Sink/Video
  Description              Video sink using the Linux kernel mode setting API
  Author                   V�íctor J�áquez <vjaquez@igalia.com>

Plugin Details:
  Name                     kms
  Description              Video sink using the Linux kernel mode setting API
...
Pad Templates:
  SINK template: 'sink'
    Availability: Always
    Capabilities:
      video/x-raw
                 format: { (string)BGRA, (string)BGRx, (string)RGBA, (string)RGBx, (string)RGB, (string)BGR, (string)UYVY, (string)YUY2, (string)YVYU, (string)I420, (string)YV12, (string)Y42B, (str}
                  width: [ 1, 2147483647 ]
                 height: [ 1, 2147483647 ]
              framerate: [ 0/1, 2147483647/1 ]
...
Pads:
  SINK: 'sink'
    Pad Template: 'sink'

Element Properties:
...
  bus-id              : DRM bus ID
                        flags: readable, writable
                        String. Default: null
  connector-id        : DRM connector id
                        flags: readable, writable
                        Integer. Range: -1 - 2147483647 Default: -1 
  plane-id            : DRM plane id
                        flags: readable, writable
                        Integer. Range: -1 - 2147483647 Default: -1 
...
  fullscreen-overlay  : When enabled, the sink sets CRTC size same as input video size
                        flags: readable, writable
                        Boolean. Default: false
...
```

- Construct, add and test the next step in the pipeline
- ***Note: The command will need to be canceled using <CTRL-C>***

```bash
root@vcu_uz7ev_cc:~# gst-launch-1.0 -v videotestsrc pattern=0 ! video/x-raw,width=1920,height=1080,framerate=15/1 ! \
queue ! \
kmssink bus-id="fd4a0000.zynqmp-display"

Setting pipeline to PAUSED ...
Pipeline is PREROLLING ...
/GstPipeline:pipeline0/GstKMSSink:kmssink0: display-width = 1920
/GstPipeline:pipeline0/GstKMSSink:kmssink0: display-height = 1080
/GstPipeline:pipeline0/GstVideoTestSrc:videotestsrc0.GstPad:src: caps = video/x-raw, format=(string)UYVY, width=(int)1920, height=(int)1080, frae
/GstPipeline:pipeline0/GstCapsFilter:capsfilter0.GstPad:src: caps = video/x-raw, format=(string)UYVY, width=(int)1920, height=(int)1080, framerae
/GstPipeline:pipeline0/GstQueue:queue0.GstPad:sink: caps = video/x-raw, format=(string)UYVY, width=(int)1920, height=(int)1080, framerate=(fracte
/GstPipeline:pipeline0/GstQueue:queue0.GstPad:sink: caps = video/x-raw, format=(string)UYVY, width=(int)1920, height=(int)1080, framerate=(fracte
/GstPipeline:pipeline0/GstCapsFilter:capsfilter0.GstPad:sink: caps = video/x-raw, format=(string)UYVY, width=(int)1920, height=(int)1080, framere
/GstPipeline:pipeline0/GstKMSSink:kmssink0.GstPad:sink: caps = video/x-raw, format=(string)UYVY, width=(int)1920, height=(int)1080, framerate=(fe
Pipeline is PREROLLED ...
Setting pipeline to PLAYING ...
New clock: GstSystemClock
^Chandling interrupt.
Interrupt: Stopping pipeline ...
Execution ended after 0:00:09.463996235
Setting pipeline to PAUSED ...
Setting pipeline to READY ...
Setting pipeline to NULL ...
Freeing pipeline ...
```

## STAGE 3-ALT: Send video out to the KMSSINK (Display Output)
- use the 'kmssink' element to send decoded video to the display
- Use gstreamer element properties to allow fullscreen-overlay (if native resolution is higher)
- Test at non-native resolution of 1280x720 (use fullscreen-overlay)

```bash
root@vcu_uz7ev_cc:~# gst-launch-1.0 -v videotestsrc pattern=0 ! video/x-raw,width=1280,height=720,framerate=15/1 ! \
queue ! \
kmssink bus-id="fd4a0000.zynqmp-display" fullscreen-overlay=true

Setting pipeline to PAUSED ...
Pipeline is PREROLLING ...
/GstPipeline:pipeline0/GstKMSSink:kmssink0: display-width = 1920
/GstPipeline:pipeline0/GstKMSSink:kmssink0: display-height = 1080
/GstPipeline:pipeline0/GstVideoTestSrc:videotestsrc0.GstPad:src: caps = video/x-raw, format=(string)UYVY, width=(int)1280, height=(int)720, framerate=15/1
[  943.960816] PLL: shutdownpsFilter:capsfilter0.GstPad:src: caps = video/x-raw, format=(string)UYVY, width=(int)1280, height=(int)720, framerate=15/1
/GstPipeline:pipeline0/GstQueue:queue0.GstPad:sink: caps = vide[  943.968423] PLL: enable
o/x-raw, format=(string)UYVY, width=(int)1280, height=(int)720, framerate=(fraction)15/1, multiview-mode=(string)mono, pixel-aspect-ratio=(fraction)
/GstPipeline:pipeline0/GstQueue:queue0.GstPad:sink: caps = video/x-raw, format=(string)UYVY, width=(int)1280, height=(int)720, framerate=(fractie
/GstPipeline:pipeline0/GstCapsFilter:capsfilter0.GstPad:sink: caps = video/x-raw, format=(string)UYVY, width=(int)1280, height=(int)720, framerate=(fraction)15/1
/GstPipeline:pipeline0/GstKMSSink:kmssink0.GstPad:sink: caps = video/x-raw, format=(string)UYVY, width=(int)1280, height=(int)720, framerate=(fre
Pipeline is PREROLLED ...
Setting pipeline to PLAYING ...
New clock: GstSystemClock
^Chandling interrupt.
Interrupt: Stopping pipeline ...
Execution ended after 0:00:06.795817839
Setting pipeline to PAUSED ...
Setting pipeline to READY ...
Setting pipeline to NULL ...
[  950.996659] PLL: shutdown
[  951.000457] PLL: enable
Freeing pipeline ...
root@vcu_uz7ev_cc:~# 
```