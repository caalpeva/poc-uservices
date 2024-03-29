package team.boolbee.poc.cadence.starters;

import com.uber.cadence.client.WorkflowOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import team.boolbee.poc.cadence.entities.CadenceManager;
import team.boolbee.poc.cadence.entities.workflows.GreetingSideEffectWorkflow;
import team.boolbee.poc.cadence.entities.workflows.IGreetingQueryableWorkflow;

import java.time.Duration;

import static team.boolbee.poc.cadence.Constants.CADENCE_DOMAIN;

public class GreetingSideEffectWorkflowStarter {
    private static Logger logger = LoggerFactory.getLogger(GreetingSideEffectWorkflowStarter.class);

    public static final String TASK_LIST = "poc-tl-greeting-side-effect";

    public static void main(String[] args) throws InterruptedException {
        var workflowClient = CadenceManager.createDefaultWorkflowClient(CADENCE_DOMAIN);
        CadenceManager.startOneWorker(workflowClient,
                TASK_LIST,
                new Class<?>[] {GreetingSideEffectWorkflow.class },
                new Object[] {});

        // Get a workflow stub using the same task list the worker uses.
        IGreetingQueryableWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingQueryableWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setExecutionStartToCloseTimeout(Duration.ofSeconds(30))
                        .build());

        // Execute a workflow waiting for it to complete. Usually this is done from another program.
        workflow.createGreeting("World");

        // Query and print the set value
        System.out.println(workflow.queryGreeting());
        System.exit(0);
    }
}