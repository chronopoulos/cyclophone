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

    let pa = try!(pa::PortAudio::new());

/*
    let mut settings = try!(pa.default_output_stream_settings(CHANNELS, SAMPLE_RATE, FRAMES_PER_BUFFER));
    // we won't output out of range samples so don't bother clipping them.
    settings.flags = pa::stream_flags::CLIP_OFF;
*/

    let id = pa::DeviceIndex(2);
    let params = pa::StreamParameters::<f32>::new(id, 2, true, 0.0);
    let mut settings = pa::OutputStreamSettings::new(params, SAMPLE_RATE, FRAMES_PER_BUFFER);
    settings.flags = pa::stream_flags::CLIP_OFF;

    printPaDev(id, &pa);


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

        if frames * 2 > bufmax
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

const INTERLEAVED: bool = true;
const LATENCY: pa::Time = 0.0; // Ignored by PortAudio::is_*_format_supported.
const STANDARD_SAMPLE_RATES: [f64; 13] = [
    8000.0, 9600.0, 11025.0, 12000.0, 16000.0, 22050.0, 24000.0, 32000.0,
    44100.0, 48000.0, 88200.0, 96000.0, 192000.0,
];

fn printPaDev(idx: pa::DeviceIndex, pado: &pa::PortAudio) -> Result<(), pa::Error> {
  let info = try!(pado.device_info(idx));
  println!("--------------------------------------- {:?}", idx);
  println!("{:#?}", &info);

  let in_channels = info.max_input_channels;
  let input_params = 
    pa::StreamParameters::<i16>::new(idx, in_channels, INTERLEAVED, LATENCY);
  let out_channels = info.max_output_channels;
  let output_params = 
    pa::StreamParameters::<i16>::new(idx, out_channels, INTERLEAVED, LATENCY);

  println!("Supported standard sample rates for half-duplex 16-bit {} channel input:", 
    in_channels);
  for &sample_rate in &STANDARD_SAMPLE_RATES {
    if pado.is_input_format_supported(input_params, sample_rate).is_ok() {
        println!("\t{}hz", sample_rate);
    }
  }

  println!("Supported standard sample rates for half-duplex 16-bit {} channel output:", 
    out_channels);
  for &sample_rate in &STANDARD_SAMPLE_RATES {
    if pado.is_output_format_supported(output_params, sample_rate).is_ok() {
        println!("\t{}hz", sample_rate);
    }
  }

  println!("Supported standard sample rates for full-duplex 16-bit {} channel input, {} channel output:",
     in_channels, out_channels);
  for &sample_rate in &STANDARD_SAMPLE_RATES {
    if pado.is_duplex_format_supported(input_params, output_params, sample_rate).is_ok() {
        println!("\t{}hz", sample_rate);
    }
  }

  Ok(())
}

