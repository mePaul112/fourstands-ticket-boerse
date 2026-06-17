# FourStands Ticket-Börse

FC St. Pauli Fanclub **FourStands** – self-hosted ticket exchange app.

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

## Deployment

Push auf `main` → GitHub Actions deployt automatisch auf GitHub Pages → App live unter `https://[username].github.io/fourstands-ticket-boerse/`
