use std::net::UdpSocket;
use std::io::{Error,ErrorKind};
use std::string::String;

extern crate tinyosc;
use tinyosc as osc;

use std::fmt::format;

fn main() {

  match rmain() {
    Ok(s) => println!("ok"),
    Err(e) => println!("error: {} ", e),
    }
}

fn rmain() -> Result<String, Error> { 
  // let socket = try!(UdpSocket::bind("192.168.8.214:8000"));
  let socket = try!(UdpSocket::bind("127.0.0.1:8000"));
  let mut buf = [0; 100];
  println!("cyclopass");

  loop { 
    let (amt, src) = try!(socket.recv_from(&mut buf));

    println!("length: {}", amt);
    let inmsg = match osc::Message::deserialize(&buf[.. amt]) {
      Ok(m) => m,
      Err(e) => {
          return Err(Error::new(ErrorKind::Other, "oh no!"));
        },
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
                  let pathh = format(format_args!("/0x00/Oscillator{}/meh", a));    
                  // let pathh = format(format_args!("/Oscillator{}/meh", a));    
                  let mut arghs = Vec::new();
                  // arghs.push(osc::Argument::f(b * 100.0 - 100.0)); 
                  arghs.push(osc::Argument::f(b)); 
                  let outmsg = osc::Message { path: &pathh, arguments: arghs };
                  match outmsg.serialize() {
                    Ok(v) => {
                      println!("sending {:?}", v);
              			  socket.send_to(&v, "127.0.0.1:5510")
                    },
                    Err(e) => return Err(Error::new(ErrorKind::Other, "oh no!")),
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
      _ => { println!("ignore");
           Ok(0) } ,
      };
  };


  // drop(socket); // close the socket
  // Ok(String::from("meh"))
}

