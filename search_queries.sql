-- ================================
-- Receita total por rota
-- ================================
SELECT 
  r.id AS route_id,
  bs1.name AS origin,
  bs2.name AS destination,
  SUM(tk.price) AS total_revenue
FROM Route r
JOIN Schedule s ON s.route_id = r.id
JOIN SeatOnSchedule sos ON sos.schedule_id = s.id
JOIN Ticket tk ON tk.seat_on_schedule_id = sos.id
JOIN BusStop bs1 ON r.origin_id = bs1.id
JOIN BusStop bs2 ON r.destination_id = bs2.id
GROUP BY r.id, bs1.name, bs2.name
ORDER BY total_revenue DESC;

-- ================================
-- Taxa de ocupação média dos ônibus
-- ================================
select 
    b.plate,
    avg(ticket_count::decimal / b.capacity) * 100 as avg_occupancy_rate
from Bus b
join Trip tr on tr.bus_plate = b.plate
left join (
    select trip_id, count(*) as ticket_count
    from Ticket
    group by trip_id
) tcount on tcount.trip_id = tr.id
group by b.plate;

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
select 
    passenger_name,
    count(*) as total_tickets,
    sum(price) as total_spent
from Ticket
group by passenger_name
order by total_spent desc
limit 10;
