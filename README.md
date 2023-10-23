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

Errors like
```
Code: 412. DB::ErrnoException: Cannot do 'capget' syscall, errno: 38, strerror: Function not implemented. (NETLINK_ERROR), Stack trace (when copying this message, always include the lines below):

0. Poco::Exception::Exception(String const&, int) @ 0x00000000189cfd1a in /opt/occlum/glibc/lib/libchdb.so
1. DB::Exception::Exception(DB::Exception::MessageMasked&&, int, bool) @ 0x0000000010434a95 in /opt/occlum/glibc/lib/libchdb.so
2. DB::ErrnoException::ErrnoException(String const&, int, int, std::optional<String> const&) @ 0x00000000104395f3 in /opt/occlum/glibc/lib/libchdb.so
3. DB::throwFromErrno(String const&, int, int) @ 0x00000000104354fa in /opt/occlum/glibc/lib/libchdb.so
4. ? @ 0x000000001047d063 in /opt/occlum/glibc/lib/libchdb.so
5. DB::hasLinuxCapability(int) @ 0x000000001047cf91 in /opt/occlum/glibc/lib/libchdb.so
6. ? @ 0x000000001046f694 in /opt/occlum/glibc/lib/libchdb.so
7. DB::TaskStatsInfoGetter::checkPermissions() @ 0x000000001046f5ea in /opt/occlum/glibc/lib/libchdb.so
8. DB::TasksStatsCounters::create(unsigned long) @ 0x000000001046981c in /opt/occlum/glibc/lib/libchdb.so
9. DB::ThreadStatus::initPerformanceCounters() @ 0x00000000158a366e in /opt/occlum/glibc/lib/libchdb.so
10. DB::ThreadStatus::attachToGroupImpl(std::shared_ptr<DB::ThreadGroup> const&) @ 0x00000000158a347a in /opt/occlum/glibc/lib/libchdb.so
11. DB::ParallelParsingInputFormat::parserThreadFunction(std::shared_ptr<DB::ThreadGroup>, unsigned long) @ 0x00000000165dc9c0 in /opt/occlum/glibc/lib/libchdb.so
12. ThreadPoolImpl<ThreadFromGlobalPoolImpl<false>>::worker(std::__list_iterator<ThreadFromGlobalPoolImpl<false>, void*>) @ 0x00000000104c9de7 in /opt/occlum/glibc/lib/libchdb.so
13. ThreadFromGlobalPoolImpl<false>::ThreadFromGlobalPoolImpl<void ThreadPoolImpl<ThreadFromGlobalPoolImpl<false>>::scheduleImpl<void>(std::function<void ()>, Priority, std::optional<unsigned long>, bool)::'lambda0'()>(void&&)::'lambda'()::operator()() @ 0x00000000104cd83c in /opt/occlum/glibc/lib/libchdb.so
14. ThreadPoolImpl<std::thread>::worker(std::__list_iterator<std::thread, void*>) @ 0x00000000104c776d in /opt/occlum/glibc/lib/libchdb.so
15. ? @ 0x00000000104cb4ae in /opt/occlum/glibc/lib/libchdb.so
16. ? @ 0x00007f7592116759 in ?
```

I fix by adding capget syscall: https://github.com/aggregion/occlum/blob/aggregion/src/libos/src/process/syscalls.rs#L547-L559