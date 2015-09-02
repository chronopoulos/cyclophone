use std::net::UdpSocket;
use std::io::{Error,ErrorKind};
use std::string::String;

extern crate tinyosc;
use tinyosc as osc;


fn main() {

  match rmain() {
    Ok(s) => println!("ok"),
    Err(e) => println!("error: {} ", e),
    }
}

fn rmain() -> Result<String, Error> { 
  let mut socket = try!(UdpSocket::bind("127.0.0.1:34254"));
  let mut buf = [0; 100];
  while true {
    let (amt, src) = try!(socket.recv_from(&mut buf));

    println!("length: {}", amt);
    let inmsg = match osc::Message::deserialize(&buf[.. amt]) {
      Ok(m) => m,
      Err(e) => {
          return Err(Error::new(ErrorKind::Other, "oh no!"));
          //return Error(String::from(" :: couldn't decode OSC message :c"));
          // return;
        },
      };

    println!("message recieved {} {:?}", inmsg.path, inmsg.arguments );

    match inmsg {
      osc::Message { path: "keyc", arguments: ref args } => {
          println!("mah args: {:?} ", args);
          match inmsg.serialize() {
           Ok(v) => socket.send_to(&v, "127.0.0.1:34255"),
           Err(e) => return Err(Error::new(ErrorKind::Other, "oh no!")),
            }
        },
      _ => { println!("ignore");
           Ok(0) } ,
      };
  };


  drop(socket); // close the socket
  Ok(String::from("meh"))
}

