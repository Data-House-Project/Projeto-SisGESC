#primeiro bloco de código no notebook do Databricks, adicicionem esse bloco:

# Fato de Evasão Acadêmica na memória 
spark.sql("""
CREATE OR REPLACE TEMP VIEW gold_fato_evasao AS
SELECT 
    mc.pk_matricula_curso,
    mc.fk_aluno,
    mc.fk_curso,
    mc.notas_global,
    mc.faltas_total,
    mc.status_academico,
    -- Agregação financeira vinculada à matrícula
    COALESCE(SUM(m.valor_parcela), 0) AS total_mensalidade_gerada,
    COUNT(CASE WHEN m.status_mensalidade = 'ATRASADO' THEN 1 END) AS meses_inadimplente
FROM silver_matricula_curso mc
LEFT JOIN silver_contratos_educacionais ce ON ce.fk_matricula_curso = mc.pk_matricula_curso
LEFT JOIN silver_mensalidade m ON m.fk_contrato = ce.pk_contrato
GROUP BY 
    mc.pk_matricula_curso, mc.fk_aluno, mc.fk_curso, 
    mc.notas_global, mc.faltas_total, mc.status_academico
""")
print("Tabela View gold_fato_evasao criada com sucesso! Ouro finalizado!")

display(spark.sql("SELECT * FROM gold_fato_evasao LIMIT 10"))

#segundo bloco de código no mesmo notebook adicionem esse:

%sql
SELECT 
    meses_inadimplente,
    AVG(notas_global) as media_notas,
    COUNT(pk_matricula_curso) as total_alunos
FROM gold_fato_evasao
GROUP BY meses_inadimplente
ORDER BY meses_inadimplente ASC

#terceiro caso queiram gerar um csv
# Salva a tabela Ouro como um arquivo CSV para o PBI
df_gold = spark.sql("SELECT * FROM gold_fato_evasao")
df_gold.toPandas().to_csv("/Workspace/Users/SEUEMAIL@gmail.com/gold_fato_evasao.csv", index=False)
