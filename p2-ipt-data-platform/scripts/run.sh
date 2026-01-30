echo "IPT Data Platform - Automação de Ingestão e Transformação de Dados"

echo "🛠️  A iniciar os serviços..."
docker compose up -d --build
echo "✅ Serviços iniciados."

echo "🏗️  A gerar e carregar dados..."
"$(dirname "$0")/generate_and_load.sh"
"$(dirname "$0")/ingest.sh"
echo "✅ Dados gerados e carregados."

echo "📊 A executar dbt para transformar dados..."
docker exec -it ipt_dbt dbt seed --full-refresh
docker exec -it ipt_dbt dbt run --select +dim_students +fact_students
echo "✅ dbt concluído."

echo "🎉 Processo concluído com sucesso!"