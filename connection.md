# Connexion pour screenK

## Sélection
Utilisez --serial pour spécifier l'appareil.

## TCP/IP (sans fil)
Utilisez --tcpip pour connecter automatiquement.

Méthode manuelle :
1. Obtenez l'IP : adb shell ip route
2. adb tcpip 5555
3. adb connect IP:5555
4. Lancez screenK.ps1
