from pyspark.ml.feature import VectorAssembler
from pyspark.ml.classification import RandomForestClassifier
from pyspark.sql.functions import col, when

spark.sql("USE CATALOG workspace")
spark.sql("USE SCHEMA delta")

# Preparando o Alvo (Label)
# Vamos considerar Risco (1) se o aluno tiver média < 6 ou mais de 2 meses inadimplente
df_ia = spark.table("gold_fato_evasao").withColumn(
    "label", 
    when((col("notas_global") < 6.0) | (col("meses_inadimplente") > 1), 1).otherwise(0)
)

# Seleção de Características (Features)
# A IA vai aprender com base em: Notas, Faltas e Inadimplência
assembler = VectorAssembler(
    inputCols=["notas_global", "faltas_total", "meses_inadimplente"], 
    outputCol="features"
)

df_preparado = assembler.transform(df_ia)

# Treinamento do Modelo (Random Forest)
rf = RandomForestClassifier(labelCol="label", featuresCol="features", numTrees=10)
modelo = rf.fit(df_preparado)

# Gerando as Predições e o Score de Risco
predicoes = modelo.transform(df_preparado)

# Criando a Camada Final para o Power BI
# Adicionamos a probabilidade de evasão
from pyspark.sql.functions import udf
from pyspark.sql.types import FloatType

primeiro_elemento = udf(lambda v: float(v[1]), FloatType())

resultado_final = predicoes.withColumn("score_risco", primeiro_elemento(col("probability")))

# Salvando a tabela física para o Power BI ler
resultado_final.select(
    "pk_matricula_curso", "fk_aluno", "notas_global", 
    "meses_inadimplente", "prediction", "score_risco"
).write.mode("overwrite").saveAsTable("gold_ia_previsao_evasao")

print(" IA Preditiva treinada e tabela gold_ia_previsao_evasao gerada!")
display(spark.sql("SELECT * FROM gold_ia_previsao_evasao ORDER BY score_risco DESC"))
