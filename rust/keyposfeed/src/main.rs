
#[macro_use]
mod tryopt;
mod stringerror;

use std::net::UdpSocket;
use std::io::{Error,ErrorKind};
use std::string::String;
use std::env;

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
  
  let syntax = "syntax: \n keyposfeed <recvip:port> <sendip:port>";

  let recvip = try_opt_resbox!(iter.next(), syntax);
  let sendip = try_opt_resbox!(iter.next(), syntax);

  let socket = try!(UdpSocket::bind(&recvip[..]));
  let mut buf = [0; 100];
  println!("keyposfeed");

  loop { 
    let (amt, src) = try!(socket.recv_from(&mut buf));

    println!("length: {}", amt);
    let inmsg = match osc::Message::deserialize(&buf[.. amt]) {
       Ok(m) => m,
       Err(e) => return Err(stringerror::stringBoxErr("OSC deserialize error")),
      };

    println!("message recieved {} {:?}", inmsg.path, inmsg.arguments );

    match inmsg {
      osc::Message { path: "keyc", arguments: ref args } => {
        if args.len() == 2 
          {
            let q = &args[0];
            let r = &args[1];
       
            // coming from the cyclophone, a is the key index and 
            // b is nominally 0.0 to 1.0
 
            match (q,r) {
              (&osc::Argument::i(a), &osc::Argument::f(b)) => {
                  // let pathh = format(format_args!("/0x00/Oscillator{}/volume", a));    
                  let pathh = format(format_args!("vs{}", a));    
                  // let pathh = format(format_args!("/Oscillator{}/meh", a));    
                  let mut arghs = Vec::new();
                  // arghs.push(osc::Argument::f(b * 100.0 - 100.0)); 
                  arghs.push(osc::Argument::s("s_moved")); 
                  arghs.push(osc::Argument::f(b)); 
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
                // return Err(Error::new(ErrorKind::Other, "unexpected osc args!"));
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
  };


  // drop(socket); // close the socket
  // Ok(String::from("meh"))
}

