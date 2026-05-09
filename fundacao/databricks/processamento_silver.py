from pyspark.sql.functions import col, trim, upper

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

print(" Iniciando processamento da Camada Prata (Poda Dinâmica de Colunas Fantasmas)...")

for tabela in tabelas_sisgesc:
    if not tabela.strip():
        continue
        
    nome_bronze = f"bronze_{tabela}"
    
    try:
        # Verifica se existe na Bronze
        if not spark.catalog.tableExists(nome_bronze):
            print(f" ALERTA: {nome_bronze} não encontrada. Pulando...")
            continue

        df_silver = spark.table(nome_bronze)
 
        # retira todas as colunas void com valor null dinâmicamente
        colunas_transformadas = []
        for nome_col, tipo_col in df_silver.dtypes:
            if tipo_col in ('void', 'null'):
                print(f" Podando coluna vazia '{nome_col}' da tabela {tabela}")
                continue
            elif tipo_col == 'string':
                colunas_transformadas.append(upper(trim(col(nome_col))).alias(nome_col))
            else:
                colunas_transformadas.append(col(nome_col))
        
        if not colunas_transformadas:
            print(f" Tabela {tabela} só tinha colunas nulas. Ignorada.")
            continue
            
        df_silver = df_silver.select(*colunas_transformadas)
        
        df_silver = df_silver.dropDuplicates()
        
        # Salva na Silver
        df_silver.write.mode("overwrite").saveAsTable(f"silver_{tabela}")
        print(f" {tabela}: Limpa e processada a alta velocidade.")
        
    except Exception as e:
        print(f" Erro em {tabela}: {e}")

print(" Camada Prata finalizada e pronta para cruzamentos.")
