-- ================================
-- Receita total por rota ✅
-- ================================
SELECT 
  r.id AS route_id,
  cp.name AS company_name,
  bs1.name AS origin,
  bs2.name AS destination,
  SUM(tk.price) AS total_revenue
FROM Route r
JOIN Schedule s ON s.route_id = r.id
JOIN SeatOnSchedule sos ON sos.schedule_id = s.id
JOIN Ticket tk ON tk.seat_on_schedule_id = sos.id
JOIN BusStop bs1 ON r.origin_id = bs1.id
JOIN BusStop bs2 ON r.destination_id = bs2.id
Join CompanyRoute cr ON cr.route_id = r.id
Join Company cp ON cp.cnpj = cr.cnpj
GROUP BY cp.name, r.id, bs1.name, bs2.name
ORDER BY total_revenue DESC;

-- ================================
-- Passageiros que mais compraram tickets ✅
-- ================================
select 
    p.cpf,
    p.first_name || ' ' || p.last_name as nome_completo,
    count(t.id) as total_compras,
    sum(t.price) as total_gasto
from Passenger p
join Ticket t on p.cpf = t.passenger_cpf
group by p.cpf, nome_completo
order by total_compras desc;

-- ================================
-- Ranking de motoristas por quantidade de viagens
-- ================================
select 
    e.first_name || ' ' || e.last_name as driver,
    count(tr.id) as trips_count
from Employee e
join Trip tr on tr.driver_cpf = e.cpf
where e.role = 'Motorista'
group by e.cpf
order by trips_count desc;


-- ================================
-- Ônibus com maior quilometragem acumulada por rota
-- ================================
select 
    r.id as route_id,
    bs1.name as origin,
    bs2.name as destination,
    b.plate,
    b.model,
    max(b.mileage) as highest_mileage
from Route r
join Trip tr on tr.route_id = r.id
join Bus b on b.plate = tr.bus_plate
join BusStop bs1 on r.origin_id = bs1.id
join BusStop bs2 on r.destination_id = bs2.id
group by r.id, bs1.name, bs2.name, b.plate, b.model
order by highest_mileage desc;


-- ================================
-- Passageiros que mais compraram bilhetes
-- ================================
SELECT 
  p.first_name || ' ' || p.last_name AS passenger_name,
  COUNT(t.id) AS total_tickets,
  SUM(t.price) AS total_spent
FROM Ticket t
JOIN Passenger p ON p.cpf = t.passenger_cpf
GROUP BY p.cpf, p.first_name, p.last_name
ORDER BY total_spent DESC
LIMIT 50;
