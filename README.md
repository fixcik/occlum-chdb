I try to run [chdb](https://github.com/metrico/libchdb) in occlum


# Build

`docker build . -t occlum-sample`

# Run

`docker run --rm --privileged -v /var/run/aesmd/aesm.socket:/var/run/aesmd/aesm.socket occlum-sample`

I catch this error:

```
thread '<unnamed>' panicked at 'called `Result::unwrap()` on an `Err` value: Error { inner: Embedded((EINVAL, "invalid start or end")), location: Some(ErrorLocation { line: 12, file: "src/vm/vm_range.rs" }), cause: None }', src/vm/vm_manager.rs:872:80
stack backtrace:
   0: rust_begin_unwind
   1: core::panicking::panic_fmt
             at library/core/src/panicking.rs:142
   2: core::result::unwrap_failed
             at library/core/src/result.rs:1749
   3: occlum_libos_core_rs::vm::vm_manager::InternalVMManager::mprotect_single_vma_chunk
   4: occlum_libos_core_rs::vm::vm_manager::VMManager::mprotect
   5: occlum_libos_core_rs::vm::do_mprotect
   6: occlum_libos_core_rs::syscall::do_mprotect
   7: occlum_libos_core_rs::syscall::do_syscall
   8: occlum_syscall
   9: <unknown>
note: Some details are omitted, call backtrace::enable_backtrace() with 'PrintFormat::Full' for a verbose backtrace.
fatal runtime error: failed to initiate panic, error 5
/opt/occlum/build/bin/occlum: line 455:    24 Illegal instruction     (core dumped) RUST_BACKTRACE=1 "$instance_dir/build/bin/occlum-run" "$@"
```