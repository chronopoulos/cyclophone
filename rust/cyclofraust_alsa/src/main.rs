extern crate libc;

use std::ffi::CString;
use std::net::UdpSocket;
use std::net::SocketAddr;
use std::io::{Error,ErrorKind};
use std::string::String;
use std::fmt::format;
use std::time::Duration;
use std::sync::mpsc;
use std::thread;
use std::str::FromStr;
use std::cmp::min;

extern crate alsa;
use alsa::Direction;
use alsa::ValueOr;
use alsa::pcm::{PCM, HwParams, Format, Access};

type Sample = f32;

extern crate tinyosc;
use tinyosc as osc;

extern {
  pub fn fraust_init(samplerate: i32);
  pub fn fraust_compute(count: i32, input: *const libc::c_float, output: *mut libc::c_float );
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
const SAMPLE_RATE: f64 = 44100.0;
const FRAMES_PER_BUFFER: u32 = 64;
// const FRAMES_PER_BUFFER: u32 = 2048;

fn main() {
    run().unwrap()
}


fn run() -> Result<(), Box<std::error::Error> > {


    // ---------------------------------------------
    // make a channel to receive updates from the osc.

    let (tx, rx) = mpsc::channel::<KeyEvt>();

    // ---------------------------------------------
    // init fraust 
    // ---------------------------------------------
    println!("initting with sample rate: {}", SAMPLE_RATE);

    unsafe { fraust_init(SAMPLE_RATE as i32); }

    let bufmax = 10000;
    let mut inflts = [0.0;10000];
    inflts[0] = 1.0;

    let mut outflts = [0.0;10000];
    // let mut outflts = [0.0;bufmax];

    let volstring = CString::new("Volume").unwrap();

    unsafe { fraust_setval(volstring.as_ptr(), 0.05); }

    // let mut loopcount = 0;
    // let mut buflen = 0;
    // let bufmaxu = bufmax as usize;
    // let mut bufidx = bufmaxu - 1;

    // make a full buffer to begin with.
    // unsafe { fraust_compute(bufmax, flts.as_mut_ptr(), outflts.as_mut_ptr()); }

    // ---------------------------------------------
    // init alsa 
    // ---------------------------------------------

    /*
    let config = default_config();
    let mut phases: Vec<Phase> = (*config.pitches).iter().map(|&p| phase(&config, p)).collect();
    phases.sort();
    let phases = phases;

    let phase_min = phases[0];
    let phase_max = phases[phases.len()-1];
    let sample_rate = config.sample_rate;
    let samples = phase_max * 2;

    let mut backing_vector: Vec<Sample> = Vec::with_capacity(samples);
    // Should probably use Vec::from_elem(samples, 0) but that is not in stable yet
    unsafe { backing_vector.set_len(samples); }
    let mut data = &mut backing_vector[..];
    */

    // input, output buffers.
    // let sample_count = 10000;
    // let sample_count = 1000;
    // let sample_count = 959;
    let sample_count = 16;
    // let sample_count = 900;
    let sample_rate = 44100;
    let mut input_vector: Vec<Sample> = Vec::with_capacity(sample_count);
    // Should probably use Vec::from_elem(samples, 0) but that is not in stable yet
    unsafe { input_vector.set_len(sample_count); }
    let mut inputdata = &mut input_vector[..];

    let mut output_vector: Vec<Sample> = Vec::with_capacity(sample_count);
    // Should probably use Vec::from_elem(sample_count, 0) but that is not in stable yet
    unsafe { output_vector.set_len(sample_count); }
    let mut outputdata = &mut output_vector[..];

     
    let default = CString::new("default").unwrap();
    let nonblock = false; 
    /*
    let pcm_in = PCM::open(&*default, Direction::Capture, nonblock).unwrap();
    {
      let hwp = HwParams::any(&pcm_in).unwrap();
      hwp.set_channels(1).unwrap();
      hwp.set_rate(sample_rate, ValueOr::Nearest).unwrap();
      hwp.set_format(Format::float()).unwrap();
      hwp.set_access(Access::RWInterleaved).unwrap();
      pcm_in.hw_params(&hwp).unwrap();
    }
    let io_in = pcm_in.io_f32().unwrap();
    pcm_in.prepare().unwrap();
    */

    let pcm_out = PCM::open(&*default, Direction::Playback, nonblock).unwrap();
    {
      let hwp = HwParams::any(&pcm_out).unwrap();
      hwp.set_rate_near(sample_rate, ValueOr::Nearest).unwrap();
      hwp.set_buffer_size_near(1024).unwrap();
      hwp.set_period_size_near(64,ValueOr::Nearest).unwrap();
      hwp.set_channels(2).unwrap();
      hwp.set_format(Format::float()).unwrap();
      hwp.set_access(Access::RWInterleaved).unwrap();
      pcm_out.hw_params(&hwp).unwrap();
    }
    let io_out = pcm_out.io_f32().unwrap();
    pcm_out.prepare().unwrap();

    match pcm_out.hw_params_current() {
      Ok(params) => println!("hwparams: {:?}", params),
      _ => println!("failed to get params"),
    }
   
    // println!("fraust compute!"); 
    // unsafe { fraust_compute(sample_count as i32, inflts.as_ptr(), outflts.as_mut_ptr()); }

    // copy vals into output array.
    let mut idx = 0;
    for _ in 0..sample_count {
        outputdata[idx] = outflts[idx];
        idx += 1;
    }
    
    //println!("instate: {:?}", pcm_in.state());
    println!("outstate: {:?}", pcm_out.state());

    let oscrecvip = std::net::SocketAddr::from_str("0.0.0.0:8000").expect("Invalid IP");
    // spawn the osc receiver thread. 
    thread::spawn(move || {
      match oscthread(oscrecvip, tx) {
        Ok(s) => println!("oscthread exited ok"),
        Err(e) => println!("oscthread error: {} ", e),
      }
    });

    let mut iters = 0;

    loop {
      // let samps = try!(io_in.readi(&mut inputdata));
      // try!(io_in.readi(&mut inputdata));
      // println!("instate: {:?}", pcm_in.state());
      // println!("outstate: {:?}", pcm_out.state());

      // any events to update the DSP with?? 
      match rx.try_recv() { 
        Ok(ke) => {
          println!("message");
          match ke.evttype { 
            KeType::KeyHit => { 
                println!("setting vol to 0.3!");
                unsafe { fraust_setval(volstring.as_ptr(), 0.3); }
              }
            KeType::KeyUnpress => { 
                println!("setting vol to 0.001!");
                unsafe { fraust_setval(volstring.as_ptr(), 0.001); }
              }
            _ => {}
          }
        }
        _ => {}
      }

      iters = iters + 1;
      // println!("fraust compute! {}", iters); 
      unsafe { fraust_compute(sample_count as i32, inflts.as_ptr(), outflts.as_mut_ptr()); }
      let mut idx = 0;
      for _ in 0..sample_count {
          outputdata[idx] = outflts[idx];
          idx += 1;
      }
      // println!("copied {} samples", idx);
      
      // std::thread::sleep(Duration::from_millis(10));
      try!(io_out.writei(outputdata));
    
    }

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


