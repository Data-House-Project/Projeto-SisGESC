from pyspark.ml.feature import VectorAssembler
from pyspark.ml.classification import RandomForestClassifier
from pyspark.sql.functions import col, when, udf
from pyspark.sql.types import FloatType

# Configuração de Caminho e Contexto
CATALOGO = "workspace"
ESQUEMA = "delta"

spark.sql(f"USE CATALOG {CATALOGO}")
spark.sql(f"USE SCHEMA {ESQUEMA}")

print(" Iniciando Treinamento da IA Preditiva...")

# Leitura da Tabela Gold (Base de Conhecimento)
df_gold = spark.table(f"{CATALOGO}.{ESQUEMA}.gold_fato_evasao")

# Definição do Alvo (Label)
# Classifica como Risco (1) se a nota for baixa ou houver inadimplência
df_ia = df_gold.withColumn("label", 
    when((col("notas_global") < 6.5) | (col("meses_inadimplente") > 0), 1).otherwise(0)
)

# Vetorização das Características (Features)
# A IA analisa Notas, Faltas e Inadimplência para aprender o padrão
assembler = VectorAssembler(
    inputCols=["notas_global", "faltas_total", "meses_inadimplente"], 
    outputCol="features"
)
df_final = assembler.transform(df_ia)

# 5. Treinamento do Modelo (Random Forest)
rf = RandomForestClassifier(labelCol="label", featuresCol="features", numTrees=10)
model = rf.fit(df_final)

# Geração das Predições
predicoes = model.transform(df_final)

# Extração do Score de Risco (Probabilidade de Evasão)
# Converte o vetor de probabilidade em um valor numérico para o Power BI
extrair_prob = udf(lambda v: float(v[1]), FloatType())
resultado_final = predicoes.withColumn("score_risco", extrair_prob(col("probability")))

# 8. Persistência dos Resultados para o Power BI
resultado_final.select(
    "pk_matricula_curso", 
    "notas_global", 
    "meses_inadimplente", 
    "prediction", 
    "score_risco"
).write.mode("overwrite").saveAsTable(f"{CATALOGO}.{ESQUEMA}.gold_ia_previsao_evasao")

print(" SUCESSO! A tabela 'gold_ia_previsao_evasao' foi gerada com as predições.")
display(spark.table(f"{CATALOGO}.{ESQUEMA}.gold_ia_previsao_evasao"))
