package team.boolbee.poc.cadence.starters;

import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.client.WorkflowStub;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import team.boolbee.poc.cadence.entities.CadenceManager;
import team.boolbee.poc.cadence.entities.activities.GreetingActivities;
import team.boolbee.poc.cadence.entities.workflows.GreetingCancellableWorkflow;

import java.time.Duration;
import java.util.concurrent.CancellationException;

import static team.boolbee.poc.cadence.Constants.CADENCE_DOMAIN;

public class GreetingWorkflowCancellationStarter {
    private static Logger logger = LoggerFactory.getLogger(GreetingWorkflowCancellationStarter.class);
    public static final String TASK_LIST = "poc-tl-greeting-cancellation";

    public static void main(String[] args) {
        var workflowClient = CadenceManager.createDefaultWorkflowClient(CADENCE_DOMAIN);
        var activities = new GreetingActivities();
        CadenceManager.startOneWorker(workflowClient,
                TASK_LIST,
                new Class<?>[] { GreetingCancellableWorkflow.class },
                new Object[] { activities });

        // NOTE: strongly typed workflow stub doesn't cancel method.
        WorkflowStub untypedWorkflow = workflowClient.newUntypedWorkflowStub(
                "IGreetingWorkflow::getGreeting",
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setExecutionStartToCloseTimeout(Duration.ofDays(30))
                        .build());

        try {
            untypedWorkflow.start("World");
            untypedWorkflow.cancel(); // Issue cancellation request. This will trigger a CancellationException on the workflow.
            untypedWorkflow.getResult(String.class);
        } catch (CancellationException e) {
            logger.warn("Workflow cancelled");
        }

        System.out.println(activities.getInvocations());
        System.exit(0);
    }
}