import mysql.connector
from faker import Faker
import random
from dotenv import load_dotenv
import os

load_dotenv(dotenv_path='.env')

fake = Faker('pt_BR')

config = {
    'host': os.getenv('DB_HOST'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'port': int(os.getenv('DB_PORT')), 
    'database': os.getenv('DB_NAME'),
}

def gerar_massa():
    conn = None 
    try:
        conn = mysql.connector.connect(**config)
        cursor = conn.cursor()
        print("Conectado ao Aiven. Iniciando geração...")

        nacionalidades = [('Brasil', 'Brasileiro'), ('Portugal', 'Português')]
        for pais, gentilico in nacionalidades:
            cursor.execute("INSERT INTO nacionalidade (pais, gentilico) VALUES (%s, %s)", (pais, gentilico))
        
        fk_nac = 1

        print("Inserindo pessoas...")
        for _ in range(30):
            nome = fake.first_name()
            sobrenome = fake.last_name()
            cursor.execute("""
                INSERT INTO pessoa (nome, sobrenome, rg, cpf, data_nascimento, genero, 
                                  estado_civil, fk_nacionalidade, email_pessoal, telefone_emergencia)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (nome, sobrenome, fake.rg(), fake.cpf(), fake.date_of_birth(minimum_age=18), 
                  random.choice(['F', 'M']), 'Solteiro', fk_nac, fake.email(), 
                  fake.cellphone_number()[:15]))

            print(f"Inserindo pessoa: {nome} {sobrenome}, RG: {fake.rg()}, CPF: {fake.cpf()}, Email: {fake.email()}, Telefone: {fake.cellphone_number()[:15]}")

        cursor.execute("INSERT INTO departamento (nome_depto, sigla_depto) VALUES ('Tecnologia', 'TI')")
        fk_depto = cursor.lastrowid
        
        cursor.execute("""
            INSERT INTO curso (fk_depto, nome_curso, tipo_curso, tempo_curso, ambiente_curso)
            VALUES (%s, 'Análise e Desenvolvimento de Sistemas', 'Graduação', 5, 'Híbrido')
        """, (fk_depto,))
        fk_curso = cursor.lastrowid

        cursor.execute("SELECT pk_pessoa FROM pessoa ORDER BY pk_pessoa DESC LIMIT 20")
        pessoas = cursor.fetchall()

        for (id_p,) in pessoas:
            ra = f"2026{random.randint(10000, 99999)}"
            cursor.execute("INSERT INTO aluno (fk_pessoa, ra, data_primeiro_ingresso) VALUES (%s, %s, '2026-02-01')", (id_p, ra))
            fk_aluno = cursor.lastrowid

            cursor.execute("""
                INSERT INTO matricula_curso (fk_aluno, fk_curso, data_ingresso, status_academico, notas_global, faltas_total)
                VALUES (%s, %s, '2026-02-15', 'ativo', %s, %s)
            """, (fk_aluno, fk_curso, random.uniform(4.0, 9.5), random.randint(0, 15)))

        conn.commit()
        print("Massa de dados inserida com sucesso no Aiven.")

    except mysql.connector.Error as db_err:
        print(f"Erro de conexão ao banco de dados: {db_err}")
    except Exception as e:
        print(f"Erro: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    gerar_massa()