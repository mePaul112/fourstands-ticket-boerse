# FourStands Ticket-Börse

FC St. Pauli Fanclub **FourStands** – self-hosted ticket exchange app.

> Einordnung: eigenständiger Hauptpfad **03 FourStands** (Leitfaden: `C:\Users\steph\OneDrive - prodAIx\xx_Lebensraum\LEITFADEN-Projektstruktur.md`, globale Regeln: `C:\Users\steph\.claude\CLAUDE.md`). Tägliche Routine: `C:\Users\steph\.claude\scheduled-tasks\fourstands-feedback-check\`. Chat-Titel `[FourStands] …`.

## Was ist das?

Eine Single-File Web-App (`index.html`) für den Fanclub FourStands (FC St. Pauli), die Ticket-Suche, -Angebote und -Tausch verwaltet. Kein Backend-Server – die App läuft statisch auf GitHub Pages und nutzt **Supabase** als Echtzeit-Datenbank.

## Tech Stack

- **Frontend**: Vanilla HTML/CSS/JS (Single File, kein Build-Step)
- **Datenbank**: Supabase (PostgreSQL + Realtime)
- **Hosting**: GitHub Pages
- **Fonts**: Bebas Neue + Barlow Condensed (Google Fonts)
- **Supabase JS**: CDN (jsdelivr)

## Projektstruktur

```
index.html      ← Die gesamte App (HTML + CSS + JS in einer Datei)
README.md       ← Projektbeschreibung
CLAUDE.md       ← Dieser Kontext für Claude Code
setup.sh        ← Einmaliges Setup-Script
```

## Design

- Farben: FC St. Pauli Stil — Dunkelbraun/Schwarz (`#0f0d0a`), FCSP Rot (`#EC1B24`), Braun (`#6B3A2A`)
- Fonts: Bebas Neue (Display), Barlow Condensed (UI), Barlow (Text)
- Branding: FourStands Totenkopf + Rainbow "FOUR STANDS" Logo
- Mobile-first, keine Abhängigkeiten außer Supabase CDN

## Features

- 🔍 **Suche** – Warteschlange mit Zeitstempel (#1, #2, ...)
- 🎟️ **Biete** – Ticket-Angebote mit Bereich + Anzahl
- 🔄 **Tausch** – Tauschwünsche mit automatischem Matching
- ⚡ **Match-Detection** – zeigt wenn Suche + Angebot zusammenpassen
- 🔔 **Match-Benachrichtigung** – Live-Hinweis in der App + optionale Browser-Notification bei neuen eigenen Matches (opt-in über ⋮-Menü; kein echtes Push bei geschlossener App)
- 📋 **Gesuch-Regeln** – Gesuche erst wenn Spiel zeitgenau terminiert (Anstoßzeit bekannt) und max. N aktive Gesuche pro Person, max. Begleit-Tickets je Selbst-Gesuch (config-Keys: `su_terminiert`, `max_su`, `max_begleit`; Setup-Tab)
- 🙋 **Für wen?** (seit 09/2026, Mitglieder-Feedback) – jede Suche trägt Pflichtangabe `fuer` = `selbst` (Mitglied geht mit, **auch mit Begleitung**: eigenes Ticket + bis zu `max_begleit` Begleit-Tickets, im Setup einstellbar, Default 3 = bisherige Obergrenze 4 Karten; Anzahl-Auswahl passt sich per `fuerChg` an, höhere Bestands-Anzahl bleibt beim Bearbeiten erhalten) oder `andere` (**nur** für andere, Mitglied geht selbst nicht mit). Warteschlange = `suCmp`: `defer` → `fuer` (selbst vor andere) → `created_at`; `andere` rutscht also auch hinter später eingetragene Selbst-Gesuche. `fuer = NULL` (Alt-Einträge) zählt als `selbst`. Je Spiel + Signal-Kontakt max. **ein aktives Gesuch je Art** (`suDup`: eins `selbst`, eins `andere`; seit 10/2026, Wunsch Marlies/Olaf „Fanclub first"). Beide zählen zu `max_su`. Die #-Nummer in der Liste zeigt die echte Warteschlangen-Position. Die Nachtroutine (`aktivitaet.ps1` im Scheduled Task) bildet `suCmp` nach — bei Änderungen dort mitziehen. Migration: `migration-2026-09-26-gesuch-fuer-wen.sql`
- 📱 **Signal-Links** – direkte Verlinkung zum Signal-Kontakt
- 🔒 **Admin-PIN** – schützt Spiele-Anlage und Setup (Standard: `0000`)
- ☁️ **Supabase Realtime** – alle Mitglieder sehen Änderungen sofort

## Supabase Schema

```sql
-- Tabellen: public.spiele, public.eintraege
-- RLS: anon hat vollen Zugriff (kein Login nötig)
-- Realtime: beide Tabellen in supabase_realtime publication
-- SQL steht im Setup-Tab der App
```

## Bereiche

- **Heimspiele**: Nordkurve, Südtribüne, Gegengerade, Haupttribüne
- **Auswärtsspiele**: Sitzplatz, Stehplatz

## Wichtige Variablen im JS

```js
cfg.url    // Supabase Project URL (ohne /rest/v1/)
cfg.key    // Supabase Anon Public Key
cfg.pin    // Admin-PIN (4 Ziffern, default: '0000')
// Alles in localStorage gespeichert unter 'fs-cfg4'
```

## Häufige Aufgaben

**Neues Feature hinzufügen**: Alles in `index.html`. CSS-Tokens in `:root { }`, JS-Funktionen am Ende des `<script>`-Blocks.

**Bereiche ändern**: Arrays `HEIM` und `AUSW` oben im JS-Block.

**Design anpassen**: CSS-Custom-Properties in `:root` — primär `--red`, `--brn`, `--bg`, `--sf`.

**Supabase-Schema erweitern**: SQL im Setup-Tab der App anpassen UND `mapei()` / `todb()` Funktionen im JS aktualisieren.

## Regeln

- **Hilfe mitpflegen (Stephan, 19.06.2026):** Jede Funktions- oder Bedienänderung zieht die In-App-Hilfe (?-Reiter, `helpPage()`) im selben Commit nach, zweisprachig DE und EN. Die Hilfe ist die einzige Anlaufstelle der Mitglieder; veraltete Hilfe erzeugt direkt Rückfragen.

## Deployment

Push auf `main` → GitHub Actions deployt automatisch auf GitHub Pages → App live unter `https://[username].github.io/fourstands-ticket-boerse/`
