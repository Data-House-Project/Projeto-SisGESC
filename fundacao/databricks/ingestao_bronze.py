%pip install mysql-connector-python pandas

import mysql.connector
import pandas as pd

config = {
    'host': 'mysql-16bf5bed-sisgesc-universitario-1b04.l.aivencloud.com', 
    'user': 'avnadmin',
    'password': '', #retirei por segurança.
    'port': 25090,
    'database': 'sisgesc_universitario'
}

tabelas_sisgesc = [
    "pessoa", "nacionalidade", "endereco", "dependente", "dados_bancarios", 
    "formacao_academica", "usuario", "perfil", "usuario_perfil", "log_auditoria", 
    "departamento", "cargo", "funcionario", "dados_trabalhistas", "professor", 
    "progressao_docente", "avaliacao_desempenho", "ocorrencia_disciplinar", 
    "substituicao_chefia", "curso", "professor_curso", "coordenador", "aluno", 
    "disciplina", "turma", "matricula_curso", "matricula_turma", "motivo_reprovacao", 
    "desempenho", "evento_calendario", "projeto_academico", "bolsa_estudo",
    "producao_cientifica", "autor_producao", "pessoa_juridica", "contratos_educacionais", 
    "mensalidade", "inadimplencia", "contas_receber", "contas_receber_mensalidade", 
    "pagamento_recebido", "fornecedor", "contas_pagar", "pagamento", "folha_pagamento", 
    "rubrica", "item_folha", "beneficio", "vinculo_beneficio", "sindicato", 
    "vinculo_sindicato", "registro_ponto", "banco_horas", "exame_medico", 
    "afastamento", "controle_ferias", "ativo_equipamento", "espaco_fisico", 
    "alocacao_ativo_local", "parceiro_comercial", "contrato_espaco", "empresa_terceirizada",
    "colaborador_terceirizado", "veiculo_estacionamento", "processo_seletivo", 
    "candidato", "entrevista_desligamento", "documento_digital", "intercambio_internacional", 
    "premiacao_honraria", "conselho_colegiado", "membro_conselho"
]

from pyspark.sql.types import StructType, StructField, StringType

try:
    print(" Iniciando conexão com o Aiven...")
    conn = mysql.connector.connect(**config)
    print(" Conectado ao Aiven! Iniciando ingestão da Camada Bronze...")

    for tabela in tabelas_sisgesc:
        print(f" Processando: {tabela}...")
        try:
            # Extrai do MySQL usando Pandas
            query = f"SELECT * FROM {tabela}"
            pdf = pd.read_sql(query, conn)

            if not pdf.empty:
                df_spark = spark.createDataFrame(pdf)
                status = "com dados"
            else:
                schema = StructType([StructField(col, StringType(), True) for col in pdf.columns])
                df_spark = spark.createDataFrame([], schema)
                status = "vazia (apenas estrutura)"
                
            # Salva a tabela no Catálogo do Databricks
            df_spark.write.mode("overwrite").saveAsTable(f"bronze_{tabela}")
            print(f" Tabela bronze_{tabela} salva com sucesso! [{status}]")
                
        except Exception as erro_tabela:
            print(f" Erro ao ler/salvar a tabela {tabela}: {erro_tabela}")

except Exception as e:
    print(f" Erro crítico de conexão (Verifique Host/Senha): {e}")
finally:
    if 'conn' in locals() and conn.is_connected():
        conn.close()
        print(" Conexão com o banco Aiven encerrada.")
        print(" Pipeline da Camada Bronze finalizado!")
