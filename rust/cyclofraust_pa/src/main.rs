// #![feature(step_by)]
// extern crate cpal;
extern crate libc;
use std::ffi::CString;
use std::net::UdpSocket;
use std::net::SocketAddr;
use std::io::{Error,ErrorKind};
use std::string::String;
use std::fmt::format;
use std::sync::mpsc;
use std::thread;
use std::str::FromStr;
use std::cmp::min;
extern crate portaudio;

use portaudio as pa;

extern crate tinyosc;
use tinyosc as osc;

extern {
  pub fn fraust_init(samplerate: i32);
  pub fn fraust_compute(count: i32, input: *mut libc::c_float, output: *mut libc::c_float );
  pub fn fraust_setval(label: *const libc::c_char , val: libc::c_float); 
}


enum KeType { 
  KeyPress,
  KeyMove,
  KeyUnpress,
  KeyHit
} 

pub struct KeyEvt { 
  evttype: KeType
, keyindex: i32
, position: f32
}

const CHANNELS: i32 = 2;
const NUM_SECONDS: i32 = 5;
const SAMPLE_RATE: f64 = 44_100.0;
const FRAMES_PER_BUFFER: u32 = 64;

fn main() {
    run().unwrap()
}


fn run() -> Result<(), pa::Error> {

    // ---------------------------------------------
    // start the osc receiver thread
    // ---------------------------------------------

    // make a channel to receive updates from the osc.
    let (tx, rx) = mpsc::channel::<KeyEvt>();

    // we'll do osc receive below, in the main thread.

    // ---------------------------------------------
    // init fraust 
    // ---------------------------------------------
    println!("initting with sample rate: {}", SAMPLE_RATE);

    unsafe { fraust_init(SAMPLE_RATE as i32); }

    let bufmax = 1000;
    let mut flts = [0.0;1000];
    flts[0] = 1.0;
    
    let mut outflts = [0.0;1000];

    let volstring = CString::new("Volume").unwrap();

    unsafe { fraust_setval(volstring.as_ptr(), 0.05); }

    let mut loopcount = 0;
    let mut buflen = 0;
    let bufmaxu = bufmax as usize;
    let mut bufidx = bufmaxu - 1;

    // make a full buffer to begin with.
    // unsafe { fraust_compute(bufmax, flts.as_mut_ptr(), outflts.as_mut_ptr()); }

    // ---------------------------------------------
    // start the portaudio process!
    // ---------------------------------------------
    println!("PortAudio Test: output sawtooth wave. SR = {}, BufSize = {}", SAMPLE_RATE, FRAMES_PER_BUFFER);

    let mut left_saw = 0.0;
    let mut right_saw = 0.0;

    let pa = try!(pa::PortAudio::new());

    let mut settings = try!(pa.default_output_stream_settings(CHANNELS, SAMPLE_RATE, FRAMES_PER_BUFFER));
    // we won't output out of range samples so don't bother clipping them.
    settings.flags = pa::stream_flags::CLIP_OFF;

    // This routine will be called by the PortAudio engine when audio is needed. It may called at
    // interrupt level on some machines so don't do anything that could mess up the system like
    // dynamic resource allocation or IO.
    let callback = move |pa::OutputStreamCallbackArgs { buffer, frames, .. }| {
        // any events to update the DSP with?? 
        match rx.try_recv() { 
          Ok(ke) => {
            match ke.evttype { 
              KeType::KeyHit => { 
                  // println!("setting vol to 0.3!");
                  unsafe { fraust_setval(volstring.as_ptr(), 0.3); }
                }
              KeType::KeyUnpress => { 
                  // println!("setting vol to 0.001!");
                  unsafe { fraust_setval(volstring.as_ptr(), 0.001); }
                }
              _ => {}
            }
          }
          _ => {}
        }

        if (frames * 2 > bufmax)
        {
          pa::Abort
        }
        else
        {
          // do dsp!
          let mut idx = 0;
          let mut ofidx = 0;

          // compute 'frames' number of samples.
          unsafe { fraust_compute(frames as i32, flts.as_mut_ptr(), outflts.as_mut_ptr()); }

          for _ in 0..frames {
              buffer[idx] = outflts[ofidx];
              idx += 1;
              buffer[idx] = outflts[ofidx];
              idx += 1;
              ofidx += 1;
          }
          pa::Continue
        }
    };

    let mut stream = try!(pa.open_non_blocking_stream(settings, callback));

    try!(stream.start());

    let oscrecvip = std::net::SocketAddr::from_str("0.0.0.0:8000").expect("Invalid IP");
    // spawn the osc receiver thread. 
    match oscthread(oscrecvip, tx) {
      Ok(s) => println!("oscthread exited ok"),
      Err(e) => println!("oscthread error: {} ", e),
    };

    /*
    loop {
      println!("Play for {} seconds.", NUM_SECONDS);
      pa.sleep(NUM_SECONDS * 1_000);
    }
    */

    try!(stream.stop());
    try!(stream.close());

    println!("its over!");

    Ok(())
}


fn oscthread(oscrecvip: SocketAddr, sender: mpsc::Sender<KeyEvt>) -> Result<String, Error> { 
  let socket = try!(UdpSocket::bind(oscrecvip));
  let mut buf = [0; 1000];

  loop { 
    let (amt, src) = try!(socket.recv_from(&mut buf));

    // println!("length: {}", amt);
    let inmsg = match osc::Message::deserialize(&buf[.. amt]) {
      Ok(m) => m,
      Err(e) => {
          return Err(Error::new(ErrorKind::Other, "oh no!"));
        },
      };

    // println!("message received {} {:?}", inmsg.path, inmsg.arguments );

    match inmsg {
      osc::Message { path: "keyh", arguments: ref args } => {
        let q = &args[0];
        let r = &args[1];
        // coming from the cyclophone, a is the key index and 
        // b is nominally 0.0 to 1.0
        match (q,r) {
          (&osc::Argument::i(idx), &osc::Argument::f(amt)) => {
              // build a keyevt to send over to the sound thread.
              let ke = KeyEvt{ evttype: KeType::KeyHit, keyindex: idx, position: amt };
              sender.send(ke)
              //Ok(0)
            },
          _ => { 
            // println!("ignore");
            Ok(())
          },
        }
      }
      osc::Message { path: "keye", arguments: ref args } => {
        let q = &args[0];
        let r = &args[1];
        // coming from the cyclophone, a is the key index and 
        // b is nominally 0.0 to 1.0
        match (q,r) {
          (&osc::Argument::i(idx), &osc::Argument::f(amt)) => {
              // build a keyevt to send over to the sound thread.
              let ke = KeyEvt{ evttype: KeType::KeyUnpress, keyindex: idx, position: amt };
              sender.send(ke)
              //Ok(0)
            },
          _ => { 
            // println!("ignore");
            Ok(())
          },
        }
      }
      /*
      osc::Message { path: "keye", arguments: ref args } => {
      }
      osc::Message { path: "keyc", arguments: ref args } => {
      },
      */
      _ => { // println!("ignore");
           Ok(()) } ,
      };
  };


  // drop(socket); // close the socket
  // Ok(String::from("meh"))
}

