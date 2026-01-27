1 º Começamos por fazer a adiçáo do metabase e do data werehouse no nossso docker compose file.~
2 º Temos de assegurar que o nosso data werehouse tenha acesso aos dados, para isto existe duas formas:
    1 º "Live Link" (Postgres Foreign Data Wrappers), onde criamos um link entre o nosso datawerehouse e as restantes Dbs
            Example ::
                        -- 1. Enable the extension in the Warehouse
                    CREATE EXTENSION postgres_fdw;

                    -- 2. Create a "Server" definition for the Issues DB
                    -- Notice: host is the container name defined in docker-compose
                    CREATE SERVER issues_server 
                    FOREIGN DATA WRAPPER postgres_fdw 
                    OPTIONS (host 'ipt_issues_db', dbname 'issues_app', port '5432');

                    -- 3. Map the User
                    -- Allow 'warehouse_user' to login to 'issues_server' as 'issues_user'
                    CREATE USER MAPPING FOR warehouse_user
                    SERVER issues_server 
                    OPTIONS (user 'issues_user', password 'issues_pass');

                    -- 4. Import the Schema
                    -- This creates "foreign tables" in your warehouse that point to the real data
                    IMPORT FOREIGN SCHEMA public 
                    FROM SERVER issues_server 
                    INTO public;


    2 º "Python Worker" (ETL Script), script que corre de tempo a tempo Cron job, responsavel por ir fazer a extraçao dos dados das Dbs
         transforma los e popular a werehouse.

Através do primeiro metodo criamos os links das dbs para o nosso data werehouse

3 º Ingestao de dados
    Vamos criar um ficheiro, neste caso o ficheiro "ingest.sh" que irá realizar
    a ingestão do conteudo nas DBs.

Após executarmos este script, já vamos conseguir aceder ao nosso metabase e recolher os dados


# DBT

docker exec -it ipt_dbt dbt seed --full-refresh

docker exec -it ipt_dbt dbt run --select +dim_students