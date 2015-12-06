
#[macro_use]
mod tryopt;
mod stringerror;

use std::net::UdpSocket;
use std::io::{Error,ErrorKind};
use std::string::String;
use std::env;
use std::str::FromStr;
use std::str;

extern crate tinyosc;
use tinyosc as osc;


use std::fmt::format;

fn main() {

  match rmain() {
    Ok(s) => println!("ok"),
    Err(e) => println!("error: {} ", e),
    }
}

fn rmain() -> Result<String, Box<std::error::Error> > { 
  let args = env::args();
  let mut iter = args.skip(1); // skip the program name
  
  let syntax = "syntax: \n cyclosim <recvip:port> <sendip:port>";

  let recvip = try_opt_resbox!(iter.next(), syntax);
  let sendip = try_opt_resbox!(iter.next(), syntax);

  let socket = try!(UdpSocket::bind(&recvip[..]));
  let mut buf = [0; 100];
  println!("cyclosim");

  loop { 
    let (amt, src) = try!(socket.recv_from(&mut buf));

    println!("length: {}", amt);
    let inmsg = match osc::Message::deserialize(&buf[.. amt]) {
       Ok(m) => m,
       Err(e) => return Err(stringerror::stringBoxErr("OSC deserialize error")),
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
                let outmsg = osc::Message { path: &butttype, arguments: arghs };
                match outmsg.serialize() {
                  Ok(v) => {
                    println!("sending {:?}", v);
                    socket.send_to(&v, &sendip[..]);
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

            // probably a slider event!
            let one = &args[0];
            let two = &args[1];
            
            match (one,two,meh) {
              (&osc::Argument::s(evt), &osc::Argument::f(amt), Some((path,Ok(idx)))) => {
                let mut arghs = Vec::new();
                arghs.push(osc::Argument::i(idx));
                arghs.push(osc::Argument::f(amt)); 
                let outmsg = osc::Message { path: &path, arguments: arghs };
                match outmsg.serialize() {
                  Ok(v) => {
                    println!("sending {:?}", v);
                    socket.send_to(&v, &sendip[..]);
                    ()
                  },
                  Err(e) => return Err(Box::new(e)),
                }
              },
              _ => { 
                println!("ignore");
                // return Err(Error::new(ErrorKind::Other, "unexpected osc args!"));
                // Ok(0)
              },
            }
          }
        _ =>  
          {
             println!("ignore");
             // Ok(0)    
          }
        }
      }
    }
  }
}

      /* ,
      osc::Message { path: "switch", arguments: ref args } => {
        if args.len() == 1 
          {
            let idx = &args[0];  // knob index
      
            println!("switch {:?}", idx);
 
            match idx {
              &osc::Argument::i(idx) => {
                for i in 0..5 {
                  println!("switch {}, {}", i, idx);
                  let pathh = format(format_args!("center{}", i));    
                  let mut arghs = Vec::new();
                  if i == idx {
                    arghs.push(osc::Argument::s("b_pressed")); 
                  }
                  else {
                    arghs.push(osc::Argument::s("b_unpressed")); 
                  }

                  let outmsg = osc::Message { path: &pathh, arguments: arghs };
                  match outmsg.serialize() {
                    Ok(v) => {
                      println!("sending {:?}, {:?}", pathh, args);
                      socket.send_to(&v, &sendip[..]);
                      ()
                    },
                    Err(e) => return Err(Box::new(e)),
                  }
                };
              
                Ok(0)
              },
              _ => { 
                println!("ignore");
                Ok(0)
              },
            }
          }
        else
          {
             println!("ignore");
             Ok(0)    
          }
        },
      osc::Message { path: "knob", arguments: ref args } => {
        if args.len() == 2 
          {
            let idx = &args[0];  // knob index
            let val = &args[1];  // knob value
       
            match (idx,val) {
              (&osc::Argument::i(idx), &osc::Argument::f(val)) => {
                  let pathh = format(format_args!("hs{}", idx));    
                  let mut arghs = Vec::new();
                  // arghs.push(osc::Argument::f(b * 100.0 - 100.0)); 
                  arghs.push(osc::Argument::s("s_moved")); 
                  arghs.push(osc::Argument::f(val)); 
                  let outmsg = osc::Message { path: &pathh, arguments: arghs };
                  match outmsg.serialize() {
                    Ok(v) => {
                      println!("sending {:?}", v);
              			  socket.send_to(&v, &sendip[..])
                    },
                    Err(e) => return Err(Box::new(e)),
                  }
                },
              _ => { 
                println!("ignore");
                Ok(0)
              },
            }
          }
        else
          {
             println!("ignore");
             Ok(0)    
          }
        },
      osc::Message { path: "button", arguments: ref args } => {
        if args.len() == 2 
          {
            let idx = &args[0];  // button index
            let val = &args[1];  // button state
       
            match (idx,val) {
              (&osc::Argument::i(idx), &osc::Argument::i(val)) => {
                  let pathh = format(format_args!("b{}", idx));    
                  let mut arghs = Vec::new();
                  // arghs.push(osc::Argument::f(b * 100.0 - 100.0)); 
                  if val == 1 {
                    arghs.push(osc::Argument::s("b_pressed")); 
                  } else {
                    arghs.push(osc::Argument::s("b_unpressed"));
                  } 
                  let outmsg = osc::Message { path: &pathh, arguments: arghs };
                  match outmsg.serialize() {
                    Ok(v) => {
                      println!("sending {:?}", v);
              			  socket.send_to(&v, &sendip[..])
                    },
                    Err(e) => return Err(Box::new(e)),
                  }
                },
              _ => { 
                println!("ignore");
                Ok(0)
              },
            }
          }
        else
          {
             println!("ignore");
             Ok(0)    
          }
        },
      _ => { println!("ignore");
           Ok(0) } ,
      };
      */


