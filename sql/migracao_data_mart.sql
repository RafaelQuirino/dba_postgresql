DO $$
DECLARE
    row record;
BEGIN
    --Movendo as tabelas do schema public para o schema data_mart
    FOR row IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(row.tablename) || ' SET SCHEMA data_mart;';
    END LOOP;

    --Movendo as views do schema public para o schema data_mart
    FOR row IN SELECT viewname FROM pg_views WHERE schemaname = 'public' LOOP
        EXECUTE 'ALTER VIEW public.' || quote_ident(row.viewname) || ' SET SCHEMA data_mart;';
    END LOOP;

    --Movendo as sequences do schema public para o schema data_mart
    FOR row IN SELECT sequencename FROM pg_sequences WHERE schemaname = 'public' LOOP
        EXECUTE 'ALTER SEQUENCE public.' || quote_ident(row.sequencename) || ' SET SCHEMA data_mart;';
    END LOOP;
END;
$$; 