// #![feature(step_by)]
extern crate cpal;
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

extern crate tinyosc;
use tinyosc as osc;

// use libc;

//mod blah {
// #[link(name = "minimal", kind = "static")]
extern {
  // fn fraust_init(samplerate: libc::c_int);
  pub fn fraust_init(samplerate: i32);
  pub fn fraust_compute(count: i32, input: *mut libc::c_float, output: *mut libc::c_float );
  pub fn fraust_setval(label: *const libc::c_char , val: libc::c_float); 
}
//}


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

/*
fn sosafe(count: usize, mut input: &[f32], mut output: &[f32]) { 
  let cnt = min( count, min(input.len(), output.len()));

  unsafe { fraust_compute(cnt as i32, input.as_mut_ptr(), output.as_mut_ptr()); }

}
*/

fn main() {

    // make a channel to receive updates from the osc.
    let (tx, rx) = mpsc::channel::<KeyEvt>();

    // let oscrecvip: SocketAddr = std::net::SocketAddr::from_str("0.0.0.0:8000");
    // let oscrecvip = std::net::SocketAddr::from_str::<SocketAddr>("127.0.0.1:8080").unwrap();
    let oscrecvip = std::net::SocketAddr::from_str("0.0.0.0:8000").expect("Invalid IP");
    // spawn the osc receiver thread. 
    thread::spawn(move || { 
      match oscthread(oscrecvip, tx) {
        Ok(s) => println!("oscthread exited ok"),
        Err(e) => println!("oscthread error: {} ", e),
      }
    });
     // let oscrecvip: SocketAddr = from_str("0.0.0.0:8000").expect("Invalid IP");
    /*
    match std::net::SocketAddr::from_str("0.0.0.0:8000") { 
      Ok(oscrecvip) => {
        // spawn the osc receiver thread. 
        thread::spawn(move || { 
          match oscthread(oscrecvip, tx) {
            Ok(s) => println!("oscthread exited ok"),
            Err(e) => println!("oscthread error: {} ", e),
          }
        });
      }
      Err(e) => { 
        println!("error");
      } 
    }
    // let oscrecvip: SocketAddr = 
    */


    let endpoint = cpal::get_default_endpoint().expect("Failed to get default endpoint");
    // let format = endpoint.get_supported_formats_list().unwrap().nth(200).expect("Failed to get endpoint format");
    let format = endpoint.get_supported_formats_list().unwrap().nth(500).expect("Failed to get endpoint format");
    let mut voice = cpal::Voice::new(&endpoint, &format).expect("Failed to create a channel");

    // Produce a sinusoid of maximum amplitude.
    // let mut data_source = (0u64..).map(|t| t as f32 * 440.0 * 2.0 * 3.141592 / format.samples_rate.0 as f32);     // 440 Hz
    // let mut data_source = (0u64..).map(|t| t as f32 * 220.0 * 2.0 * 3.141592 / format.samples_rate.0 as f32)     // 440 Hz
    //                              .map(|t| t.sin());

    println!("initting with sample rate: {}", format.samples_rate.0);

    unsafe { fraust_init(format.samples_rate.0 as i32); }

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

    let mut sampcount = 0;

    loop {
        // println!("loope {}", count);
        loopcount = loopcount + 1;
        // get key events.
        match rx.try_recv() { 
          Ok(ke) => {
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

        match voice.append_data(bufmaxu) {
            cpal::UnknownTypeBuffer::U16(mut buffer) => {
                println!("blah I'm here U16");
                for (sample, value) in buffer.chunks_mut(format.channels.len()).zip(&mut outflts.iter()) {
                    println!("len: {}", format.channels.len());
                    let value = ((value * 0.5 + 0.5) * std::u16::MAX as f32) as u16;
                    // make all values the same in each channel.
                    for out in sample.iter_mut() { *out = value; }
                }
            },

            cpal::UnknownTypeBuffer::I16(mut buffer) => {
                println!("blah I'm here I16");
                for (sample, value) in buffer.chunks_mut(format.channels.len()).zip(&mut outflts.iter()) {
                    let value = (value * std::i16::MAX as f32) as i16;
                    for out in sample.iter_mut() { *out = value; }
                }
            },

            cpal::UnknownTypeBuffer::F32(mut buffer) => {
              // point outflts.iter() at the 'bufstart'.
              // copy vals until the buffer is done, then refresh it.
              for sample in buffer.chunks_mut(format.channels.len())
                {
                  // copy an output value to all the channels.
                  for out in sample.iter_mut() 
                  { 
                    sampcount = sampcount + 1; 
                    *out = outflts[bufidx];
                  }
  
                  bufidx = bufidx + 1;
                  if bufidx == bufmaxu
                  {
                    println!("makin samples! sampcount: {}, bufidx: {}", sampcount, bufidx);
                    unsafe { fraust_compute(bufmax, flts.as_mut_ptr(), outflts.as_mut_ptr()); }
                    bufidx = 0;
                  }
                }
              /*
              for (sample, value) in 
                buffer.chunks_mut(format.channels.len()).zip(&mut outflts.iter()) 
                {
                    for out in sample.iter_mut() { sampcount = sampcount + 1; *out = *value; }
                }
              */
            },
        }

        voice.play();
        
        // println!("sampcount: {}", sampcount);
        // println!("sampcount / chans: {}", sampcount / format.channels.len());
    }
}

/*
fn oscthread(oscrecvip: SocketAddr, sender: mpsc::Sender<KeyEvt>) { 

  match oscthread_forreals(oscrecvip, sender) {
    Ok(s) => println!("oscthread exited ok"),
    Err(e) => println!("oscthread error: {} ", e),
    }
}
*/

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

