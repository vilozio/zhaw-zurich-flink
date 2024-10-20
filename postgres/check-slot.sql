-- Check for Replication Status
SELECT 
  slot_name,
  plugin,
  slot_type,
  database,
  active,
  active_pid,
  restart_lsn,
  confirmed_flush_lsn
FROM pg_replication_slots;


-- Check for Replay Lag
SELECT usename, application_name, replay_lag 
FROM pg_stat_replication;
