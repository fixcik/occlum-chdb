extern crate libc;

use std::ffi::{CStr, CString};
use std::os::raw::c_char;

#[derive(Debug, Clone, Copy)]
#[repr(C)]
pub struct LocalResult {
    buf: *mut c_char,
    len: usize,
    vec: *mut c_char,
    elapsed: f64,
    rows_read: u64,
    bytes_read: u64,
}

#[link(name = "chdb")]
extern "C" {
    fn query_stable(argc: i32, argv: *const *const c_char) -> *mut LocalResult;
}

pub fn execute(query: &str, format: &str) -> Option<String> {
    let mut argv: [*const c_char; 6] = [
        CString::new("clickhouse").unwrap().into_raw(),
        CString::new("--multiquery").unwrap().into_raw(),
        // CString::new("--max_threads=16").unwrap().into_raw(),
        CString::new("--verbose").unwrap().into_raw(),
        CString::new("--log-level=trace").unwrap().into_raw(),
        CString::new("--output-format=CSV").unwrap().into_raw(),
        CString::new("--query=").unwrap().into_raw(),
    ];

    let data_format = format!("--format={}", format);
    argv[4] = CString::new(data_format).unwrap().into_raw();

    let local_query = format!("--query={}", query);
    argv[5] = CString::new(local_query).unwrap().into_raw();

    let result = unsafe { query_stable(6, argv.as_ptr()) };

    unsafe {
        drop(CString::from_raw(argv[4] as *mut c_char));
        drop(CString::from_raw(argv[5] as *mut c_char));
    }

    if result.is_null() {
        return None;
    }

    let c_str = unsafe { CStr::from_ptr((*result).buf) };
    let output = c_str.to_string_lossy().into_owned();

    Some(output)
}
