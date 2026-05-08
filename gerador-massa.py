import mysql.connector
from faker import Faker
import random
from dotenv import load_dotenv
import os
from datetime import datetime, timedelta

load_dotenv(dotenv_path='.env')

fake = Faker('pt_BR')

config = {
    'host': os.getenv('DB_HOST'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'port': int(os.getenv('DB_PORT', 25090)), 
    'database': os.getenv('DB_NAME'),
}

def gerar_massa():
    conn = None 
    try:
        conn = mysql.connector.connect(**config)
        cursor = conn.cursor()
        print("🔌 Conectado ao Aiven. Verificando idempotência...")

        cursor.execute("SELECT COUNT(*) FROM pessoa")
        qtd_pessoas = cursor.fetchone()[0]

        if qtd_pessoas > 5: 
            print(" O banco já possui dados gerados! Abortando para evitar duplicidade (-20 pontos).")
            return

        print("🚀 Iniciando geração de massa de dados completa...")

        # NACIONALIDADES E DEPARTAMENTOS
        cursor.execute("INSERT INTO nacionalidade (pais, gentilico) VALUES ('Brasil', 'Brasileiro')")
        fk_nac = cursor.lastrowid

        cursor.execute("INSERT INTO departamento (nome_depto, sigla_depto) VALUES ('Tecnologia', 'TI')")
        fk_depto = cursor.lastrowid
        
        cursor.execute("""
            INSERT INTO cargo (fk_depto, titulacao_cargo, regime_trabalho, salario_base) 
            VALUES (%s, 'Professor Titular', '40h', 6500.00)
        """, (fk_depto,))
        fk_cargo = cursor.lastrowid

        print(" Inserindo Pessoas...")
        ids_pessoas = []
        for _ in range(40):
            nome = fake.first_name()
            sobrenome = fake.last_name()
            cursor.execute("""
                INSERT INTO pessoa (nome, sobrenome, rg, cpf, data_nascimento, genero, 
                                  estado_civil, fk_nacionalidade, email_pessoal, telefone_emergencia)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (nome, sobrenome, fake.rg(), fake.cpf(), fake.date_of_birth(minimum_age=18, maximum_age=60), 
                  random.choice(['F', 'M']), 'Solteiro', fk_nac, fake.email(), fake.cellphone_number()[:15]))
            ids_pessoas.append(cursor.lastrowid)
            
        print(" Gerando Módulo RH...")
        for i in range(5):
            id_func = ids_pessoas[i]
            cursor.execute("""
                INSERT INTO funcionario (fk_pessoa, fk_cargo, data_admissao, email_institucional, tipo_vinculo, status_atual) 
                VALUES (%s, %s, '2023-01-15', %s, 'clt', 'ativo')
            """, (id_func, fk_cargo, f"func{i}@sisgesc.edu.br"))
            fk_matricula = cursor.lastrowid
           
            cursor.execute("""
                INSERT INTO folha_pagamento (fk_matricula, mes_referencia, ano_referencia, valor_liquido)
                VALUES (%s, %s, %s, %s)
            """, (fk_matricula, datetime.now().month, datetime.now().year, 5800.00))

        cursor.execute("""
            INSERT INTO curso (fk_depto, nome_curso, tipo_curso, tempo_curso, ambiente_curso)
            VALUES (%s, 'Ciência da Computação', 'Bacharelado', 8, 'Presencial')
        """, (fk_depto,))
        fk_curso = cursor.lastrowid

        print(" Gerando Módulo Acadêmico e Financeiro...")
        for i in range(5, 35): # 30 alunos
            id_aluno_pessoa = ids_pessoas[i]
            ra = f"2026{random.randint(10000, 99999)}"
            
            # Cria o Aluno
            cursor.execute("INSERT INTO aluno (fk_pessoa, ra, data_primeiro_ingresso) VALUES (%s, %s, '2026-02-01')", (id_aluno_pessoa, ra))
            fk_aluno = cursor.lastrowid

            # Cria a Matrícula
            notas = random.uniform(3.0, 9.5)
            faltas = random.randint(0, 20)
            cursor.execute("""
                INSERT INTO matricula_curso (fk_aluno, fk_curso, data_ingresso, status_academico, notas_global, faltas_total)
                VALUES (%s, %s, '2026-02-15', 'ativo', %s, %s)
            """, (fk_aluno, fk_curso, float(notas), faltas))
            fk_matricula_curso = cursor.lastrowid

            # Cria o Contrato Educacional
            valor_mensal = 1200.00
            cursor.execute("""
                INSERT INTO contratos_educacionais (fk_matricula_curso, porcentagem_desconto, valor_total_mensalidade, data_inicio, data_fim)
                VALUES (%s, 0, %s, '2026-02-01', '2026-12-31')
            """, (fk_matricula_curso, valor_mensal))
            fk_contrato = cursor.lastrowid

            # Gera 3 Mensalidades para cada aluno
            for parcela in range(1, 4):
                if notas < 6.0 and faltas > 10 and parcela == 3:
                    status_mensalidade = 'atrasado'
                else:
                    status_mensalidade = 'pago'
                
                cursor.execute("""
                    INSERT INTO mensalidade (fk_contrato, parcela, valor_parcela, data_limite, status_mensalidade)
                    VALUES (%s, %s, %s, %s, %s)
                """, (fk_contrato, parcela, valor_mensal, f"2026-{parcela+1:02d}-10", status_mensalidade))

        conn.commit()
        print(" Massa de dados inserida com sucesso no Aiven, todas as queries agora retornarão dados.")

    except mysql.connector.Error as db_err:
        print(f"❌ Erro de conexão ao banco de dados: {db_err}")
    except Exception as e:
        print(f"❌ Erro: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    gerar_massa()
