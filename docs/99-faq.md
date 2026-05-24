# FAQ

## Warum schreibt das Template keine Hostdaten?

Weil öffentliche oder ungeprüfte Repositories keine privaten Host- und Infrastrukturinformationen enthalten dürfen.

## Warum schlägt `assert-private-repo` im Template fehl?

Das ist beabsichtigt. Der Guard schützt Host-Schreibzugriffe. Template-Arbeit bleibt trotzdem möglich.

## Darf ich `.env` committen?

Nein. Nutze Secret-Referenzen und externe Secret Stores.
