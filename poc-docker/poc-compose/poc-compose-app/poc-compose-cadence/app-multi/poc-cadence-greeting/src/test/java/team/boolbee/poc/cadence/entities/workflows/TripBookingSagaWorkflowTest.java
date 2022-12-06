package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowException;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.testing.TestWorkflowEnvironment;
import com.uber.cadence.worker.Worker;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import team.boolbee.poc.cadence.entities.activities.ITripBookingActivities;
import team.boolbee.poc.cadence.entities.activities.TripBookingActivities;

import java.util.UUID;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;
import static org.mockito.Matchers.eq;
import static org.mockito.Mockito.*;

public class TripBookingSagaWorkflowTest {

    private final String CAR_RESERVATION_ID = UUID.randomUUID().toString();
    private final String CUSTOMER = System.getenv("USERNAME");
    private  final String TASK_LIST = "poc-tl-trip-booking-saga-test";
    private TestWorkflowEnvironment testWorkflowEnvironment;
    private WorkflowClient workflowClient;
    private Worker worker;

    @Before
    public void setUp() {
        testWorkflowEnvironment = TestWorkflowEnvironment.newInstance();
        worker = testWorkflowEnvironment.newWorker(TASK_LIST);
        worker.registerWorkflowImplementationTypes(TripBookingSagaWorkflow.class);
        workflowClient = testWorkflowEnvironment.newWorkflowClient();
    }

    @After
    public void tearDown() {
        testWorkflowEnvironment.close();
    }

    /**
     * Not very useful test that validates that the default activities cause workflow to fail. See
     * other tests on using mocked activities to test SAGA logic.
     */
    @Test
    public void testTripBookingWorkflowFailsWithDefaultActivities() {
        worker.registerActivitiesImplementations(new TripBookingActivities());
        testWorkflowEnvironment.start();

        ITripBookingSagaWorkflow workflow = workflowClient.newWorkflowStub(
                ITripBookingSagaWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .build());
        try {
            workflow.bookTrip(CUSTOMER, false);
            fail("unreachable");
        } catch (WorkflowException e) {
            assertEquals("Flight booking did not work", e.getCause().getCause().getMessage());
        }
    }

    /** Unit test workflow logic using mocked activities. */
    @Test
    public void testTripBookingWorkflowFailsWithMockActivities() {
        ITripBookingActivities activities = mock(ITripBookingActivities.class);
        when(activities.reserveCar(CUSTOMER)).thenReturn(CAR_RESERVATION_ID);
        when(activities.reserveHotel(CUSTOMER)).thenThrow(new RuntimeException("Hotel booking did not work"));

        worker.registerActivitiesImplementations(activities);
        testWorkflowEnvironment.start();

        ITripBookingSagaWorkflow workflow = workflowClient.newWorkflowStub(
                ITripBookingSagaWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .build());
        try {
            workflow.bookTrip(CUSTOMER, false);
            fail("unreachable");
        } catch (WorkflowException e) {
            assertEquals("Hotel booking did not work", e.getCause().getCause().getMessage());
        }

        verify(activities).cancelCar(eq(CAR_RESERVATION_ID), eq(CUSTOMER));
    }
}
