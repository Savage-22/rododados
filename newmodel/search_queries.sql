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
-- Quanto cada rota gerou de receita, filtrado por semana, mês e ano para dada empresa
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