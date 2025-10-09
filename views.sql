-- Vista: Informação completa de viagens com detalhes de rota e veículo
CREATE OR REPLACE VIEW vw_trip_details AS
SELECT 
    t.id_trip,
    t.trip_date,
    t.departure_datetime,
    t.arrival_datetime,
    t.status AS trip_status,
    t.available_capacity,
    r.name AS route_name,
    c.name AS company_name,
    v.license_plate,
    v.vehicle_type,
    v.capacity AS total_capacity,
    CONCAT(p.first_name, ' ', p.last_name) AS driver_name,
    s.departure_time AS scheduled_departure
FROM Trip t
JOIN Schedule s ON t.id_schedule = s.id_schedule
JOIN Route r ON s.id_route = r.id_route
JOIN Company c ON r.id_company = c.id_company
JOIN Vehicle v ON t.id_vehicle = v.id_vehicle
JOIN Person p ON t.id_driver = p.id_person;

COMMENT ON VIEW vw_trip_details IS 'Vista consolidada de viagens com informação completa';

-- Vista: Tickets com informação completa
CREATE OR REPLACE VIEW vw_ticket_details AS
SELECT 
    tk.id_ticket,
    tk.price,
    tk.discount_applied,
    tk.discount_reason,
    tk.payment_method,
    tk.status AS ticket_status,
    -- Informação do passageiro
    CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
    p.email AS passenger_email,
    p.phone AS passenger_phone,
    pas.is_student,
    -- Informação de paradas
    bs_boarding.name AS boarding_stop_name,
    bs_boarding.city AS boarding_city,
    bs_destination.name AS destination_stop_name,
    bs_destination.city AS destination_city,
    -- Informação da viagem
    t.trip_date,
    t.departure_datetime,
    t.arrival_datetime,
    t.status AS trip_status,
    -- Informação da rota
    r.name AS route_name,
    r.route_code,
    r.route_type,
    -- Informação da companhia
    c.name AS company_name,
    -- Informação do veículo
    v.license_plate,
    v.vehicle_type
FROM Ticket tk
JOIN Passenger pas ON tk.id_passenger = pas.id_person
JOIN Person p ON pas.id_person = p.id_person
JOIN Bus_Stop bs_boarding ON tk.id_boarding_stop = bs_boarding.id_stop
JOIN Bus_Stop bs_destination ON tk.id_destination_stop = bs_destination.id_stop
JOIN Trip t ON tk.id_trip = t.id_trip
JOIN Schedule sch ON t.id_schedule = sch.id_schedule
JOIN Route r ON sch.id_route = r.id_route
JOIN Company c ON r.id_company = c.id_company
JOIN Vehicle v ON t.id_vehicle = v.id_vehicle
LEFT JOIN Seller sel ON tk.id_seller = sel.id_person;

COMMENT ON VIEW vw_ticket_details IS 'Vista completa de tickets com informação do passageiro, viagem, rota, paradas e vendedor';