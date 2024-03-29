package team.boolbee.poc.cadence.entities.activities;

import com.uber.cadence.activity.ActivityMethod;

public interface ITripBookingActivities {

    @ActivityMethod
    String reserveCar(String name);
    @ActivityMethod
    String reserveFlight(String name);
    @ActivityMethod
    String reserveHotel(String name);
    @ActivityMethod
    String cancelCar(String reservationID, String name);
    @ActivityMethod
    String cancelFlight(String reservationID, String name);
    @ActivityMethod
    String cancelHotel(String reservationID, String name);
}
