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
-- Recorrência de passageiros por rota ✅
-- ================================
SELECT
    p.first_name || ' ' || p.last_name AS passenger_name,
    p.cpf,
    r.id AS route_id,
    bs_origin.name || ' -> ' || bs_dest.name AS route_name,
    COUNT(t.id) AS trips_on_this_route,
    MAX(s.departure_time) AS last_trip_date
FROM Passenger p
JOIN Ticket t ON p.cpf = t.passenger_cpf
JOIN SeatOnSchedule sos ON t.seat_on_schedule_id = sos.id
JOIN Schedule s ON sos.schedule_id = s.id
JOIN Route r ON s.route_id = r.id
JOIN BusStop bs_origin ON r.origin_id = bs_origin.id
JOIN BusStop bs_dest ON r.destination_id = bs_dest.id
GROUP BY p.cpf, passenger_name, r.id, route_name
HAVING COUNT(t.id) >= 2
ORDER BY trips_on_this_route DESC;


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
-- Tempo de viagem de cada motorista num intervalo de 30 dias ✅
-- ================================
WITH recent_schedules AS (
    SELECT * FROM Schedule
    WHERE departure_time >= NOW() - interval '30 day'
)
SELECT
    e.first_name || ' ' || e.last_name AS driver_name,
    e.cpf,
    SUM(s.travel_time) AS total_travel_time
FROM Employee e
JOIN ScheduleEmployee se ON e.cpf = se.employee_cpf
JOIN recent_schedules s ON se.schedule_id = s.id
WHERE e.role = 'Motorista'
GROUP BY e.cpf, driver_name
ORDER BY total_travel_time DESC;
