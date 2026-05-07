-- BipolarMonitor PostgreSQL schema
-- Tables are also auto-created by SQLAlchemy on first API start,
-- this file adds indexes and retention policy setup.

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Retention policy helper: mark old media for cleanup
CREATE OR REPLACE FUNCTION cleanup_old_media(retention_days INT DEFAULT 30)
RETURNS INT AS $$
DECLARE
    deleted INT;
BEGIN
    UPDATE measurements
    SET video_path = NULL, audio_path = NULL
    WHERE analyzed = TRUE
      AND created_at < NOW() - (retention_days || ' days')::INTERVAL
      AND (video_path IS NOT NULL OR audio_path IS NOT NULL);
    GET DIAGNOSTICS deleted = ROW_COUNT;
    RETURN deleted;
END;
$$ LANGUAGE plpgsql;

-- Run cleanup daily via pg_cron (if available) or cron job calling this function
-- SELECT cron.schedule('bipolar-cleanup', '0 4 * * *', 'SELECT cleanup_old_media(30)');
