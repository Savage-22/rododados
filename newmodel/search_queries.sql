-- ================================
-- Receita total por rota ✅
-- ================================
SELECT 
  r.id_route,
  cp.name AS company_name,
  r.route_code,
  r.name as route_name,
  (SELECT 
    bs.name
    FROM route_stop rs_o
    JOIN bus_stop bs ON rs_o.id_stop = bs.id_stop
    WHERE rs_o.id_route = r.id_route
    ORDER BY rs_o.stop_order ASC
    LIMIT 1) AS origin,
  (SELECT 
    bs.name
    FROM route_stop rs_d
    JOIN bus_stop bs ON rs_d.id_stop = bs.id_stop
    WHERE rs_d.id_route = r.id_route
    ORDER BY rs_d.stop_order ASC
    LIMIT 1) AS destination,
  (SELECT rs_cost.fare_from_origin
    FROM route_stop rs_cost
    WHERE rs_cost.id_route = r.id_route
    ORDER BY rs_cost.stop_order DESC
    LIMIT 1) AS total_cost,
  COUNT(rs.id_stop ) AS total_stops
FROM Route r
JOIN route_stop rs ON r.id_route = rs.id_route
JOIN bus_stop bs ON rs.id_stop = bs.id_stop 
JOIN company cp ON r.id_company = cp.id_company 
GROUP BY r.id_route, cp.name, r.route_code, r.name
ORDER BY total_cost DESC;

-- ================================
-- Passageiros que mais gastaram e se são estudantes ✅
-- ================================

SELECT
	p.cpf,
	CONCAT(p.first_name,' ', p.last_name) AS passenger_name,
	ps.loyalty_points AS  total_points,
	CASE
		WHEN ps.is_student THEN 'Student'
		ELSE 'Regular'
	END AS passenger_type,
	COUNT(t.id_ticket) AS total_purchases,
	SUM(t.price) AS total_spend
FROM person p
JOIN passenger ps ON p.id_person = ps.id_person
JOIN ticket t ON ps.id_person = t.id_passenger
LEFT JOIN student s ON ps.id_person = s.id_person
GROUP BY p.cpf, p.first_name, p.last_name, ps.loyalty_points, ps.is_student
ORDER BY total_purchases DESC;

-- ================================
-- Quantos tickets cada funcionário vendeu no dia ✅
-- ================================

SELECT
    -- Identificação do Vendedor:
    s.id_person  AS id_vendedor,
    p.first_name || ' ' || p.last_name AS nome_completo_vendedor,
    e.employee_code,
    -- Contagem de Vendas:
    COUNT(t.id_ticket) AS total_tickets_vendidos
FROM ticket t
JOIN seller s ON t.id_seller = s.id_person
JOIN employee e ON s.id_person = e.id_person
JOIN person p ON e.id_person = p.id_person
WHERE
    -- 1. Filtro OBRIGATÓRIO pela Data da Venda (Parâmetro)
    DATE(t.created_at) = '2025-10-15' -- SUBSTITUA pela data desejada (AAAA-MM-DD)
    -- 2. Filtro de Status do Ticket (Opcional, para contar apenas vendas concretizadas)
    -- AND T.status IN ('paid', 'used') 
GROUP BY 
    s.id_person, 
    p.first_name, 
    p.last_name, 
    e.employee_code
ORDER BY total_tickets_vendidos DESC;

-- ================================
-- Quanto cada rota gerou de receita, filtrado por semana, mês e ano para dada empresa ✅
-- ================================

SELECT
    -- Agrupamento temporal:
    EXTRACT(YEAR FROM T.created_at) AS ano,
    EXTRACT(MONTH FROM T.created_at) AS mes,
    EXTRACT(WEEK FROM T.created_at) AS semana_no_ano,
    -- Identificação da Empresa e Rota:
    C.name AS nome_empresa,
    R.route_code,
    R.name AS nome_rota,
    -- Cálculo da Receita:
    SUM(T.price) AS receita_total
FROM Ticket T
JOIN Trip TR ON T.id_trip = TR.id_trip
JOIN Schedule S ON TR.id_schedule = S.id_schedule
JOIN Route R ON S.id_route = R.id_route
JOIN Company C ON R.id_company = C.id_company
-- WHERE
--     -- 1. Filtro pela Empresa Específica (Parâmetro)
--     C.name = 'Nome da Empresa Desejada' -- Substitua pelo nome da empresa
--     -- OU
--     -- R.id_company = 1 -- Substitua pelo ID da empresa
--     -- 2. Filtro pelo Status do Ticket (Opcional, mas recomendado para receita real)
--     AND T.status = 'paid' -- Ou 'used' ou outras regras de negócio
--     -- 3. Filtro pelo Período de Tempo (Exemplo: Apenas 2025)
--     AND EXTRACT(YEAR FROM T.created_at) = 2025  
--     -- Você pode adicionar mais filtros por mês, semana ou data específica aqui.
--     -- AND EXTRACT(MONTH FROM T.created_at) = 10
GROUP BY 
    ano, 
    mes, 
    semana_no_ano, 
    C.name, 
    R.route_code, 
    R.name
ORDER BY 
    ano DESC, 
    mes DESC, 
    semana_no_ano DESC, 
    nome_empresa, 
    route_code;

-- ================================
-- Lista de horários de viagens disponíveis dados origem e destino específicos ✅
-- ================================

SELECT
    -- Detalhes da Rota
    R.route_code AS codigo_da_rota,
    R.name AS nome_da_rota,
    -- Detalhes do Horário (Schedule)
    S.departure_time AS hora_de_partida_programada,
    S.days_of_week AS dias_de_operacao, -- JSONB array (ex: [1, 2, 3, 4, 5])
    -- Cálculo do Preço do Trecho
    -- O preço é a Tarifa Acumulada no Destino menos a Tarifa Acumulada na Origem
    (RS_DEST.fare_from_origin - RS_ORIG.fare_from_origin) AS preco_do_ticket,
    -- Informação adicional sobre o tempo de percurso entre as paradas
    (RS_DEST.estimated_min - RS_ORIG.estimated_min) AS tempo_estimado_minutos
FROM Route R
-- 1. Encontra a Parada de Origem na Rota
JOIN Route_Stop RS_ORIG ON R.id_route = RS_ORIG.id_route
JOIN Bus_Stop BS_ORIG ON RS_ORIG.id_stop = BS_ORIG.id_stop
-- 2. Encontra a Parada de Destino na Rota
JOIN Route_Stop RS_DEST ON R.id_route = RS_DEST.id_route
JOIN Bus_Stop BS_DEST ON RS_DEST.id_stop = BS_DEST.id_stop
-- 3. Encontra os Horários Programados para a Rota
JOIN Schedule S ON R.id_route = S.id_route
WHERE
    -- Filtro A: A parada de Origem deve ser a desejada
    BS_ORIG.name = 'Nome da Parada de Origem'
    -- Filtro B: A parada de Destino deve ser a desejada
    AND BS_DEST.name = 'Nome da Parada de Destino'
    -- Filtro C: Condição CRÍTICA - A ordem de embarque deve ser *menor* que a ordem de desembarque
    AND RS_ORIG.stop_order < RS_DEST.stop_order
    -- Filtro D: Apenas rotas ativas e horários ativos
    AND R.is_active = TRUE
    AND S.is_active = TRUE
ORDER BY 
    nome_da_rota, 
    hora_de_partida_programada;

-- ================================
-- Destinos disponíveis com menor custo pra estudantes dado posição inicial ✅
-- ================================

WITH Viagens_Validas_E_Precos AS (
    SELECT
        R.id_route,
        BS_DEST.id_stop AS id_destino,
        BS_DEST.name AS nome_destino,
        -- Cálculo do Preço Base do Trecho
        -- (Tarifa acumulada Destino - Tarifa acumulada Origem)
        (RS_DEST.fare_from_origin - RS_ORIG.fare_from_origin) AS preco_base
    FROM Bus_Stop BS_ORIG
    -- Encontra a Parada de Origem na Tabela de Percursos (Route_Stop)
    JOIN Route_Stop RS_ORIG ON BS_ORIG.id_stop = RS_ORIG.id_stop
    -- Conecta à Tabela de Rotas
    JOIN Route R ON RS_ORIG.id_route = R.id_route
    -- Encontra todas as possíveis Paradas de Destino na Mesma Rota
    JOIN Route_Stop RS_DEST ON R.id_route = RS_DEST.id_route
    -- Conecta à Tabela de Paradas de Destino
    JOIN Bus_Stop BS_DEST ON RS_DEST.id_stop = BS_DEST.id_stop
    WHERE
        -- 1. Filtro pela posição inicial (Parâmetro)
        BS_ORIG.name = 'Nome da Parada Inicial'
        -- 2. A parada de destino deve vir *depois* da origem no percurso
        AND RS_DEST.stop_order > RS_ORIG.stop_order
        -- 3. Garante que o trecho tenha um custo positivo (não é a mesma parada)
        AND (RS_DEST.fare_from_origin - RS_ORIG.fare_from_origin) > 0
        -- 4. Garante que a rota tenha pelo menos um horário ativo
        AND EXISTS (
            SELECT 1 
            FROM Schedule S 
            WHERE S.id_route = R.id_route AND S.is_active = TRUE
        )
)

SELECT
    VT.id_destino,
    VT.nome_destino,
    -- Menor Preço Base encontrado para o destino (tarifa cheia)
    MIN(VT.preco_base) AS menor_preco_base,
    -- Menor Preço ESTIMADO para Estudante
    -- (Assumindo que o desconto é de 50%, modifique '0.50' conforme a regra de negócio)
    ROUND(MIN(VT.preco_base) * 0.50, 2) AS menor_preco_estudante_estimado
FROM Viagens_Validas_E_Precos VT
GROUP BY VT.id_destino, VT.nome_destino
ORDER BY menor_preco_estudante_estimado ASC;


-- ================================
-- motoristas com o maior tempo de trabalho num intervalo de 30 dias ✅
-- ================================

SELECT
    p.cpf,
    e.employee_code,
    p.first_name || ' ' || p.last_name AS driver_name,
    c.name AS company_name,
    COUNT(t.id_trip) AS total_trips,
    -- Calcula o tempo total de trabalho somando a diferença entre arrival e departure
    SUM(EXTRACT(EPOCH FROM (t.arrival_datetime - t.departure_datetime)) / 3600) AS total_hours_worked,
    -- Versão formatada em horas:minutos
    TO_CHAR(
        INTERVAL '1 second' * SUM(EXTRACT(EPOCH FROM (t.arrival_datetime - t.departure_datetime))),
        'HH24:MI'
    ) AS total_time_formatted
FROM trip t
JOIN driver d ON t.id_driver = d.id_person
JOIN employee e ON d.id_person = e.id_person
JOIN person p ON e.id_person = p.id_person
JOIN company c ON e.id_company = c.id_company
WHERE 
    -- Viagens nos últimos 30 dias
    t.trip_date >= CURRENT_DATE - INTERVAL '30 days'
    -- Apenas viagens completadas
    AND t.status = 'completed'
    -- Apenas viagens com horário de chegada definido
    AND t.arrival_datetime IS NOT NULL
GROUP BY p.cpf, e.employee_code, p.first_name, p.last_name, c.name
ORDER BY total_hours_worked DESC;
