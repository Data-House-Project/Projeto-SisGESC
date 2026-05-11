print(" Criando Tabela de Fato na Camada Gold...")

# Fato_Evasao: Consolidação de notas, faltas e inadimplência
spark.sql("""
CREATE OR REPLACE TABLE gold_fato_evasao AS
SELECT 
    mc.pk_matricula_curso,
    mc.fk_aluno,
    mc.fk_curso,
    mc.notas_global,
    mc.faltas_total,
    mc.status_academico,
    -- Agregação de valores e contagem de meses atrasados
    COALESCE(SUM(m.valor_parcela), 0) AS total_mensalidade_gerada,
    COUNT(CASE WHEN m.status_mensalidade = 'ATRASADO' THEN 1 END) AS meses_inadimplente
FROM silver_matricula_curso mc
LEFT JOIN silver_contratos_educacionais ce ON ce.fk_matricula_curso = mc.pk_matricula_curso
LEFT JOIN silver_mensalidade m ON m.fk_contrato = ce.pk_contrato
GROUP BY 
    mc.pk_matricula_curso, 
    mc.fk_aluno, 
    mc.fk_curso, 
    mc.notas_global, 
    mc.faltas_total, 
    mc.status_academico
""")

print(" Tabela gold_fato_evasao criada!")

# Verificação rápida dos dados para a IA
display(spark.sql("SELECT * FROM gold_fato_evasao LIMIT 10"))
