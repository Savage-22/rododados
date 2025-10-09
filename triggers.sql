-- Função: Atualizar available_capacity em Trip ao vender ticket
CREATE OR REPLACE FUNCTION update_trip_capacity()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' AND NEW.status = 'paid') THEN
        -- Ao inserir ticket pago, reduzir capacidade
        UPDATE Trip 
        SET available_capacity = available_capacity - 1
        WHERE id_trip = NEW.id_trip;
        
    ELSIF (TG_OP = 'UPDATE' AND OLD.status != 'paid' AND NEW.status = 'paid') THEN
        -- Ao mudar estado para pago, reduzir capacidade
        UPDATE Trip 
        SET available_capacity = available_capacity - 1
        WHERE id_trip = NEW.id_trip;
        
    ELSIF (TG_OP = 'UPDATE' AND OLD.status = 'paid' AND NEW.status IN ('cancelled', 'expired')) THEN
        -- Ao cancelar ticket, aumentar capacidade
        UPDATE Trip 
        SET available_capacity = available_capacity + 1
        WHERE id_trip = NEW.id_trip;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar capacidade automaticamente
CREATE TRIGGER trg_update_trip_capacity
AFTER INSERT OR UPDATE ON Ticket
FOR EACH ROW
EXECUTE FUNCTION update_trip_capacity();

COMMENT ON FUNCTION update_trip_capacity() IS 'Atualiza automaticamente a capacidade disponível do Trip ao vender/cancelar tickets';

-- Função: Validar que o assento pertença ao veículo da viagem
CREATE OR REPLACE FUNCTION validate_seat_vehicle()
RETURNS TRIGGER AS $$
DECLARE
    v_vehicle_id INT;
    v_trip_vehicle_id INT;
BEGIN
    -- Somente validar se um assento for atribuído
    IF NEW.id_seat IS NOT NULL THEN
        -- Obter o veículo do assento
        SELECT id_vehicle INTO v_vehicle_id
        FROM Seat WHERE id_seat = NEW.id_seat;
        
        -- Obter o veículo da viagem
        SELECT id_vehicle INTO v_trip_vehicle_id
        FROM Trip WHERE id_trip = NEW.id_trip;
        
        -- Validar que coincidam
        IF v_vehicle_id != v_trip_vehicle_id THEN
            RAISE EXCEPTION 'O assento % não pertence ao veículo da viagem', NEW.id_seat;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validar assento antes de inserir ticket
CREATE TRIGGER trg_validate_seat_vehicle
BEFORE INSERT OR UPDATE ON Ticket
FOR EACH ROW
EXECUTE FUNCTION validate_seat_vehicle();

COMMENT ON FUNCTION validate_seat_vehicle() IS 'Verifica que o assento atribuído pertence ao veículo da viagem';

-- Função: Validar que as paradas pertencem à rota da viagem
CREATE OR REPLACE FUNCTION validate_trip_stops()
RETURNS TRIGGER AS $$
DECLARE
    v_route_id INT;
    v_boarding_exists BOOLEAN;
    v_destination_exists BOOLEAN;
BEGIN
    -- Obter a rota da viagem
    SELECT r.id_route INTO v_route_id
    FROM Trip t
    JOIN Schedule s ON t.id_schedule = s.id_schedule
    JOIN Route r ON s.id_route = r.id_route
    WHERE t.id_trip = NEW.id_trip;
    
    -- Verificar que a parada de embarque existe na rota
    SELECT EXISTS (
        SELECT 1 FROM Route_Stop 
        WHERE id_route = v_route_id AND id_stop = NEW.id_boarding_stop
    ) INTO v_boarding_exists;
    
    -- Verificar que a parada de destino existe na rota
    SELECT EXISTS (
        SELECT 1 FROM Route_Stop 
        WHERE id_route = v_route_id AND id_stop = NEW.id_destination_stop
    ) INTO v_destination_exists;
    
    IF NOT v_boarding_exists THEN
        RAISE EXCEPTION 'A parada de embarque % não pertence à rota da viagem', NEW.id_boarding_stop;
    END IF;
    
    IF NOT v_destination_exists THEN
        RAISE EXCEPTION 'A parada de destino % não pertence à rota da viagem', NEW.id_destination_stop;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validar paradas
CREATE TRIGGER trg_validate_trip_stops
BEFORE INSERT OR UPDATE ON Ticket
FOR EACH ROW
EXECUTE FUNCTION validate_trip_stops();

COMMENT ON FUNCTION validate_trip_stops() IS 'Verifica que as paradas de embarque e destino pertencem à rota da viagem';