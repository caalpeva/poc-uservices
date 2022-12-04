package team.boolbee.poc.cadence.entities.activities;

public interface ITripBookingActivities {

    String reserveCar(String name);
    String reserveFlight(String name);
    String reserveHotel(String name);

    String cancelCar(String reservationID, String name);
    String cancelFlight(String reservationID, String name);
    String cancelHotel(String reservationID, String name);

}
