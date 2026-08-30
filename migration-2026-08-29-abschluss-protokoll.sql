-- FourStands Ticket-Börse — Migration „Abschluss-Protokoll"
-- Stand: 2026-08-29
--
-- Zweck: festhalten, WER mit WEM einen Deal gemacht hat und auf welchem Weg ein Eintrag
-- geschlossen wurde. Bisher war „erledigt" nicht unterscheidbar: der „Deal"-Knopf (Match über
-- die Börse) und der „✓ Erledigt"-Knopf (jemand räumt seinen Eintrag auf) hinterließen exakt
-- denselben Zustand. Damit ließ sich nicht messen, ob die Börse tatsächlich vermittelt.
--
-- Reihenfolge: ERST dieses Skript im Supabase-SQL-Editor ausführen, DANN die neue index.html
-- deployen. Die Spalten sind nullable — die aktuell laufende App stört das nicht.
-- Umgekehrt würde die neue App gegen fehlende Spalten schreiben und Fehler werfen.
--
-- Idempotent: mehrfaches Ausführen ist unschädlich.

-- ── 1. Spalten ────────────────────────────────────────────────────────────────
--   partner_id  Gegenstück des Deals (auf BEIDEN Zeilen gesetzt)
--   closed_via  'deal'  = über die Börse vermittelt (Match + „Deal"-Knopf)
--               'solo'  = Mitglied hat den eigenen Eintrag ohne Match abgehakt
--               'admin' = vom Admin über das ×-Symbol entfernt
--               'auto'  = nächtliche Aufräum-Routine (Spiel > 2 Tage vorbei)
--   closed_at   Zeitpunkt des Schließens (eintraege hat kein updated_at)
ALTER TABLE public.eintraege
  ADD COLUMN IF NOT EXISTS partner_id uuid REFERENCES public.eintraege(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS closed_via text,
  ADD COLUMN IF NOT EXISTS closed_at  timestamptz;

DO $do$ BEGIN
  ALTER TABLE public.eintraege ADD CONSTRAINT eintraege_closed_via_chk
    CHECK (closed_via IN ('deal','solo','admin','auto'));
EXCEPTION WHEN duplicate_object THEN NULL; END $do$;

-- Auswertung „welche Deals gab es zu Spiel X" läuft über partner_id
CREATE INDEX IF NOT EXISTS eintraege_partner_idx ON public.eintraege(partner_id)
  WHERE partner_id IS NOT NULL;

-- ── 2. Deal atomar abschließen ────────────────────────────────────────────────
-- Ersetzt die bisherigen zwei Einzel-Updates aus dealDone(). Ein UPDATE trifft beide
-- Zeilen in einer Transaktion: entweder sind danach beide geschlossen und wechselseitig
-- verknüpft, oder es hat sich nichts geändert. Ein Verbindungsabbruch mitten im Deal kann
-- damit keine halb geschlossene Paarung mehr hinterlassen.
CREATE OR REPLACE FUNCTION public.deal_done(a uuid, b uuid)
RETURNS void LANGUAGE sql SECURITY INVOKER AS $fn$
  UPDATE public.eintraege
     SET status     = 'erledigt',
         closed_via = 'deal',
         closed_at  = now(),
         partner_id = CASE WHEN id = a THEN b ELSE a END
   WHERE id IN (a, b);
$fn$;

-- ── 3. Wieder öffnen ──────────────────────────────────────────────────────────
-- Bleibt bewusst einseitig (öffnet nur den eigenen Eintrag, siehe Hilfe-Reiter), löst aber
-- den Rückverweis der Gegenseite auf. Sonst zeigte ein erledigter Eintrag auf einen wieder
-- offenen — die Auswertung würde einen Deal zählen, den es nicht mehr gibt.
CREATE OR REPLACE FUNCTION public.reopen_entry(e_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY INVOKER AS $fn$
DECLARE p uuid;
BEGIN
  SELECT partner_id INTO p FROM public.eintraege WHERE id = e_id;
  UPDATE public.eintraege
     SET status='offen', closed_via=NULL, closed_at=NULL, partner_id=NULL
   WHERE id = e_id;
  IF p IS NOT NULL THEN
    UPDATE public.eintraege SET partner_id=NULL WHERE id = p;
  END IF;
END $fn$;

-- SECURITY INVOKER: die Funktionen laufen mit den Rechten des Aufrufers, also weiterhin
-- unter den bestehenden RLS-Regeln für anon. Die Sicherheitslage ändert sich dadurch nicht.
GRANT EXECUTE ON FUNCTION public.deal_done(uuid,uuid) TO anon;
GRANT EXECUTE ON FUNCTION public.reopen_entry(uuid)   TO anon;

-- ── 4. Bestandsdaten ──────────────────────────────────────────────────────────
-- Bewusst KEIN Backfill. Bei Alt-Einträgen ist nicht rekonstruierbar, wer mit wem
-- abgeschlossen hat (es gibt kein updated_at, über das man Paare zeitlich zuordnen könnte).
-- Alte Zeilen behalten closed_via = NULL = „vor Einführung des Protokolls".

-- ── 5. Kontrolle ──────────────────────────────────────────────────────────────
-- Nach dem Deploy zeigt diese Abfrage je Spiel, wie viel die Börse wirklich vermittelt hat:
--
--   SELECT s.datum, s.gegner,
--          count(*) FILTER (WHERE e.closed_via='deal')  AS vermittelt,
--          count(*) FILTER (WHERE e.closed_via='solo')  AS selbst_abgehakt,
--          count(*) FILTER (WHERE e.closed_via='auto')  AS nachtlauf,
--          count(*) FILTER (WHERE e.closed_via IS NULL AND e.status<>'offen') AS vor_protokoll
--     FROM public.eintraege e JOIN public.spiele s ON s.id = e.spiel_id
--    GROUP BY s.datum, s.gegner ORDER BY s.datum DESC;
