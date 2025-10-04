-- ================================
-- Receita total por rota
-- ================================
select 
    r.id as route_id,
    bs1.name as origin,
    bs2.name as destination,
    sum(tk.price) as total_revenue
from Route r
join Schedule sch on sch.route_id = r.id
join SeatOnSchedule sos on sos.schedule_id = sch.id
join Ticket tk on tk.seat_on_schedule_id = sos.id
join BusStop bs1 on r.origin_id = bs1.id
join BusStop bs2 on r.destination_id = bs2.id
group by r.id, bs1.name, bs2.name
order by total_revenue desc;

-- ================================
-- Taxa de ocupação média dos ônibus
-- ================================
SELECT
    V.license_plate,
    V.brand,
    V.model,
    -- Calcula a média da taxa de ocupação: (Soma de Assentos Ocupados / Soma de Capacidade) * 100
    -- Usamos AVG() da proporção por agendamento ou a proporção global, dependendo da necessidade de detalhe
    -- Optando por calcular a taxa média por agendamento (schedule) para precisão:
    AVG(T.tickets_vendidos::decimal * 100 / VC.capacity) AS avg_occupancy_rate_percent
FROM Vehicle V
JOIN (
    -- Subconsulta 1: Capacidade (total de assentos) por veículo
    SELECT
        license_plate,
        COUNT(id) AS capacity
    FROM Seat
    GROUP BY license_plate
) VC ON VC.license_plate = V.license_plate
JOIN Seat S ON S.license_plate = V.license_plate
JOIN SeatOnSchedule SOS ON SOS.seat_id = S.id
LEFT JOIN (
    -- Subconsulta 2: Bilhetes vendidos por Horário e Veículo
    SELECT
        SOS.schedule_id,
        S.license_plate,
        COUNT(T.id) AS tickets_vendidos
    FROM SeatOnSchedule SOS
    JOIN Ticket T ON T.seat_on_schedule_id = SOS.id
    JOIN Seat S ON S.id = SOS.seat_id
    GROUP BY SOS.schedule_id, S.license_plate
) T ON T.schedule_id = SOS.schedule_id AND T.license_plate = V.license_plate
GROUP BY V.license_plate, V.brand, V.model, VC.capacity
ORDER BY avg_occupancy_rate_percent DESC;

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
