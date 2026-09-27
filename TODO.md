# TODO — FourStands Ticket-Tausch-Börse

Lebende Liste offener Punkte. Stand: 2026-09-26.

## ✅ „Gesuch für wen" (2026-09-26) — migriert und deployt

- [x] **Mitglieder-Feedback (unisono):** a) bei der Suche angeben, ob das Ticket für einen selbst
  oder für jemand anderes ist; b) Gesuche für andere automatisch hinter dem letzten Gesuch eines
  Mitglieds für sich selbst. Umgesetzt in Commit `37363ae`:
  - Pflichtfeld „Für wen?" im Suche-Formular + Bearbeiten; Schild „👥 nur für andere" auf der Karte.
  - Warteschlange `suCmp`: `defer` → `fuer` → Zeitstempel (Verzicht/Frist stuft weiterhin zurück —
    dann kann auch ein Gesuch für andere drankommen). #-Nummer = echte Position.
  - **Korrektur (Stephan, 26.09.2026):** „Für mich selbst" gilt auch **mit Begleitung** (Anzahl frei);
    „für andere" nur, wenn das Mitglied selbst **nicht** mitgeht. Die zuerst ausgelieferte Fassung
    (selbst = genau 1 Ticket, Begleitung als zweites Gesuch, ein Gesuch je Art) ist zurückgenommen —
    wieder ein aktives Gesuch je Spiel + Kontakt. Alt-Einträge ohne Angabe zählen als „selbst".
  - Hilfe DE/EN, Setup-SQL (Abschnitt 8), `aktivitaet.ps1` (Nachtbericht) nachgezogen.
  - [x] Migration `migration-2026-09-26-gesuch-fuer-wen.sql` im Supabase-SQL-Editor ausgeführt
    (26.09.2026; API-Check danach: Spalte `fuer` vorhanden, alle 40 Alt-Suchen = NULL → zählen als „selbst").
- [x] **Deploy:** Branch `feat/gesuch-fuer-wen` nach `main` gemergt + gepusht (26.09.2026, NACH der Migration).
  Merksatz für künftige Schema-Änderungen: immer erst das SQL, dann der Push — andersherum scheitert
  jede Eintragung (todb sendet die neue Spalte mit).
  - **Begleit-Tickets einstellbar (Stephan, 26.09.2026):** Setup → Gesuch-Regeln → „Max. Begleit-Tickets
    je Gesuch ‚für mich selbst'" (config `max_begleit`, 0–9, Default 3 = bisherige Obergrenze 4 Karten).
    Gesuche „nur für andere" bleiben bei 1–4 Karten. Bestehende Gesuche über einer gesenkten Grenze
    bleiben unverändert (Bestandsschutz beim Bearbeiten).
  - Nebenbei behoben: Bearbeiten einer Suche mit Stand „egal" setzte beim Speichern still den ersten
    Stand (Nordkurve) — der Bearbeiten-Dialog bietet für Suchen jetzt „egal / beliebig" an.
- [x] **Korrektur „Begleitung = selbst" + Begleit-Grenze ausgeliefert** (26.09.2026, reiner Code-Push,
  keine Migration nötig — `max_begleit` legt die App beim ersten Speichern im Setup selbst an).
- [x] **Feedback-Eintrag beantwortet** (26.09.2026, 💬-Board). Der Antworttext wird mit dem Deploy der
  Korrektur angepasst (die erste Fassung nannte noch „genau 1 Ticket").

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

- ~~Echtes Web-Push bei Match~~ — **verworfen (Stephan, 27.09.2026):** bräuchte einen eigenen
  Server/Edge Function + VAPID und verursacht laufende Kosten; bewusst nicht vorgesehen. Beim
  Fanclub-Treffen 22.09.2026 nachgefragt, Antwort per Mail. Ersatz bleibt die opt-in
  Browser-Benachrichtigung (⋮ → 🔔 Match-Benachrichtigung, nur bei geöffnetem Tab).
- [ ] pg_cron als Sicherheitsnetz für die Match-Ablauffrist (rückt sonst nur vor, wenn jemand die App offen hat).
- [ ] DB-Partial-Unique-Index gegen doppelte aktive Suchen (aktuell clientseitig).
- [x] `dealDone` atomar per Supabase-RPC (vorher zwei Einzel-Updates). Umgesetzt 2026-08-29 im Zuge
  des **Abschluss-Protokolls** (`migration-2026-08-29-abschluss-protokoll.sql`): neue Spalten
  `partner_id` / `closed_via` / `closed_at` auf `eintraege` halten fest, **wer mit wem** und auf
  welchem Weg geschlossen wurde (`deal` = über die Börse vermittelt, `solo` = selbst abgehakt,
  `admin`, `auto` = Nachtlauf). Damit ist erstmals messbar, ob die Börse tatsächlich vermittelt —
  vorher waren „Deal"-Knopf und „✓ Erledigt"-Knopf im Datenbestand nicht unterscheidbar.
  ⚠️ **Deploy-Reihenfolge:** erst das SQL im Supabase-Editor, dann die neue `index.html` pushen.
  Kein Backfill für Alt-Einträge möglich (kein `updated_at`), die bleiben `closed_via = NULL`.
- [ ] CSV-Export, Countdown „in X Tagen".
- [x] **„Wieder öffnen"-Knopf** für eigene erledigte Einträge (versehentlichen „Deal"/„Erledigt" rückgängig machen). Umgesetzt 2026-06-19 (Commit folgt): bei erledigten Einträgen mit `mineB||adm` → `reopenE`/`dbReopen` setzt Status zurück auf `offen`. Hinweis: einseitig (reopent nur den eigenen Eintrag, nicht automatisch den Match-Partner). Sichtbar nur bei aktivem „Erledigte zeigen".
