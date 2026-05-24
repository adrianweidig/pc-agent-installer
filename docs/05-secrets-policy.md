# Secrets Policy

Erlaubt sind Secret-Referenzen: Name, Zweck, Ablageort, Zugriffsmethode, benötigte Berechtigungen und Rotationshinweise.

Verboten sind Secret-Werte: Passwörter, Tokens, API-Keys, private Schlüssel, ungefilterte `.env`-Dateien, produktive Kubeconfigs und Zertifikats-Private-Keys.

Secret-Referenzen pro Host liegen unter `hosts/<HOSTNAME>/security/`.
