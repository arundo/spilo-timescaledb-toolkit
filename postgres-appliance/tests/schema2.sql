CREATE EXTENSION amcheck_next;  /* the upgrade script must delete it before running pg_upgrade --check! */

\c test_db

CREATE TABLE with_oids() WITH OIDS;

CREATE EXTENSION timescaledb;
CREATE EXTENSION timescaledb_toolkit;

CREATE TABLE "fOo" (id bigint NOT NULL PRIMARY KEY);
SELECT create_hypertable('"fOo"', 'id', chunk_time_interval => 100000);
INSERT INTO "fOo" SELECT * FROM (
    SELECT
        time,
        random()*100 as value
    FROM generate_series(
        '2021-01-01 00:00:00',
        '2021-01-02 04:00:00',
        INTERVAL '1 second'
    ) as time
);
ALTER TABLE "fOo" ALTER COLUMN id SET STATISTICS 500;

SELECT
    time_bucket('1 day'::interval, time) as dt,
    time_weight('Linear', time, value) AS tw -- get a time weight summary
FROM "fOo"
GROUP BY time_bucket('1 day'::interval, time);