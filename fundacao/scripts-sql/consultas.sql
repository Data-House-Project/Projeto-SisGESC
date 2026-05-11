-- Para usar o banco de dados
USE sisgesc_universitario;

-- Ficha Completa do Aluno: Mostra o registro, o curso e o RGM
SELECT 
    CONCAT(p.nome, ' ', p.sobrenome) AS nome_completo, 
    a.ra AS Registro_Academico, 
    c.nome_curso, 
    m.pk_matricula_curso AS RGM,
    m.status_academico
FROM pessoa p
JOIN aluno a ON p.pk_pessoa = a.fk_pessoa
JOIN matricula_curso m ON a.pk_aluno = m.fk_aluno
JOIN curso c ON m.fk_curso = c.pk_curso;


-- Relatório de Status: Lista apenas alunos com status 'ATIVO' com o nome do curso
SELECT 
    CONCAT(p.nome, ' ', p.sobrenome) AS nome_completo, 
    a.ra, 
    c.nome_curso 
FROM aluno a
JOIN pessoa p ON a.fk_pessoa = p.pk_pessoa
JOIN matricula_curso mc ON mc.fk_aluno = a.pk_aluno
JOIN curso c ON mc.fk_curso = c.pk_curso
WHERE mc.status_academico = 'ativo';


-- Desempenho Médio por Turma e Professor ( a visão da Coordenação)
SELECT 
    d.nome_disciplina,
    t.periodo_letivo,
    t.turno,
    CONCAT(p_prof.nome, ' ', p_prof.sobrenome) AS nome_professor,
    COUNT(mt.fk_aluno) AS qtd_alunos_matriculados,
    ROUND(AVG(mc.notas_global), 2) AS media_global_turma
FROM turma t
INNER JOIN disciplina d ON t.fk_disciplina = d.pk_disciplina
INNER JOIN professor prof ON t.fk_professor = prof.pk_professor
INNER JOIN pessoa p_prof ON prof.fk_pessoa = p_prof.pk_pessoa
LEFT JOIN matricula_turma mt ON mt.fk_turma = t.pk_turma
LEFT JOIN matricula_curso mc ON mc.fk_aluno = mt.fk_aluno
GROUP BY 
    d.nome_disciplina, t.periodo_letivo, t.turno, p_prof.nome, p_prof.sobrenome
ORDER BY 
    media_global_turma DESC;


-- Cruzamento Financeiro x RH x Aluno: Bons Pagadores (valor parcela > 3000)
SELECT 
    CONCAT(p.nome, ' ', p.sobrenome) AS nome_completo, 
    a.ra,
    m.status_mensalidade AS status_financeiro, 
    SUM(m.valor_parcela) AS total_pago
FROM pessoa p
JOIN aluno a ON p.pk_pessoa = a.fk_pessoa
JOIN matricula_curso mc ON a.pk_aluno = mc.fk_aluno
JOIN contratos_educacionais ce ON mc.pk_matricula_curso = ce.fk_matricula_curso
JOIN mensalidade m ON ce.pk_contrato = m.fk_contrato
WHERE m.status_mensalidade = 'pago'
GROUP BY p.pk_pessoa, a.ra, m.status_mensalidade
HAVING SUM(m.valor_parcela) > 3000;


-- Alunos atrasados e o valor total da dívida
SELECT 
    a.ra,
    CONCAT(p.nome, ' ', p.sobrenome) AS nome_aluno,
    COALESCE(p.telefone_pessoal, p.telefone_emergencia, 'Contato não cadastrado') AS telefone_contato,
    m.status_mensalidade,
    SUM(m.valor_parcela) AS total_divida_atrasada
FROM aluno a
INNER JOIN pessoa p ON a.fk_pessoa = p.pk_pessoa
INNER JOIN matricula_curso mc ON mc.fk_aluno = a.pk_aluno
INNER JOIN contratos_educacionais ce ON mc.pk_matricula_curso = ce.fk_matricula_curso
INNER JOIN mensalidade m ON ce.pk_contrato = m.fk_contrato
WHERE m.status_mensalidade = 'atrasado'
GROUP BY 
    a.ra, 
    p.nome, 
    p.sobrenome, 
    p.telefone_pessoal, 
    p.telefone_emergencia, 
    mc.pk_matricula_curso, 
    m.status_mensalidade 
ORDER BY total_divida_atrasada DESC;


-- Custo de Folha de Pagamento por Departamento
SELECT 
    d.nome_depto,
    fp.mes_referencia,
    fp.ano_referencia,
    COUNT(DISTINCT f.pk_matricula_funcional) AS total_colaboradores_ativos,
    CONCAT('R$ ', FORMAT(SUM(fp.valor_liquido), 2, 'pt_BR')) AS custo_total_folha,
    CONCAT('R$ ', FORMAT(AVG(fp.valor_liquido), 2, 'pt_BR')) AS media_salarial_depto
FROM departamento d
INNER JOIN cargo c ON c.fk_depto = d.pk_depto
INNER JOIN funcionario f ON f.fk_cargo = c.pk_cargo
INNER JOIN folha_pagamento fp ON fp.fk_matricula = f.pk_matricula_funcional
WHERE f.status_atual = 'ativo' 
  AND fp.mes_referencia = 5 -- Exemplo: Maio
  AND fp.ano_referencia = 2026 -- Exemplo: 2026
GROUP BY d.nome_depto, fp.mes_referencia, fp.ano_referencia
ORDER BY d.nome_depto;



-- Cenário 1: ERRO DE INTEGRAÇÃO FINANCEIRA (ROLLBACK)
-- Simula erro na geração de parcela. O banco desfaz a inserção para evitar dados inconsistentes.
START TRANSACTION;
INSERT INTO mensalidade (fk_contrato, parcela, valor_parcela, data_limite, status_mensalidade) 
VALUES (1, 5, 1500.00, '2026-06-10', 'pendente');

-- Simulação: Ocorreu uma queda de rede antes do processo terminar.
ROLLBACK; 

-- Cenário 2: SUCESSO DE TRANSAÇÃO (COMMIT)
-- Recebimento de mensalidade e registro imediato no caixa.
START TRANSACTION;
UPDATE mensalidade SET status_mensalidade = 'pago' WHERE pk_mensalidade = 1;
INSERT INTO pagamento_recebido (fk_receber, valor_pago, forma_pagamento_recebido) VALUES (1, 1200.00, 'pix');
COMMIT;

-- Cenário 4: ERRO NA MATRÍCULA DE NOVO ALUNO (ROLLBACK de integridade)
-- Tenta cadastrar uma pessoa e transformá-la em aluno. Se o vínculo com o curso falhar, 
-- a "pessoa" não deve ser criada para não gerar lixo no banco.
START TRANSACTION;

INSERT INTO pessoa (nome, sobrenome, rg, cpf, data_nascimento, fk_nacionalidade, email_pessoal, telefone_emergencia)
VALUES ('Candidato', 'Teste', '11.222.333-4', '123.456.789-00', '2000-01-01', 1, 'teste@email.com', '11999999999');

-- Salvamos o ID gerado para usar no próximo passo
SET @last_pessoa_id = LAST_INSERT_ID();

INSERT INTO aluno (fk_pessoa, ra, data_primeiro_ingresso)
VALUES (@last_pessoa_id, '202610001', '2026-02-01');

-- Simulação de Erro: O curso escolhido está lotado ou inexistente (Erro de FK forçado)
-- Aqui o rollback garante que nem a 'Pessoa' nem o 'Aluno' fiquem no banco sem matrícula.
ROLLBACK;

-- Cenário 5: ATUALIZAÇÃO DE NOTAS E STATUS (conservação de dados)
-- Se alterarmos as notas de um aluno mas falharmos ao atualizar a média global na matrícula, 
-- devemos desfazer tudo para o histórico acadêmico não ficar divergente.
START TRANSACTION;

UPDATE desempenho SET nota_p1 = 8.5, nota_p2 = 7.0 WHERE fk_matricula_turma = 1;

-- Simulação de erro no cálculo da média global ou queda do servidor
ROLLBACK;


-- Otimização de busca em tabelas com grande volume de dados.
-- Verificação de custo sem índice
EXPLAIN SELECT * FROM dependente WHERE grau_parentesco = 'Filho(a)';

-- Criação de índice para otimizar buscas frequentes do RH
CREATE INDEX idx_grau_parentesco ON dependente(grau_parentesco);

-- Verificação de custo com índice
-- O banco agora localiza o registro sem percorrer a tabela inteira.
EXPLAIN SELECT * FROM dependente WHERE grau_parentesco = 'Filho(a)';
