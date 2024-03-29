package team.boolbee.poc.cadence.starters;

import com.uber.cadence.client.WorkflowOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import team.boolbee.poc.cadence.entities.CadenceManager;
import team.boolbee.poc.cadence.entities.activities.GreetingActivities;
import team.boolbee.poc.cadence.entities.workflows.GreetingWorkflowWithAsyncActivity;
import team.boolbee.poc.cadence.entities.workflows.IGreetingWorkflow;

import static team.boolbee.poc.cadence.Constants.*;

public class GreetingWorkflowWithAsyncActivitiesStarter {
    private static Logger logger = LoggerFactory.getLogger(GreetingWorkflowWithAsyncActivitiesStarter.class);

    public static final String TASK_LIST = "poc-tl-greeting-with-async-activities";

    public static void main(String[] args) {
        var workflowClient = CadenceManager.createDefaultWorkflowClient(CADENCE_DOMAIN);
        CadenceManager.startOneWorker(workflowClient,
                TASK_LIST,
                new Class<?>[] { GreetingWorkflowWithAsyncActivity.class },
                new Object[] { new GreetingActivities() });

        // Get a workflow stub using the same task list the worker uses.
        IGreetingWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .build());

        // Execute a workflow waiting for it to complete.
        String greeting = workflow.getGreeting("World");
        System.out.println(greeting);
        System.exit(0);
    }
}