use std::net::UdpSocket;
use std::io::{Error,ErrorKind};
use std::string::String;

extern crate tinyosc;
use tinyosc as osc;


fn main() {

  match (rmain()) {
    Ok(s) => println!("ok"),
    Err(e) => println!("error: {} ", e),
    }
}

fn rmain() -> Result<String, Error> { 
  let mut socket = try!(UdpSocket::bind("127.0.0.1:34254"));
  let mut buf = [0; 100];
  let (amt, src) = try!(socket.recv_from(&mut buf));

  // Send a reply to the socket we received data from
  // println!("message received: {:?}", buf);
  println!("length: {}", amt);
  let omsg = match osc::Message::deserialize(&buf[.. amt]) {
    Ok(m) => m,
    Err(e) => {
        return Err(Error::new(ErrorKind::Other, "oh no!"));
        //return Error(String::from(" :: couldn't decode OSC message :c"));
        // return;
      },
    };

  // let buf = &mut buf[..amt];
  // buf.reverse();
  // try!(socket.send_to(buf, &src));

  println!("blaha {} ", omsg.path );

  drop(socket); // close the socket
  Ok(String::from("meh"))
}

