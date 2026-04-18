CREATE DATABASE sisgesc_universitario;
use sisgesc_universitario;
CREATE TABLE `pessoa` (
  `pk_pessoa` integer PRIMARY KEY AUTO_INCREMENT,
  `nome` varchar(150) NOT NULL,
  `rg` varchar(20) UNIQUE NOT NULL,
  `cpf` char(14) UNIQUE NOT NULL,
  `data_nascimento` date NOT NULL,
  `genero` varchar(20),
  `estado_civil` varchar(30),
  `email_pessoal` varchar(100) NOT NULL,
  `titulo_eleitor` char(12) UNIQUE,
  `telefone_pessoal` varchar(15),
  `telefone_emergencia` varchar(15) NOT NULL
);

CREATE TABLE `endereco` (
  `pk_endereco` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer NOT NULL,
  `logradouro` varchar(150) NOT NULL,
  `bairro` varchar(50) NOT NULL,
  `cidade` varchar(50) NOT NULL,
  `uf` char(2) NOT NULL,
  `cep` char(9) NOT NULL
);

CREATE TABLE `dependente` (
  `pk_dependente` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer NOT NULL,
  `nome_dependente` varchar(150) NOT NULL,
  `cpf_dependente` char(14) UNIQUE,
  `grau_parentesco` varchar(30) NOT NULL
);

CREATE TABLE `dados_bancarios` (
  `pk_banco` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer NOT NULL,
  `codigo_banco` char(3),
  `agencia` varchar(10),
  `conta` varchar(20),
  `tipo_conta` varchar(20)
);

CREATE TABLE `formacao_academica` (
  `pk_formacao_academica` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer NOT NULL,
  `nivel_formacao` varchar(50) NOT NULL,
  `instituicao` varchar(150) NOT NULL,
  `ano_conclusao` integer NOT NULL
);

CREATE TABLE `usuario` (
  `pk_usuario` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer NOT NULL,
  `login` varchar(100) UNIQUE NOT NULL,
  `senha_hash` varchar(255) NOT NULL,
  `status_conta` boolean DEFAULT true,
  `ultimo_acesso` timestamp,
  `data_criacao` timestamp DEFAULT (now())
);

CREATE TABLE `perfil` (
  `pk_perfil` integer PRIMARY KEY AUTO_INCREMENT,
  `tipo_perfil` varchar(50) NOT NULL,
  `descricao_perfil` text
);

CREATE TABLE `usuario_perfil` (
  `fk_usuario` integer NOT NULL,
  `fk_perfil` integer NOT NULL,
  PRIMARY KEY (`fk_usuario`, `fk_perfil`)
);

CREATE TABLE `log_auditoria` (
  `pk_log` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_usuario` integer,
  `tabela_afetada` varchar(50),
  `registro_id` integer,
  `acao` varchar(20),
  `valor_antigo` text,
  `valor_novo` text,
  `data_evento` timestamp DEFAULT (now())
);

CREATE TABLE `departamento` (
  `pk_depto` integer PRIMARY KEY AUTO_INCREMENT,
  `nome_depto` varchar(100) NOT NULL,
  `sigla_depto` char(5),
  `centro_academico` varchar(100)
);

CREATE TABLE `cargo` (
  `pk_cargo` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_depto` integer NOT NULL,
  `titulacao_cargo` varchar(50) NOT NULL,
  `regime_trabalho` varchar(30) NOT NULL,
  `salario_base` decimal(12,2) NOT NULL
);

CREATE TABLE `funcionario` (
  `pk_matricula_funcional` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer NOT NULL,
  `fk_cargo` integer NOT NULL,
  `data_admissao` date NOT NULL,
  `email_institucional` varchar(100) UNIQUE NOT NULL,
  `tipo_vinculo` ENUM ('clt', 'pj', 'estagiario', 'terceirizado'),
  `status_atual` ENUM ('ativo', 'afastado', 'encerrado', 'ferias')
);

CREATE TABLE `dados_trabalhistas` (
  `pk_dados_trabalhistas` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_matricula` integer,
  `numero_ctps` varchar(20) NOT NULL,
  `serie_ctps` varchar(10),
  `uf_ctps` char(2),
  `pis_pasep` char(11) UNIQUE NOT NULL,
  `categoria_esocial` char(3),
  `cnh_numero` varchar(15),
  `cnh_categoria` char(2)
);

CREATE TABLE `professor` (
  `pk_professor` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer NOT NULL,
  `fk_cargo` integer NOT NULL,
  `fk_coordenador` integer,
  `titulacao` varchar(50),
  `conhecimento_profissional` text,
  `descricao` text,
  `lattes_url` varchar(255)
);

CREATE TABLE `progressao_docente` (
  `pk_progressao` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_professor` integer NOT NULL,
  `nivel_anterior` varchar(30),
  `nivel_novo` varchar(30),
  `data_mudanca` date NOT NULL,
  `portaria_documento` varchar(100)
);

CREATE TABLE `avaliacao_desempenho` (
  `pk_avaliacao` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_avaliado` integer,
  `fk_avaliador` integer,
  `data_avaliacao` date,
  `nota_desempenho` decimal(4,2),
  `comentarios_feedback` text
);

CREATE TABLE `ocorrencia_disciplinar` (
  `pk_ocorrencia` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_matricula` integer,
  `tipo_ocorrencia` varchar(50),
  `data_ocorrencia` date,
  `descricao_fato` text
);

CREATE TABLE `substituicao_chefia` (
  `pk_substituicao` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_titular` integer,
  `fk_substituto` integer,
  `data_inicio` date NOT NULL,
  `data_fim` date,
  `motivo_substituicao` varchar(100),
  `gera_onus_financeiro` boolean DEFAULT false
);

CREATE TABLE `curso` (
  `pk_curso` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_depto` integer NOT NULL,
  `nome_curso` varchar(100) NOT NULL,
  `tipo_curso` varchar(50),
  `tempo_curso` integer,
  `ambiente_curso` varchar(20)
);

CREATE TABLE `professor_curso` (
  `fk_professor` integer NOT NULL,
  `fk_curso` integer NOT NULL,
  PRIMARY KEY (`fk_professor`, `fk_curso`)
);

CREATE TABLE `coordenador` (
  `pk_coodernador` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_curso` integer,
  `fk_professor` integer,
  `bonus` integer,
  `horario_atendimento` datetime
);

CREATE TABLE `aluno` (
  `pk_aluno` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer NOT NULL,
  `fk_curso` integer NOT NULL,
  `ra` char(11) UNIQUE NOT NULL,
  `data_primeiro_ingresso` date NOT NULL
);

CREATE TABLE `disciplina` (
  `pk_disciplina` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_curso` integer NOT NULL,
  `fk_depto` integer,
  `nome_disciplina` varchar(100) NOT NULL,
  `carga_horaria_semestral` integer NOT NULL
);

CREATE TABLE `turma` (
  `pk_turma` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_disciplina` integer,
  `fk_professor` integer,
  `fk_coordenador` integer,
  `periodo_letivo` varchar(10) NOT NULL,
  `turno` varchar(20)
);

CREATE TABLE `matricula_curso` (
  `pk_matricula_curso` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_aluno` integer NOT NULL,
  `fk_curso` integer NOT NULL,
  `data_ingresso` date NOT NULL,
  `status_academico` varchar(30) DEFAULT 'Ativo',
  `notas_global` decimal(4,2) DEFAULT 0,
  `faltas_total` integer DEFAULT 0
);

CREATE TABLE `matricula_turma` (
  `pk_matricula_turma` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_aluno` integer NOT NULL,
  `fk_turma` integer NOT NULL,
  `data_matricula` date
);

CREATE TABLE `motivo_reprovacao` (
  `pk_motivo` integer PRIMARY KEY AUTO_INCREMENT,
  `descricao` varchar(100) NOT NULL
);

CREATE TABLE `desempenho` (
  `pk_desempenho` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_matricula_turma` integer NOT NULL,
  `nota_p1` decimal(4,2) DEFAULT 0,
  `nota_p2` decimal(4,2) DEFAULT 0,
  `fk_motivo_reprovacao` integer,
  `feedback_melhoria` text,
  `pontos_fortes` text
);

CREATE TABLE `evento_calendario` (
  `pk_evento` integer PRIMARY KEY AUTO_INCREMENT,
  `nome_evento` varchar(100),
  `data_evento` date NOT NULL,
  `tipo_evento` varchar(30),
  `fk_unidade_afetada` integer
);

CREATE TABLE `projeto_academico` (
  `pk_projeto` integer PRIMARY KEY AUTO_INCREMENT,
  `titulo_projeto` varchar(255) NOT NULL,
  `tipo_projeto` varchar(50),
  `data_inicio` date,
  `data_fim` date,
  `valor_financiamento` decimal(15,2)
);

CREATE TABLE `bolsa_estudo` (
  `pk_bolsa` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer,
  `fk_projeto` integer,
  `tipo_bolsa` varchar(50),
  `valor_mensal` decimal(10,2) NOT NULL,
  `data_vigencia_inicio` date,
  `data_vigencia_fim` date
);

CREATE TABLE `producao_cientifica` (
  `pk_producao` integer PRIMARY KEY AUTO_INCREMENT,
  `titulo_producao` varchar(255) NOT NULL,
  `tipo_producao` varchar(50),
  `ano_publicacao` integer,
  `issn_isbn` varchar(20),
  `doi_link` varchar(255)
);

CREATE TABLE `autor_producao` (
  `fk_producao` integer,
  `fk_pessoa` integer,
  `eh_autor_principal` boolean DEFAULT false,
  PRIMARY KEY (`fk_producao`, `fk_pessoa`)
);

CREATE TABLE `pessoa_juridica` (
  `pk_juridica` integer PRIMARY KEY AUTO_INCREMENT,
  `nome_fantasia` varchar(100) NOT NULL,
  `cnpj` varchar(15) UNIQUE NOT NULL,
  `telefone_juridica` varchar(15) NOT NULL,
  `email_juridica` varchar(100) NOT NULL
);

CREATE TABLE `contratos_educacionais` (
  `pk_contrato` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_matricula_curso` integer NOT NULL,
  `porcentagem_desconto` decimal(5,2) NOT NULL,
  `valor_total_mensalidade` decimal(10,2) NOT NULL,
  `data_inicio` date,
  `data_fim` date,
  `status_contrato` ENUM ('ativo', 'encerrado', 'cancelado') NOT NULL DEFAULT 'ativo'
);

CREATE TABLE `mensalidade` (
  `pk_mensalidade` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_contrato` integer NOT NULL,
  `parcela` integer NOT NULL,
  `valor_parcela` decimal(10,2) NOT NULL,
  `data_limite` date NOT NULL,
  `status_mensalidade` ENUM ('pendente', 'pago', 'atrasado') NOT NULL DEFAULT 'pendente'
);

CREATE TABLE `inadimplencia` (
  `pk_atraso` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_mensalidade` integer NOT NULL,
  `data_atraso` date,
  `juros` decimal(10,2) NOT NULL DEFAULT 0,
  `multa` decimal(10,2) NOT NULL DEFAULT 0
);

CREATE TABLE `contas_receber` (
  `pk_receber` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer NOT NULL,
  `valor_receber` decimal(10,2) NOT NULL,
  `tipo_receber` ENUM ('juros', 'multa', 'dp', 'matricula', 'rematricula') NOT NULL DEFAULT 'matricula',
  `vencimento_receber` date NOT NULL,
  `status_receber` ENUM ('pendente', 'pago', 'atrasado') NOT NULL DEFAULT 'pendente'
);

CREATE TABLE `contas_receber_mensalidade` (
  `fk_receber` integer NOT NULL,
  `fk_mensalidade` integer NOT NULL,
  PRIMARY KEY (`fk_receber`, `fk_mensalidade`)
);

CREATE TABLE `pagamento_recebido` (
  `pk_pagamento_recebido` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_receber` integer NOT NULL,
  `valor_pago` decimal(10,2) NOT NULL,
  `forma_pagamento_recebido` ENUM ('pix', 'debito', 'credito', 'dinheiro', 'boleto', 'cheque') NOT NULL DEFAULT 'credito',
  `data_pagamento_recebido` timestamp DEFAULT (now())
);

CREATE TABLE `fornecedor` (
  `pk_fornecedor` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_juridica` integer UNIQUE NOT NULL
);

CREATE TABLE `contas_pagar` (
  `pk_pagar` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_matricula` integer,
  `fk_fornecedor` integer,
  `status_pagar` ENUM ('pendente', 'pago', 'atrasado') NOT NULL DEFAULT 'pendente',
  `valor_pagar_total` decimal(10,2) NOT NULL,
  `descricao` varchar(60),
  `data_limite` date NOT NULL
);

CREATE TABLE `pagamento` (
  `pk_pagamento` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pagar` integer NOT NULL,
  `forma_pagamento` ENUM ('pix', 'debito', 'credito', 'dinheiro', 'boleto', 'cheque') NOT NULL DEFAULT 'credito',
  `valor_pago` decimal(10,2) NOT NULL,
  `data_pagamento` timestamp DEFAULT (now()),
  `status_pagamento` ENUM ('pendente', 'pago', 'atrasado') NOT NULL DEFAULT 'pago'
);

CREATE TABLE `folha_pagamento` (
  `pk_folha_pagamento` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_matricula` integer NOT NULL,
  `mes_referencia` integer NOT NULL,
  `ano_referencia` integer NOT NULL,
  `data_emissao` timestamp DEFAULT (now()),
  `valor_liquido` decimal(12,2) NOT NULL
);

CREATE TABLE `rubrica` (
  `pk_rubrica` integer PRIMARY KEY AUTO_INCREMENT,
  `nome_rubrica` varchar(100) NOT NULL,
  `tipo_rubrica` char(1)
);

CREATE TABLE `item_folha` (
  `pk_item_folha` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_folha_pagamento` integer NOT NULL,
  `fk_rubrica` integer NOT NULL,
  `valor` decimal(12,2) NOT NULL
);

CREATE TABLE `beneficio` (
  `pk_beneficio` integer PRIMARY KEY AUTO_INCREMENT,
  `nome_beneficio` varchar(100) NOT NULL,
  `provedor` varchar(100),
  `valor_padrao` decimal(12,2)
);

CREATE TABLE `vinculo_beneficio` (
  `fk_matricula` integer NOT NULL,
  `fk_beneficio` integer NOT NULL,
  `data_adesao` date NOT NULL,
  `valor_desconto_colaborador` decimal(12,2),
  PRIMARY KEY (`fk_matricula`, `fk_beneficio`)
);

CREATE TABLE `sindicato` (
  `pk_sindicato` integer PRIMARY KEY AUTO_INCREMENT,
  `nome_sindicato` varchar(150),
  `cnpj` char(18) UNIQUE,
  `percentual_contribuicao` decimal(5,2)
);

CREATE TABLE `vinculo_sindicato` (
  `fk_matricula` integer,
  `fk_sindicato` integer,
  `data_filiacao` date,
  PRIMARY KEY (`fk_matricula`, `fk_sindicato`)
);

CREATE TABLE `registro_ponto` (
  `pk_ponto` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_matricula` integer NOT NULL,
  `data_registro` date NOT NULL,
  `hora_entrada` time NOT NULL,
  `hora_saida` time,
  `justificativa` text
);

CREATE TABLE `banco_horas` (
  `pk_banco_horas` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_matricula` integer,
  `mes_referencia` integer,
  `ano_referencia` integer,
  `saldo_horas_minutos` integer,
  `horas_compensadas` integer
);

CREATE TABLE `exame_medico` (
  `pk_exame` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_matricula` integer NOT NULL,
  `tipo_exame` varchar(50),
  `data_exame` date NOT NULL,
  `resultado` varchar(30) NOT NULL,
  `crm_medico` varchar(20)
);

CREATE TABLE `afastamento` (
  `pk_afastamento` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_matricula` integer NOT NULL,
  `tipo_afastamento` varchar(50) NOT NULL,
  `data_inicio` date NOT NULL,
  `data_fim` date,
  `cid_codigo` varchar(10)
);

CREATE TABLE `controle_ferias` (
  `pk_ferias` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_matricula` integer,
  `inicio_periodo_aquisitivo` date NOT NULL,
  `fim_periodo_aquisitivo` date NOT NULL,
  `limite_concessivo` date NOT NULL,
  `dias_direitos` integer DEFAULT 30,
  `saldo_dias` integer
);

CREATE TABLE `ativo_equipamento` (
  `pk_ativo` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_matricula` integer NOT NULL,
  `tipo_equipamento` varchar(50),
  `modelo` varchar(100),
  `numero_serie` varchar(100) UNIQUE NOT NULL,
  `data_entrega` date NOT NULL,
  `data_devolucao` date
);

CREATE TABLE `espaco_fisico` (
  `pk_espaco` integer PRIMARY KEY AUTO_INCREMENT,
  `nome_espaco` varchar(100) NOT NULL,
  `bloco` char(5) NOT NULL,
  `andar` integer,
  `capacidade_pessoas` integer,
  `tipo_uso` varchar(50)
);

CREATE TABLE `alocacao_ativo_local` (
  `fk_ativo` integer,
  `fk_espaco` integer,
  `data_instalacao` date DEFAULT (now()),
  PRIMARY KEY (`fk_ativo`, `fk_espaco`)
);

CREATE TABLE `parceiro_comercial` (
  `pk_parceiro` integer PRIMARY KEY AUTO_INCREMENT,
  `nome_fantasia` varchar(150) NOT NULL,
  `cnpj` char(18) UNIQUE NOT NULL,
  `tipo_servico` varchar(50),
  `telefone_contato` varchar(15)
);

CREATE TABLE `contrato_espaco` (
  `pk_contrato` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_parceiro` integer,
  `fk_espaco` integer,
  `valor_aluguel_mensal` decimal(12,2),
  `data_inicio` date NOT NULL,
  `data_fim` date,
  `status_contrato` varchar(20)
);

CREATE TABLE `empresa_terceirizada` (
  `pk_empresa` integer PRIMARY KEY AUTO_INCREMENT,
  `nome_fantasia` varchar(150),
  `cnpj` char(18) UNIQUE,
  `contato_gestor` varchar(100)
);

CREATE TABLE `colaborador_terceirizado` (
  `pk_terceirizado` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer,
  `fk_empresa` integer,
  `funcao_exercida` varchar(100),
  `data_inicio_prestacao` date,
  `cartao_acesso_id` varchar(50)
);

CREATE TABLE `veiculo_estacionamento` (
  `pk_veiculo` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer,
  `placa` char(7) UNIQUE NOT NULL,
  `modelo` varchar(50),
  `cor` varchar(20),
  `selo_estacionamento` varchar(50) UNIQUE
);

CREATE TABLE `processo_seletivo` (
  `pk_processo` integer PRIMARY KEY AUTO_INCREMENT,
  `titulo_vaga` varchar(150) NOT NULL,
  `tipo_vaga` varchar(50),
  `data_abertura` date NOT NULL,
  `data_fechamento` date,
  `status_processo` varchar(20)
);

CREATE TABLE `candidato` (
  `pk_candidato` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer,
  `fk_processo` integer,
  `curriculo_url` varchar(255),
  `resultado_final` varchar(30)
);

CREATE TABLE `entrevista_desligamento` (
  `pk_desligamento` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_matricula` integer,
  `data_desligamento` date NOT NULL,
  `motivo_saida` varchar(100),
  `entrevista_feedback` text,
  `devolveu_ativos` boolean DEFAULT false
);

CREATE TABLE `documento_digital` (
  `pk_documento` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer,
  `tipo_documento` varchar(50),
  `url_arquivo` varchar(255) NOT NULL,
  `data_upload` timestamp DEFAULT (now())
);

CREATE TABLE `intercambio_internacional` (
  `pk_intercambio` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer,
  `pais_destino` char(2),
  `instituicao_destino` varchar(150),
  `data_partida` date,
  `data_retorno` date,
  `ajuda_custo_total` decimal(12,2)
);

CREATE TABLE `premiacao_honraria` (
  `pk_premio` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer,
  `nome_premio` varchar(150) NOT NULL,
  `data_concessao` date,
  `descricao_conquista` text
);

CREATE TABLE `conselho_colegiado` (
  `pk_conselho` integer PRIMARY KEY AUTO_INCREMENT,
  `nome_conselho` varchar(100) NOT NULL,
  `fk_depto_gestor` integer
);

CREATE TABLE `membro_conselho` (
  `pk_membro` integer PRIMARY KEY AUTO_INCREMENT,
  `fk_pessoa` integer,
  `fk_conselho` integer,
  `cargo_conselho` varchar(50),
  `data_inicio_mandato` date,
  `data_fim_mandato` date
);

ALTER TABLE `endereco` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `dependente` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `dados_bancarios` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `formacao_academica` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `usuario` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `usuario_perfil` ADD FOREIGN KEY (`fk_usuario`) REFERENCES `usuario` (`pk_usuario`);

ALTER TABLE `usuario_perfil` ADD FOREIGN KEY (`fk_perfil`) REFERENCES `perfil` (`pk_perfil`);

ALTER TABLE `log_auditoria` ADD FOREIGN KEY (`fk_usuario`) REFERENCES `usuario` (`pk_usuario`);

ALTER TABLE `cargo` ADD FOREIGN KEY (`fk_depto`) REFERENCES `departamento` (`pk_depto`);

ALTER TABLE `funcionario` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `funcionario` ADD FOREIGN KEY (`fk_cargo`) REFERENCES `cargo` (`pk_cargo`);

ALTER TABLE `dados_trabalhistas` ADD FOREIGN KEY (`fk_matricula`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `professor` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `professor` ADD FOREIGN KEY (`fk_cargo`) REFERENCES `cargo` (`pk_cargo`);

ALTER TABLE `progressao_docente` ADD FOREIGN KEY (`fk_professor`) REFERENCES `professor` (`pk_professor`);

ALTER TABLE `avaliacao_desempenho` ADD FOREIGN KEY (`fk_avaliado`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `avaliacao_desempenho` ADD FOREIGN KEY (`fk_avaliador`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `ocorrencia_disciplinar` ADD FOREIGN KEY (`fk_matricula`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `substituicao_chefia` ADD FOREIGN KEY (`fk_titular`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `substituicao_chefia` ADD FOREIGN KEY (`fk_substituto`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `curso` ADD FOREIGN KEY (`fk_depto`) REFERENCES `departamento` (`pk_depto`);

ALTER TABLE `professor_curso` ADD FOREIGN KEY (`fk_professor`) REFERENCES `professor` (`pk_professor`);

ALTER TABLE `professor_curso` ADD FOREIGN KEY (`fk_curso`) REFERENCES `curso` (`pk_curso`);

ALTER TABLE `coordenador` ADD FOREIGN KEY (`fk_curso`) REFERENCES `curso` (`pk_curso`);

ALTER TABLE `coordenador` ADD FOREIGN KEY (`fk_professor`) REFERENCES `professor` (`pk_professor`);

ALTER TABLE `aluno` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `aluno` ADD FOREIGN KEY (`fk_curso`) REFERENCES `curso` (`pk_curso`);

ALTER TABLE `disciplina` ADD FOREIGN KEY (`fk_curso`) REFERENCES `curso` (`pk_curso`);

ALTER TABLE `disciplina` ADD FOREIGN KEY (`fk_depto`) REFERENCES `departamento` (`pk_depto`);

ALTER TABLE `turma` ADD FOREIGN KEY (`fk_disciplina`) REFERENCES `disciplina` (`pk_disciplina`);

ALTER TABLE `turma` ADD FOREIGN KEY (`fk_professor`) REFERENCES `professor` (`pk_professor`);

ALTER TABLE `turma` ADD FOREIGN KEY (`fk_coordenador`) REFERENCES `coordenador` (`pk_coodernador`);

ALTER TABLE `matricula_curso` ADD FOREIGN KEY (`fk_aluno`) REFERENCES `aluno` (`pk_aluno`);

ALTER TABLE `matricula_curso` ADD FOREIGN KEY (`fk_curso`) REFERENCES `curso` (`pk_curso`);

ALTER TABLE `matricula_turma` ADD FOREIGN KEY (`fk_aluno`) REFERENCES `aluno` (`pk_aluno`);

ALTER TABLE `matricula_turma` ADD FOREIGN KEY (`fk_turma`) REFERENCES `turma` (`pk_turma`);

ALTER TABLE `desempenho` ADD FOREIGN KEY (`fk_matricula_turma`) REFERENCES `matricula_turma` (`pk_matricula_turma`);

ALTER TABLE `desempenho` ADD FOREIGN KEY (`fk_motivo_reprovacao`) REFERENCES `motivo_reprovacao` (`pk_motivo`);

ALTER TABLE `evento_calendario` ADD FOREIGN KEY (`fk_unidade_afetada`) REFERENCES `departamento` (`pk_depto`);

ALTER TABLE `bolsa_estudo` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `bolsa_estudo` ADD FOREIGN KEY (`fk_projeto`) REFERENCES `projeto_academico` (`pk_projeto`);

ALTER TABLE `autor_producao` ADD FOREIGN KEY (`fk_producao`) REFERENCES `producao_cientifica` (`pk_producao`);

ALTER TABLE `autor_producao` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `contratos_educacionais` ADD FOREIGN KEY (`fk_matricula_curso`) REFERENCES `matricula_curso` (`pk_matricula_curso`);

ALTER TABLE `mensalidade` ADD FOREIGN KEY (`fk_contrato`) REFERENCES `contratos_educacionais` (`pk_contrato`);

ALTER TABLE `inadimplencia` ADD FOREIGN KEY (`fk_mensalidade`) REFERENCES `mensalidade` (`pk_mensalidade`);

ALTER TABLE `contas_receber` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `contas_receber_mensalidade` ADD FOREIGN KEY (`fk_receber`) REFERENCES `contas_receber` (`pk_receber`);

ALTER TABLE `contas_receber_mensalidade` ADD FOREIGN KEY (`fk_mensalidade`) REFERENCES `mensalidade` (`pk_mensalidade`);

ALTER TABLE `pagamento_recebido` ADD FOREIGN KEY (`fk_receber`) REFERENCES `contas_receber` (`pk_receber`);

ALTER TABLE `fornecedor` ADD FOREIGN KEY (`fk_juridica`) REFERENCES `pessoa_juridica` (`pk_juridica`);

ALTER TABLE `contas_pagar` ADD FOREIGN KEY (`fk_matricula`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `contas_pagar` ADD FOREIGN KEY (`fk_fornecedor`) REFERENCES `fornecedor` (`pk_fornecedor`);

ALTER TABLE `pagamento` ADD FOREIGN KEY (`fk_pagar`) REFERENCES `contas_pagar` (`pk_pagar`);

ALTER TABLE `folha_pagamento` ADD FOREIGN KEY (`fk_matricula`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `item_folha` ADD FOREIGN KEY (`fk_folha_pagamento`) REFERENCES `folha_pagamento` (`pk_folha_pagamento`);

ALTER TABLE `item_folha` ADD FOREIGN KEY (`fk_rubrica`) REFERENCES `rubrica` (`pk_rubrica`);

ALTER TABLE `vinculo_beneficio` ADD FOREIGN KEY (`fk_matricula`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `vinculo_beneficio` ADD FOREIGN KEY (`fk_beneficio`) REFERENCES `beneficio` (`pk_beneficio`);

ALTER TABLE `vinculo_sindicato` ADD FOREIGN KEY (`fk_matricula`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `vinculo_sindicato` ADD FOREIGN KEY (`fk_sindicato`) REFERENCES `sindicato` (`pk_sindicato`);

ALTER TABLE `registro_ponto` ADD FOREIGN KEY (`fk_matricula`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `banco_horas` ADD FOREIGN KEY (`fk_matricula`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `exame_medico` ADD FOREIGN KEY (`fk_matricula`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `afastamento` ADD FOREIGN KEY (`fk_matricula`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `controle_ferias` ADD FOREIGN KEY (`fk_matricula`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `ativo_equipamento` ADD FOREIGN KEY (`fk_matricula`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `alocacao_ativo_local` ADD FOREIGN KEY (`fk_ativo`) REFERENCES `ativo_equipamento` (`pk_ativo`);

ALTER TABLE `alocacao_ativo_local` ADD FOREIGN KEY (`fk_espaco`) REFERENCES `espaco_fisico` (`pk_espaco`);

ALTER TABLE `contrato_espaco` ADD FOREIGN KEY (`fk_parceiro`) REFERENCES `parceiro_comercial` (`pk_parceiro`);

ALTER TABLE `contrato_espaco` ADD FOREIGN KEY (`fk_espaco`) REFERENCES `espaco_fisico` (`pk_espaco`);

ALTER TABLE `colaborador_terceirizado` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `colaborador_terceirizado` ADD FOREIGN KEY (`fk_empresa`) REFERENCES `empresa_terceirizada` (`pk_empresa`);

ALTER TABLE `veiculo_estacionamento` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `candidato` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `candidato` ADD FOREIGN KEY (`fk_processo`) REFERENCES `processo_seletivo` (`pk_processo`);

ALTER TABLE `entrevista_desligamento` ADD FOREIGN KEY (`fk_matricula`) REFERENCES `funcionario` (`pk_matricula_funcional`);

ALTER TABLE `documento_digital` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `intercambio_internacional` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `premiacao_honraria` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `conselho_colegiado` ADD FOREIGN KEY (`fk_depto_gestor`) REFERENCES `departamento` (`pk_depto`);

ALTER TABLE `membro_conselho` ADD FOREIGN KEY (`fk_pessoa`) REFERENCES `pessoa` (`pk_pessoa`);

ALTER TABLE `membro_conselho` ADD FOREIGN KEY (`fk_conselho`) REFERENCES `conselho_colegiado` (`pk_conselho`);
