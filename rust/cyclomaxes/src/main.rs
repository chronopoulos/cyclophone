use std::net::UdpSocket;
use std::io::{Error,ErrorKind};
use std::string::String;
use std::collections::BTreeMap;

use std::fs::File;
use std::io::Write;

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
  let socket = try!(UdpSocket::bind("0.0.0.0:8000"));
  let mut buf = [0; 100];
  println!("cyclomaxes");

  let mut maxmap : BTreeMap<i32,f32>  = BTreeMap::new();

  loop { 
    let (amt, src) = try!(socket.recv_from(&mut buf));

    // println!("length: {}", amt);
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
       
            // coming from the cyclophone, arg 0 is the key index and 
            // arg 1 is the key position.
 
            match (q,r) {
              (&osc::Argument::i(keyindex), &osc::Argument::f(keypos)) => {
                let v = maxmap.entry(keyindex).or_insert(keypos);
                if keypos > *v {
                  *v = keypos;
                };

              },
              _ => { 
                println!("ignore");
                // return Err(Error::new(ErrorKind::Other, "unexpected osc args!"));
                // Ok(0)
              },
            }
          }
        else
          {
             println!("ignore");
             // Ok(0)    
          }
        },
      osc::Message { path: "button", arguments: ref args } => {
        // write the array out to a file.
        match File::create("maxes.map") {
          Ok(mut file) => { 
            write!(file, "{:?}", maxmap);
            println!("wrote to maxes.txt");
          },
          _ => println!("unable to write maxes.txt file!"), 
        };
        // write the array out to a file.
        match File::create("maxes.array") {
          Ok(mut file) => {
            for v in maxmap.values() 
            { 
              write!(file, "{}\n", v);
            }
            println!("wrote to maxes.array");
          },
          _ => println!("unable to write maxes.array file!"), 
        };
      }
      _ => { println!("ignore");
           // Ok(0) 
      },
      };
  };

}

