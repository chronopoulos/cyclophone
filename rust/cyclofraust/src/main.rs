// #![feature(step_by)]
extern crate cpal;
extern crate libc;
use std::ffi::CString;
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




fn main() {

    /*
    unsafe { fraust_init(44100); }

    let mut flts = [0.0;500];
    flts[0] = 1.0;
    
    let mut outflts = [0.0;500];

    unsafe { fraust_compute(500, flts.as_mut_ptr(), outflts.as_mut_ptr()); }

    for f in outflts.iter()
    {
      println!("{}", f);
    }
    */ 

    /*
    for i in (0u8..).step_by(2) {
        println!("{}", i);
    }
    */
    // println!("64thign: {}", (0u64..));

    let endpoint = cpal::get_default_endpoint().expect("Failed to get default endpoint");
    // let format = endpoint.get_supported_formats_list().unwrap().next().expect("Failed to get endpoint format");
    let format = endpoint.get_supported_formats_list().unwrap().nth(200).expect("Failed to get endpoint format");
    let mut voice = cpal::Voice::new(&endpoint, &format).expect("Failed to create a channel");

    // Produce a sinusoid of maximum amplitude.
    // let mut data_source = (0u64..).map(|t| t as f32 * 440.0 * 2.0 * 3.141592 / format.samples_rate.0 as f32);     // 440 Hz
    // let mut data_source = (0u64..).map(|t| t as f32 * 220.0 * 2.0 * 3.141592 / format.samples_rate.0 as f32)     // 440 Hz
    //                              .map(|t| t.sin());

    println!("initting with sample rate: {}", format.samples_rate.0);

    unsafe { fraust_init(format.samples_rate.0 as i32); }

    let mut flts = [0.0;5000];
    flts[0] = 1.0;
    
    let mut outflts = [0.0;5000];

    let volstring = CString::new("Volume").unwrap();

    unsafe { fraust_setval(volstring.as_ptr(), 0.05); }

    loop {
        unsafe { fraust_compute(5000, flts.as_mut_ptr(), outflts.as_mut_ptr()); }

        match voice.append_data(5000) {
            cpal::UnknownTypeBuffer::U16(mut buffer) => {
                for (sample, value) in buffer.chunks_mut(format.channels.len()).zip(&mut outflts.iter()) {
                    let value = ((value * 0.5 + 0.5) * std::u16::MAX as f32) as u16;
                    // make all values the same in each channel.
                    for out in sample.iter_mut() { *out = value; }
                }
            },

            cpal::UnknownTypeBuffer::I16(mut buffer) => {
                for (sample, value) in buffer.chunks_mut(format.channels.len()).zip(&mut outflts.iter()) {
                    let value = (value * std::i16::MAX as f32) as i16;
                    for out in sample.iter_mut() { *out = value; }
                }
            },

            cpal::UnknownTypeBuffer::F32(mut buffer) => {
                for (sample, value) in buffer.chunks_mut(format.channels.len()).zip(&mut outflts.iter()) {
                    for out in sample.iter_mut() { *out = *value; }
                }
            },
        }

        voice.play();
    }
}

