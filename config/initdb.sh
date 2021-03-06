#!/usr/bin/env bash
perl -pi -e "s/#shared_preload_libraries = ''/shared_preload_libraries = 'pg_stat_statements'/g" $PGDATA/postgresql.conf
#echo "shared_preload_libraries = 'pg_stat_statements'" >> $PGDATA/postgresql.conf
echo "pg_stat_statements.max = 10000" >> $PGDATA/postgresql.conf
echo "pg_stat_statements.track = all" >> $PGDATA/postgresql.conf

set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER todo01 WITH PASSWORD 'todo';
    GRANT USAGE ON SCHEMA public TO todo01;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO todo01;
    GRANT todo TO todo01;
    CREATE EXTENSION PG_STAT_STATEMENTS;
EOSQL