
#[macro_use]
mod tryopt;
mod stringerror;

// use std::error;
use std::thread;
use std::sync::{Arc, Mutex};
use std::collections::BTreeMap;

use std::net::UdpSocket;
use std::net::SocketAddr;
// use std::io::{Error,ErrorKind};
use std::string::String;
use std::fmt::format;
use std::env;
use std::sync::mpsc;
// use std::str::FromStr;
// use std::str;
use std::time::Duration;

use std::net::ToSocketAddrs;
extern crate tinyosc;
use tinyosc as osc;

// use std::error;
// use std::fmt::format;

fn main() {

  match rmain() {
    Ok(_) => println!("ok"),
    Err(e) => println!("error: {} ", e),
    }
}

enum KeType { 
  KeyPress,
  KeyMove,
  KeyUnpress
} 

pub struct KeyEvt { 
  evttype: KeType
, keyindex: i32
, position: f32
}

/*

option 1: map of index to keystate struct.
remove keystate from map when key goes inactive.
if map is empty, no scan is necessary.

option 2: array of keystates.  have to scan whole list to check state.
have to pass in key count.

*/

pub struct KeyState { 
  position: f32
, pressed: bool
}

fn sendkey(path: &str, index: i32, position: f32, oscsocket: &UdpSocket, oscsoundip: &SocketAddr) -> Result<(), Box<std::error::Error> >
{
  // send position messages for all keys in the map.
  let mut arghs = Vec::new();
  arghs.push(osc::Argument::i(index)); 
  arghs.push(osc::Argument::f(position)); 
  println!("sending {:?} {:?}", "keyp", arghs);
  let outmsg = osc::Message { path: "keyp", arguments: arghs };
  match outmsg.serialize() {
    Ok(v) => {
      try!(oscsocket.send_to(&v, oscsoundip));
      println!("sent {:?}", v);
      ()
    },
    Err(e) => return Err(Box::new(e)),
  }
  Ok(())
} 

// send an osc message to update the slider position in the gui.
fn sendkeygui(prefix: &str, index: i32, position: f32, oscsocket: &UdpSocket, oscguiip: &SocketAddr) -> Result<(), Box<std::error::Error> >
{
  // let pathh = format(format_args!("/0x00/Oscillator{}/volume", a));    
  let pathh = format(format_args!("{}{}", prefix, index));    
  // let pathh = format(format_args!("/Oscillator{}/meh", a));    
  let mut arghs = Vec::new();
  // arghs.push(osc::Argument::f(b * 100.0 - 100.0)); 
  arghs.push(osc::Argument::s("s_moved")); 
  arghs.push(osc::Argument::f(position)); 
  let outmsg = osc::Message { path: &pathh, arguments: arghs };
  match outmsg.serialize() {
    Ok(v) => {
      println!("sending {:?}", v);
      oscsocket.send_to(&v, oscguiip);
    },
    Err(e) => return Err(Box::new(e)),
  }

  Ok(())
} 


fn keythread( rx: mpsc::Receiver<KeyEvt>, 
              oscsoundip: SocketAddr,
              oscguiip: SocketAddr,
              oscsocket: UdpSocket)
              -> Result<String, Box<std::error::Error> >
{
  // listen for slider evts.   
  // loop, doing things to the sliders that are down.  
  // if no sliders are down just wait for a slider evt.

  let mut ks: BTreeMap<i32,KeyState> = BTreeMap::new();
  let interval = Duration::from_millis(500);
  let increment = 0.05;
  let mut delkeys: Vec<i32> = Vec::new();

  loop {
    let oke = 
      if ks.is_empty() {
        let ke = try!(rx.recv());
        Some(ke)
      }
      else {
        thread::sleep(interval); 
        let meh = rx.try_recv();
        match meh { 
          Ok(x) => Some(x), 
          Err(mpsc::TryRecvError::Empty) => None,
          Err(mpsc::TryRecvError::Disconnected) => return Ok("disconnected".to_string()), 
        }
      };
    match oke { 
      Some(ke) => 
        match ke.evttype { 
          KeType::KeyPress => {
            // new state entry.
            ks.insert(ke.keyindex, KeyState { position: ke.position, pressed: true }); 
            // send keyc message with new press.
            try!(sendkey("keyc", ke.keyindex.clone(), ke.position, &oscsocket, &oscsoundip));
          },
          KeType::KeyMove => {
            // replace the existing entry with an updated one.   
            ks.insert(ke.keyindex, KeyState { position: ke.position, pressed: true });
            ()
          },
          KeType::KeyUnpress => {
            println!("keyunpress {}", ke.keyindex);

            // change to pressed = false, and use new position too.  
            ks.insert(ke.keyindex, KeyState { position: ke.position, pressed: false });
            ()
          },
        },
      None => (),
    }

    // increment unpressed keys, send position update message to the gui.  
    for (key, value) in ks.iter_mut() {
      // if unpressed, increment the position towards 1.0.  
      if value.pressed == false { 
        value.position += increment;
        // once we reach 1.0, it goes on the delete list.
        if value.position >= 1.0 {
          value.position = 1.0;
          delkeys.push(key.clone());
        }
        sendkeygui("vs", key.clone(), value.position, &oscsocket, &oscguiip); 
      }
  
      try!(sendkey("keyp", key.clone(), value.position, &oscsocket, &oscsoundip));
    }

    // remove any keystates that were put in the delete list.
    for key in delkeys.iter() { 
      ks.remove(key);
    }
    delkeys.clear(); 

  }
  
}

fn rmain() -> Result<String, Box<std::error::Error> > { 
  let args = env::args();
  let mut iter = args.skip(1); // skip the program name
  
  let syntax = "syntax: \n cyclosim <recvip:port> <sendip:port>";

  let recvipstr = try_opt_resbox!(iter.next(), syntax);
  let sendipstr = try_opt_resbox!(iter.next(), syntax);

  let mut recvips = try!((&recvipstr).to_socket_addrs());
  let mut sendips = try!((&sendipstr).to_socket_addrs());

  let recvip = try_opt_resbox!(recvips.next(), "receive address is bad");
  let sendip = try_opt_resbox!(sendips.next(), "send address is bad");

  println!("recv addr: {:?}", recvip);
  println!("send addr: {:?}", sendip);

  let recvsocket = try!(UdpSocket::bind(recvip));
  let sendsocket = try!(UdpSocket::bind("0.0.0.0:0"));
  let mut buf = [0; 100];
  println!("cyclosim");

  // spawn key slider thread.
  let (tx, rx) = mpsc::channel();
  let ktss = try!(sendsocket.try_clone());

  thread::spawn(move || { 
    match keythread(rx, sendip, recvip, ktss) { 
      Err(e) => println!("keythread exited with error: {:?}", e),
      Ok(_) => (),
    }
  }); 

  loop { 
    let (amt, _) = try!(recvsocket.recv_from(&mut buf));

    println!("length: {}", amt);
    let inmsg = match osc::Message::deserialize(&buf[.. amt]) {
       Ok(m) => m,
       Err(()) => return Err(stringerror::stringBoxErr("OSC deserialize error")),
      };

    println!("message recieved {} {:?}", inmsg.path, inmsg.arguments );

    match inmsg {
      osc::Message { path: inpath, arguments: ref args } => {
        match args.len() {
         1 => {
            // probably a button event!
            let one = &args[0];
            let press = match one {
                          &osc::Argument::s("b_pressed") => Some(1), 
                          &osc::Argument::s("b_unpressed") => Some(0), 
                          _ => None
                          };
            
            let bi = 
              if inpath.starts_with("center") {
                let i = inpath[6..].parse::<i32>();
                Some(("switch", i))
              }
              else if inpath.starts_with("b") {
                let i = inpath[1..].parse::<i32>();
                Some(("button", i))
              }
              else {
                None
              };
    
            match (bi, press) { 
              (Some((butttype, Ok(index))), Some(p)) => {
                let mut arghs = Vec::new();
                arghs.push(osc::Argument::i(index)); 
                arghs.push(osc::Argument::i(p)); 
                println!("sending {:?} {:?}", butttype, arghs);
                let outmsg = osc::Message { path: &butttype, arguments: arghs };
                match outmsg.serialize() {
                  Ok(v) => {
                    try!(sendsocket.send_to(&v, sendip));
                    println!("sent {:?}", v);
                    ()
                  },
                  Err(e) => return Err(Box::new(e)),
                }
              },
              (a,b) => { 
                println!("ignore - blah {:?}", (a,b));
              },
            }
          },
         2 => {
            // probably a slider event!
            let meh = 
              if inpath.starts_with("hs") {
                let i = inpath[2..].parse::<i32>();
                Some(("knob", i))
              }
              else if inpath.starts_with("vs") {
                let i = inpath[2..].parse::<i32>();
                Some(("keyc", i))
              }
              else { None };

            let one = &args[0];
            let two = &args[1];
            
            match (one,two,meh) {
              (&osc::Argument::s(evtname), &osc::Argument::f(amt), Some((path,Ok(idx)))) => {
                let mut arghs = Vec::new();
                arghs.push(osc::Argument::i(idx));
                arghs.push(osc::Argument::f(amt)); 
                let outmsg = osc::Message { path: &path, arguments: arghs };
                match outmsg.serialize() {
                  Ok(v) => {
                    println!("sending {:?}", v);
                    try!(sendsocket.send_to(&v, sendip));
                    println!("sent {:?}", v);
                    ()
                  },
                  Err(e) => return Err(Box::new(e)),
                }
       
                // make a key update event and send to the keythread. 
                if let Some(et) = match evtname { "s_pressed" => Some(KeType::KeyPress), "s_moved" => Some(KeType::KeyMove), "s_unpressed" => Some(KeType::KeyUnpress), _ => None } 
                {
                  let ke = KeyEvt{evttype: et, keyindex: idx, position: amt};
                  tx.send(ke);
                }
              },
              _ => { 
                println!("ignore");
              },
            }
          }
        _ =>  
          {
             println!("ignore");
          }
        }
      }
    }
  }
}


