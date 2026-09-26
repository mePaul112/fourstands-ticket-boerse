-- FourStands Ticket-Börse — Migration „Gesuch für wen"
-- Stand: 2026-09-26
--
-- Zweck (Mitglieder-Feedback, unisono aus der Testphase):
--   a) Bei jeder Suche wird angegeben, ob das Mitglied SELBST mitgeht (auch mit Begleitung,
--      Anzahl frei) oder das Ticket NUR FÜR ANDERE sucht (geht selbst nicht mit) — Pflichtfeld.
--   b) Gesuche nur für andere stehen in der Warteschlange automatisch hinter dem letzten
--      Gesuch, bei dem ein Mitglied selbst mitgeht (auch hinter später eingetragenen).
--
-- Korrigiert 26.09.2026 (Stephan): Begleitung zählt zu 'selbst', 'andere' nur, wenn das
-- Mitglied selbst nicht mitgeht. Der Spaltenkommentar wurde in der DB noch mit der ersten
-- Fassung gesetzt ("genau 1 Ticket") — erneutes Ausführen dieses Skripts korrigiert ihn.
--
-- Die Reihenfolge rechnet der Client (index.html, suCmp): defer → fuer → created_at.
-- Die DB speichert nur die Angabe. Alt-Einträge behalten fuer = NULL und zählen als 'selbst'
-- (kein Backfill — wer vor der Regel gesucht hat, verliert seinen Platz nicht).
--
-- Reihenfolge: ERST dieses Skript im Supabase-SQL-Editor ausführen, DANN die neue index.html
-- deployen. Die Spalte ist nullable — die aktuell laufende App stört das nicht.
-- Umgekehrt würde die neue App gegen eine fehlende Spalte schreiben und jede Eintragung
-- (auch Biete/Tausch, todb() sendet fuer immer mit) mit Fehler abbrechen.
--
-- Idempotent: mehrfaches Ausführen ist unschädlich.

ALTER TABLE public.eintraege ADD COLUMN IF NOT EXISTS fuer text;

DO $do$ BEGIN
  ALTER TABLE public.eintraege ADD CONSTRAINT eintraege_fuer_chk
    CHECK (fuer IN ('selbst','andere'));
EXCEPTION WHEN duplicate_object THEN NULL; END $do$;

COMMENT ON COLUMN public.eintraege.fuer IS
  'Nur bei typ=suche: selbst = Mitglied geht mit (ggf. + Begleitung, Anzahl frei), andere = nur fuer andere (Mitglied geht nicht mit). NULL = Alt-Eintrag (zaehlt als selbst).';

-- PostgREST-Schema-Cache neu laden, damit die Spalte sofort per API sichtbar ist
NOTIFY pgrst, 'reload schema';

-- Kontrolle:
-- SELECT fuer, count(*) FROM public.eintraege WHERE typ='suche' GROUP BY 1;
