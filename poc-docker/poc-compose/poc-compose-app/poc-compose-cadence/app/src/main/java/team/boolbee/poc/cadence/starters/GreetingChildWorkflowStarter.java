package team.boolbee.poc.cadence.starters;

import com.uber.cadence.client.WorkflowOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import team.boolbee.poc.cadence.entities.CadenceManager;
import team.boolbee.poc.cadence.entities.activities.GreetingActivities;
import team.boolbee.poc.cadence.entities.workflows.GreetingChildWorkflow;
import team.boolbee.poc.cadence.entities.workflows.GreetingParentWorkflow;
import team.boolbee.poc.cadence.entities.workflows.IGreetingParentWorkflow;

import static team.boolbee.poc.cadence.Constants.CADENCE_DOMAIN;

public class GreetingChildWorkflowStarter {
    private static Logger logger = LoggerFactory.getLogger(GreetingChildWorkflowStarter.class);

    public static final String TASK_LIST = "poc-tl-greeting-child";
    public static void main(String[] args) {
        var workflowClient = CadenceManager.createDefaultWorkflowClient(CADENCE_DOMAIN);
        CadenceManager.startOneWorker(workflowClient,
                TASK_LIST,
                new Class<?>[] { GreetingParentWorkflow.class, GreetingChildWorkflow.class },
                new Object[] { new GreetingActivities() });

        // Get a workflow stub using the same task list the worker uses.
        IGreetingParentWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingParentWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .build());

        // Execute a workflow waiting for it to complete.
        String greeting = workflow.getGreeting("World", true);
        System.out.println(greeting);
        System.exit(0);
    }
}