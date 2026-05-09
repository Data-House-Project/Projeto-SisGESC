# Dim_Aluno: Consolida dados de Aluno e Pessoa na memória
spark.sql("""
CREATE OR REPLACE TEMP VIEW gold_dim_aluno AS
SELECT 
    a.pk_aluno,
    a.ra,
    p.nome,
    p.sobrenome,
    p.genero,
    p.data_nascimento,
    p.email_pessoal
FROM silver_aluno a
JOIN silver_pessoa p ON a.fk_pessoa = p.pk_pessoa
""")
print(" View gold_dim_aluno criada com sucesso!")

# Dim_Curso: Consolida Curso e Departamento na memória
spark.sql("""
CREATE OR REPLACE TEMP VIEW gold_dim_curso AS
SELECT 
    c.pk_curso,
    c.nome_curso,
    c.tipo_curso,
    d.nome_depto,
    d.sigla_depto
FROM silver_curso c
JOIN silver_departamento d ON c.fk_depto = d.pk_depto
""")
print(" View gold_dim_curso criada com sucesso!")
