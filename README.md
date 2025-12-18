# ***ZIVPN Manager VPS & Telegram Bot***

## **Prasyarat**

⚠️ WAJIB memastikan UDP ZIVPN sudah terinstal dan berjalan di VPS.

⚠️ WAJIB siapkan Admin Id dan Token Bot telegram

Jika UDP ZIVPN belum terinstal, silakan instal terlebih dahulu.

> Manager VPS dan Bot Telegram tidak akan berfungsi dengan benar tanpa UDP ZIVPN.


## **Alur Instalasi**

### ***Instal UDP ZIVPN (wajib)***

  UDP server installation for ZIVPN Tunnel (SSH/DNS/UDP) VPN app.
<br>

>Server binary for Linux amd64 and arm.

#### Installation Zizi AMD
```
wget -O zi.sh https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/zi.sh; sudo chmod +x zi.sh; sudo ./zi.sh
```

#### Installation Zizi ARM
```
bash <(curl -fsSL https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/zi2.sh)
```

#### Uninstall Zizi

```
sudo wget -O ziun.sh https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/uninstall.sh; sudo chmod +x ziun.sh; sudo ./ziun.sh
```


### ***Instal Manager VPS + Bot Telegram***

#### Instalasi

Jalankan perintah berikut sebagai root di VPS:
```
curl -fsSL https://raw.githubusercontent.com/harunkl/zivpn-manager-bot/main/manager-bot.sh -o manager-bot.sh
chmod +x manager-bot.sh
./manager-bot.sh
```

***Catatan***

Pastikan VPS memiliki akses internet normal

Script akan mengatur manager VPS dan bot Telegram secara otomatis

Disarankan menggunakan VPS fresh / belum banyak service lain





