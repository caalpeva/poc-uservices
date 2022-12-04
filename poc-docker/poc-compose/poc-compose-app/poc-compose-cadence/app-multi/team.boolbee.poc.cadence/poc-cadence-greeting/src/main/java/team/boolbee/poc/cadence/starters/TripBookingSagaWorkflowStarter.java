package team.boolbee.poc.cadence.starters;

import com.google.common.base.Throwables;
import com.uber.cadence.client.WorkflowException;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import team.boolbee.poc.cadence.entities.CadenceHelper;
import team.boolbee.poc.cadence.entities.activities.TripBookingActivities;
import team.boolbee.poc.cadence.entities.workflows.ITripBookingSagaWorkflow;
import team.boolbee.poc.cadence.entities.workflows.TripBookingSagaWorkflow;

import static team.boolbee.poc.cadence.entities.CadenceConstants.DOMAIN;

public class TripBookingSagaWorkflowStarter {
    private static Logger logger = LoggerFactory.getLogger(TripBookingSagaWorkflowStarter.class);

    private static final String TASK_LIST = "poc-tl-trip-booking-saga";

    public static void main(String[] args) {
        var workflowClient = CadenceHelper.createDefaultWorkflowClient(DOMAIN);
        CadenceHelper.startOneWorker(workflowClient,
                TASK_LIST,
                new Class<?>[] { TripBookingSagaWorkflow.class },
                new Object[] { new TripBookingActivities() });

        // Get a workflow stub using the same task list the worker uses.
        ITripBookingSagaWorkflow workflow = workflowClient.newWorkflowStub(
                ITripBookingSagaWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .build());

        // Start a workflow execution. Usually this is done from another program.
        try {
            workflow.bookTrip(System.getenv("USERNAME"), false);
        } catch (WorkflowException e) {
            Throwable cause = Throwables.getRootCause(e);
            logger.error(cause.getMessage());
            //logger.error("\nStack Trace:\n" + Throwables.getStackTraceAsString(e));
            //e.printStackTrace();
        }

        System.exit(0);
    }
}