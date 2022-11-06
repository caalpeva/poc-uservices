package team.boolbee.poc.cadence.starters;

import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.CadenceHelper;
import team.boolbee.poc.cadence.entities.activities.GreetingActivities;
import team.boolbee.poc.cadence.entities.workflows.GreetingWorkflowWithAsyncActivity;
import team.boolbee.poc.cadence.entities.workflows.IGreetingWorkflow;

import static team.boolbee.poc.cadence.entities.CadenceConstants.*;

public class GreetingWorkflowWithAsyncActivitiesStarter {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowWithAsyncActivitiesStarter.class);

    public static final String TASK_LIST = "poc-tl-greeting-with-async-activities";

    public static void main(String[] args) {
        var workflowClient = CadenceHelper.createDefaultWorkflowClient(DOMAIN);
        CadenceHelper.startOneWorker(workflowClient,
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