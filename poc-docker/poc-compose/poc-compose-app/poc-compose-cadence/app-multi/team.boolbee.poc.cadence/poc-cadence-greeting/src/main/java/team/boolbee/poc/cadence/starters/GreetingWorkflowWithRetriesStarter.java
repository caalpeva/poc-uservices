package team.boolbee.poc.cadence.starters;

import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.CadenceHelper;
import team.boolbee.poc.cadence.entities.activities.GreetingActivitiesWithDelay;
import team.boolbee.poc.cadence.entities.workflows.GreetingWorkflow;
import team.boolbee.poc.cadence.entities.workflows.GreetingWorkflowWithRetries;
import team.boolbee.poc.cadence.entities.workflows.IGreetingWorkflow;

import java.time.Duration;

import static team.boolbee.poc.cadence.entities.CadenceConstants.*;

public class GreetingWorkflowWithRetriesStarter {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowWithRetriesStarter.class);

    public static void main(String[] args) {
        var workflowClient = CadenceHelper.createWorkflowClient(DOMAIN);
        CadenceHelper.startOneWorker(workflowClient,
                TASK_LIST_GREETING_WITH_RETRIES,
                new Class<?>[] { GreetingWorkflowWithRetries.class },
                new Object[] { new GreetingActivitiesWithDelay() });

        // Get a workflow stub using the same task list the worker uses.
        IGreetingWorkflow workflow = workflowClient.newWorkflowStub(IGreetingWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST_GREETING_WITH_RETRIES)
                        .setExecutionStartToCloseTimeout(Duration.ofSeconds(30))
                        .build());

        // Execute a workflow waiting for it to complete.
        String greeting = workflow.getGreeting("World");
        System.out.println(greeting);
        System.exit(0);
    }
}