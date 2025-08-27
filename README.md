# screenK

Outil pour reproduire les données (vidéo et audio) d'appareils Android connectés via USB ou TCP/IP, et les contrôler avec clavier/souris. Ne nécessite ni root ni app sur l'appareil. Fonctionne sur Windows, Linux, macOS.

## Exemple d'utilisation
- USB : `./screenK.ps1 -usb`
- TCP/IP : `./screenK.ps1 -tcpip -ipAddress 192.168.1.1`

Inspiré de [scrcpy](https://github.com/Genymobile/scrcpy).

## Connexion TCP/IP (manuel)
1. Connectez l'appareil via USB.
2. Exécutez `adb tcpip 5555`.
3. Déconnectez USB.
4. Exécutez `adb connect IP:5555`.
