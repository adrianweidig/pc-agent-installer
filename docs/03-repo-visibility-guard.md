# Repo Visibility Guard

Vor Host-Schreibzugriffen gilt:

1. `repo-mode.yaml` lesen.
2. Git-Remotes prüfen.
3. Falls Remote vorhanden, GitHub-Sichtbarkeit mit `gh repo view --json isPrivate,visibility,nameWithOwner` prüfen.
4. Hostdaten nur erlauben, wenn `operational` plus private Sichtbarkeit oder `local-only` plus kein Remote bestätigt ist.

Bei öffentlichem oder ungeprüftem Remote werden keine Hostdaten geschrieben.
