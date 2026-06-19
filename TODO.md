# TODO — FourStands Ticket-Tausch-Börse

Lebende Liste offener Punkte. Stand: 2026-06-18.

## 🔜 Vor Go-Live entscheiden / ggf. einbauen

- [ ] **Nutzerverwaltung / echte Anmeldung (Lösung 1)** — *nach der Testphase, vor dem Live-Gang ggf. einbauen.*
  Ziel: echte Identität pro Mitglied, damit das aus dem Code-Review bekannte Sicherheits-Spannungsfeld
  (Anon-Key öffentlich, „nur Ersteller editiert" nur Vertrauenssache, Admin-PIN kosmetisch) wirklich
  geschlossen wird.
  - **Technik:** Supabase Auth, **Magic-Link** (passwortlos), **Invite-only** (nur Fanclub-Mitglieder).
  - Spalte `user_id uuid default auth.uid()` auf `eintraege`.
  - **RLS auf `auth.uid()` umstellen:** Insert/Update/Delete nur für eigene Zeilen; echte Admin-Rolle
    statt kosmetischem PIN; `me.nm` kommt aus dem Profil statt Freitext.
  - **E-Mail-Versand:** eigener SMTP (z. B. Resend/SendGrid, kostenlos) wegen Raten-Limit des
    Supabase-Standardversands bei ~50 gleichzeitigen Erstanmeldungen.
  - **Verwalten** (Nutzer anlegen/sperren/Reset/löschen) gratis über das **Supabase-Dashboard** —
    muss nicht selbst gebaut werden.
  - **Aufwand:** mittel (~½–1 Tag Umsetzung + Tests).
  - **Trade-off / Entscheidung:** Aus „Link öffnen, sofort loslegen" wird „erst anmelden".
    → Vor Go-Live bewusst entscheiden, ob die reibungslose Bedienung gegen echte Sicherheit getauscht wird.

- [ ] **Eigenen Admin-PIN setzen** (statt Default `0000`) — unabhängig von Lösung 1.

## 🔔 Feedback-Monitoring (eingerichtet 2026-06-18)

- [x] **Claude Scheduled Task** „fourstands-feedback-check" — täglich ~08:00, fasst neues Feedback inhaltlich zusammen (läuft, wenn die Claude-App offen ist).
- [ ] **GitHub Action „Feedback Nudge"** (`.github/workflows/feedback-nudge.yml`, serverseitig, täglich 06:00 UTC) — **wartet noch auf SMTP-Secrets!** Zu tun: in StartMail SMTP aktivieren, dann im Repo unter Settings → Secrets and variables → Actions die Secrets `SMTP_USERNAME` (= fourstands-ticketboerse@use.startmail.com) und `SMTP_PASSWORD` anlegen; danach „Run workflow" testen. Ohne Secrets mailt die Action nicht (kein Fehllauf). Fallback Resend möglich, falls StartMail-SMTP zickt.

## ✅ Vor Go-Live sicherstellen (Stand 2026-06-18 geprüft: erledigt)

- [x] Supabase-Migrationen ausgeführt: `defer`, `match_since`, `consent_at`, `config`-Tabelle,
  `ext_id`/`anstoss`, Status-CHECK inkl. `entfernt`, RLS-Policies (kein anon-DELETE auf `eintraege`),
  `tausch_spiel`, `spiele.logo`, `spiele.wettbewerb`, `feedback`-Tabelle (anon insert+select).

## 🗄️ Später / Backlog (kein Go-Live-Blocker)

- [ ] Echtes Web-Push bei Match (bewusst zurückgestellt — bräuchte Server/Edge Function + VAPID; iOS nur als installierte PWA).
- [ ] pg_cron als Sicherheitsnetz für die Match-Ablauffrist (rückt sonst nur vor, wenn jemand die App offen hat).
- [ ] DB-Partial-Unique-Index gegen doppelte aktive Suchen (aktuell clientseitig).
- [ ] `dealDone` atomar per Supabase-RPC (aktuell zwei Einzel-Updates).
- [ ] CSV-Export, Countdown „in X Tagen".
- [x] **„Wieder öffnen"-Knopf** für eigene erledigte Einträge (versehentlichen „Deal"/„Erledigt" rückgängig machen). Umgesetzt 2026-06-19 (Commit folgt): bei erledigten Einträgen mit `mineB||adm` → `reopenE`/`dbReopen` setzt Status zurück auf `offen`. Hinweis: einseitig (reopent nur den eigenen Eintrag, nicht automatisch den Match-Partner). Sichtbar nur bei aktivem „Erledigte zeigen".
