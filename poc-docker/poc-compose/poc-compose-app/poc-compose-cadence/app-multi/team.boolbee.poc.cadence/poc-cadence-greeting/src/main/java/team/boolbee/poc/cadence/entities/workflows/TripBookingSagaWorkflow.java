package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.activity.ActivityOptions;
import com.uber.cadence.workflow.*;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.activities.IGreetingActivities;
import team.boolbee.poc.cadence.entities.activities.ITripBookingActivities;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

import java.time.Duration;

public class TripBookingSagaWorkflow implements ITripBookingSagaWorkflow {
    private static Logger logger = Workflow.getLogger(TripBookingSagaWorkflow.class);

    private final ITripBookingActivities activities =
            Workflow.newActivityStub(ITripBookingActivities.class,
                    new ActivityOptions.Builder()
                            .setScheduleToCloseTimeout(Duration.ofHours(1))
                            .build());

    @Override
    public void bookTrip(String name, boolean asynchCancellation) {
        // Configure SAGA to run compensation activities in parallel
        Saga saga = new Saga(new Saga.Options.Builder()
                .setParallelCompensation(true)
                .build());

        try {
            // The following demonstrate how to compensate sync invocations.
            String carReservationID = activities.reserveCar(name);
            saga.addCompensation(activities::cancelCar, carReservationID, name);

            if (asynchCancellation) {
                // The following demonstrate how to compensate async invocations.
                // It is also possible to test it with Promise<Void> and Async.procedure()
                Promise<String> result = Async.function(activities::reserveHotel, name);
                saga.addCompensation(activities::cancelHotel, result.get(), name);
            } else {
                // The following demonstrate how to compensate sync invocations.
                String hotelReservationID = activities.reserveHotel(name);
                saga.addCompensation(activities::cancelHotel, hotelReservationID, name);
            }

            // The following demonstrate how to compensate sync invocations.
            String flightReservationID = activities.reserveFlight(name);
            saga.addCompensation(activities::cancelFlight, flightReservationID, name);

            // The following demonstrate the ability of supplying arbitrary lambda as a saga
            // compensation function. In production code please always use Workflow.getLogger
            // to log messages in workflow code.
            saga.addCompensation(() -> logger.info("Other compensation logic in main workflow."));
            //throw new RuntimeException("some error");
        } catch (ActivityException e) {
            saga.compensate();
            throw e;
        }
    }
}