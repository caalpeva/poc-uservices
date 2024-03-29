package team.boolbee.poc.cadence.entities.activities;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.UUID;

public class TripBookingActivities implements ITripBookingActivities {

    private static Logger logger = LoggerFactory.getLogger(TripBookingActivities.class);

    @Override
    public String reserveCar(String name) {
        logger.info("Booking car for '" + name + "'");
        return UUID.randomUUID().toString();
    }

    @Override
    public String reserveFlight(String name) {
        logger.error("Failing to book flight for '" + name + "'");
        throw new RuntimeException("Flight booking did not work");
    }

    @Override
    public String reserveHotel(String name) {
        logger.info("Booking hotel for '" + name + "'");
        return UUID.randomUUID().toString();
    }

    @Override
    public String cancelCar(String reservationID, String name) {
        logger.warn("Cancelling car reservation '" + reservationID + "' for '" + name + "'");
        return UUID.randomUUID().toString();
    }

    @Override
    public String cancelFlight(String reservationID, String name) {
        logger.warn("Cancelling flight reservation '" + reservationID + "' for '" + name + "'");
        return UUID.randomUUID().toString();
    }

    @Override
    public String cancelHotel(String reservationID, String name) {
        logger.warn("Cancelling hotel reservation '" + reservationID + "' for '" + name + "'");
        return UUID.randomUUID().toString();
    }
}
