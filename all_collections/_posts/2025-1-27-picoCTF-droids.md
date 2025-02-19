---
title: "picoCTF droids"
date: 2025-1-27
categories: [ctf, writeup]
---

# droids0

First open `zero.apk` with `jadx-gui`, in `com.hellocmu.picoctf.FlagstaffHill` the following code writes the flag to syslog.

```java
public static String getFlag(String input, Context ctx) {
    Log.i("PICO", paprika(input));
    return "Not Today...";
}
```

Using android studio's emulator the log can be found in `Logcat`.

![alt text]({{site.baseurl}}/assets/images/picoCTF-droids/droids0.png)

# droids1

First open `one.apk` with `jadx-gui`, in `com.hellocmu.picoctf.FlagstaffHill` the following code check for the password.

```java
public static String getFlag(String input, Context ctx) {
    String password = ctx.getString(R.string.password);
    return input.equals(password) ? fenugreek(input) : "NOPE";
}
```

Then the password can be found under `Resources/resources.arsc/res/values/strings.xml`, which is `opossum`.

```xml
<string name="password">opossum</string>
```

Run the apk in emulator and enter the password to get the flag

![alt text]({{site.baseurl}}/assets/images/picoCTF-droids/droids1.png)

# droids2

Same as previous problems, the password is generated in `com.hellocmu.picoctf.FlagstaffHill`.

```java
public static String getFlag(String input, Context ctx) {
    String[] witches = {"weatherwax", "ogg", "garlick", "nitt", "aching", "dismass"};
    int second = 3 - 3;
    int third = (3 / 3) + second;
    int fourth = (third + third) - second;
    int fifth = 3 + fourth;
    int sixth = (fifth + second) - third;
    String password = "".concat(witches[fifth]).concat(".").concat(witches[third]).concat(".").concat(witches[second]).concat(".").concat(witches[sixth]).concat(".").concat(witches[3]).concat(".").concat(witches[fourth]);
    return input.equals(password) ? sesame(input) : "NOPE";
}
```

Next, use java sandbox to print out the `password` and get the flag

![alt text]({{site.baseurl}}/assets/images/picoCTF-droids/droids2-sandbox.png)

![alt text]({{site.baseurl}}/assets/images/picoCTF-droids/droids2-flag.png)

# droids3

Using the same first step, the `getFlag` will always call `nope`.

```java
public class FlagstaffHill {
    public static native String cilantro(String str);

    public static String nope(String input) {
        return "don't wanna";
    }

    public static String yep(String input) {
        return cilantro(input);
    }

    public static String getFlag(String input, Context ctx) {
        String flag = nope(input);
        return flag;
    }
}
```

Following the [guild](https://book.jorianwoltjer.com/mobile/patching-apks) to patch the apk file

Decode the apk file into source code and change `nope` to `yep`.

`apktool d -f -r three.apk `

```smali
# smali/com/hellocmu/picoctf/FlagstaffHill.smali
# line 25
- invoke-static {p0}, Lcom/hellocmu/picoctf/FlagstaffHill;->nope(Ljava/lang/String;)Ljava/lang/String;
+ invoke-static {p0}, Lcom/hellocmu/picoctf/FlagstaffHill;->yep(Ljava/lang/String;)Ljava/lang/String;
```

Rebuild the apk file, however the current apk isn't sign, which cannot be installed on emulator.

`apktool b -f three -o three-new.apk`

Generate own key and sign the rebuilt apk file. 

```bash
keytool -genkey -noprompt -dname 'CN=, OU=, O=, L=, S=, C=' -keystore apk.keystore -alias 'apk' -keyalg RSA -storepass 'password' -keypass 'password'
```

```bash
apksigner sign -out three-new-signed.apk --ks-key-alias 'apk' --ks apk.keystore --key-pass 'pass:password' --ks-pass 'pass:password' -v three-new.apk
```

Then run the app to get the flag.

![alt text]({{site.baseurl}}/assets/images/picoCTF-droids/droids3.png)

# droids4

Since the structure is similar to previous ones, calling `cardamom` with password will likely return the flag.

```java
public class FlagstaffHill {
    public static native String cardamom(String str);

    public static String getFlag(String input, Context ctx) {
        StringBuilder ace = new StringBuilder("aaa");
        StringBuilder jack = new StringBuilder("aaa");
        StringBuilder queen = new StringBuilder("aaa");
        StringBuilder king = new StringBuilder("aaa");
        ace.setCharAt(0, (char) (ace.charAt(0) + 4));
        ace.setCharAt(1, (char) (ace.charAt(1) + 19));
        ace.setCharAt(2, (char) (ace.charAt(2) + 18));
        jack.setCharAt(0, (char) (jack.charAt(0) + 7));
        jack.setCharAt(1, (char) (jack.charAt(1) + 0));
        jack.setCharAt(2, (char) (jack.charAt(2) + 1));
        queen.setCharAt(0, (char) (queen.charAt(0) + 0));
        queen.setCharAt(1, (char) (queen.charAt(1) + 11));
        queen.setCharAt(2, (char) (queen.charAt(2) + 15));
        king.setCharAt(0, (char) (king.charAt(0) + 14));
        king.setCharAt(1, (char) (king.charAt(1) + 20));
        king.setCharAt(2, (char) (king.charAt(2) + 15));
        String password = "".concat(queen.toString()).concat(jack.toString()).concat(ace.toString()).concat(king.toString());
        return input.equals(password) ? "call it" : "NOPE";
    }
}
```

Follows the same steps with `droids3` to patch apk and use sandbox to get `password`, which is `alphabetsoup`

```
# smali/com/hellocmu/picoctf/FlagstaffHill.smali
# line 234
- const-string v5, "call it"
+ invoke-static {p0}, Lcom/hellocmu/picoctf/FlagstaffHill;->cardamom(Ljava/lang/String;)Ljava/lang/String;
+ 
+ move-result-object v5
```

Last enter the password to the patched apk to get the flag.

![alt text]({{site.baseurl}}/assets/images/picoCTF-droids/droids4.png)