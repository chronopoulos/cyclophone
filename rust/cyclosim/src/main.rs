
#[macro_use]
mod tryopt;
mod stringerror;

// use std::error;

use std::net::UdpSocket;
// use std::io::{Error,ErrorKind};
use std::string::String;
use std::env;
// use std::str::FromStr;
// use std::str;
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
              (&osc::Argument::s(_), &osc::Argument::f(amt), Some((path,Ok(idx)))) => {
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


