# ☠ FourStands Ticket-Börse

**FC St. Pauli Fanclub FourStands** – Ticket-Suche, -Angebote und -Tausch in Echtzeit.

[![GitHub Pages](https://img.shields.io/badge/Hosted%20on-GitHub%20Pages-222?logo=github)](https://pages.github.com)
[![Supabase](https://img.shields.io/badge/DB-Supabase-3ECF8E?logo=supabase)](https://supabase.com)

---

## Features

| | |
|---|---|
| 🔍 **Suche** | Warteschlange mit Reihenfolge – wer zuerst kommt, wird zuerst bedient |
| 🎟️ **Biete** | Tickets anbieten mit Bereich, Anzahl und Signal-Kontakt |
| 🔄 **Tausch** | Tauschwünsche mit automatischem Match-Erkennung |
| ⚡ **Echtzeit** | Alle Änderungen sofort für alle Mitglieder sichtbar |
| 📱 **Signal** | Direkte Verlinkung zu Signal-Kontakten |
| 🔒 **Admin-PIN** | Spiele-Anlage und Setup geschützt |

## Schnellstart

### 1. Supabase einrichten (einmalig, ~5 Min.)

1. Kostenloses Konto auf [supabase.com](https://supabase.com) anlegen
2. Neues Projekt erstellen
3. **SQL Editor** → diesen Code ausführen:

```sql
CREATE TABLE public.spiele (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  gegner text NOT NULL,
  datum date NOT NULL,
  typ text NOT NULL CHECK (typ IN ('heim','auswaerts')),
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.eintraege (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  spiel_id uuid REFERENCES public.spiele(id) ON DELETE CASCADE,
  typ text NOT NULL CHECK (typ IN ('suche','biete','tausch')),
  bereich text NOT NULL,
  tausch_gegen text,
  name text NOT NULL,
  signal_kontakt text,
  anzahl integer DEFAULT 1,
  notiz text,
  status text DEFAULT 'offen' CHECK (status IN ('offen','erledigt')),
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.spiele ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.eintraege ENABLE ROW LEVEL SECURITY;
CREATE POLICY "FourStands" ON public.spiele FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "FourStands" ON public.eintraege FOR ALL TO anon USING (true) WITH CHECK (true);
ALTER PUBLICATION supabase_realtime ADD TABLE public.spiele;
ALTER PUBLICATION supabase_realtime ADD TABLE public.eintraege;
```

4. **Project Settings → API**: URL und `anon public` Key notieren

### 2. App konfigurieren

Die App unter der GitHub Pages URL öffnen → **Setup-Tab** → URL und Key eintragen → Verbinden.

> ⚠️ URL ohne `/rest/v1/` am Ende: `https://xxxxx.supabase.co`

### 3. Admin-PIN setzen

Im Setup-Tab nach Verbindung den Standard-PIN `0000` ändern.

## Zugangskontrolle

Die App ist zugangsbeschränkt durch:
- **Geheime URL** – nur wer den Link kennt, kommt rein
- **Admin-PIN** – schützt Spiel-Anlage und Einstellungen vor versehentlichen Änderungen

## Lokale Entwicklung mit Claude Code

```bash
git clone https://github.com/DEIN-USERNAME/fourstands-ticket-boerse
cd fourstands-ticket-boerse
claude   # Claude Code startet mit vollem Projektkontext via CLAUDE.md
```

## Tech

- Single-File HTML/CSS/JS – kein Build-Step, kein Node, keine Dependencies
- [Supabase JS](https://supabase.com/docs/reference/javascript) via CDN
- [Bebas Neue](https://fonts.google.com/specimen/Bebas+Neue) + [Barlow Condensed](https://fonts.google.com/specimen/Barlow+Condensed) via Google Fonts
- GitHub Pages für Hosting (kostenlos, keine eigene IP)

---

*HISN HISN HISN – Millerntor bleibt* ☠
