package team.boolbee.poc.cadence.starters;

import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.CadenceHelper;
import team.boolbee.poc.cadence.entities.activities.GreetingActivities;
import team.boolbee.poc.cadence.entities.workflows.GreetingQueryableWorkflow;
import team.boolbee.poc.cadence.entities.workflows.GreetingWorkflow;
import team.boolbee.poc.cadence.entities.workflows.IGreetingQueryableWorkflow;
import team.boolbee.poc.cadence.entities.workflows.IGreetingWorkflow;

import java.time.Duration;

import static team.boolbee.poc.cadence.entities.CadenceConstants.DOMAIN;

public class GreetingQueryableWorkflowStarter {
    private static Logger logger = Workflow.getLogger(GreetingQueryableWorkflowStarter.class);

    public static final String TASK_LIST = "poc-tl-greeting-queryable";

    public static void main(String[] args) throws InterruptedException {
        var workflowClient = CadenceHelper.createDefaultWorkflowClient(DOMAIN);
        CadenceHelper.startOneWorker(workflowClient,
                TASK_LIST,
                new Class<?>[] { GreetingQueryableWorkflow.class },
                new Object[] {});

        // Get a workflow stub using the same task list the worker uses.
        IGreetingQueryableWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingQueryableWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setExecutionStartToCloseTimeout(Duration.ofSeconds(30))
                        .build());

        // Start workflow asynchronously to not use another thread to query.
        WorkflowClient.start(workflow::createGreeting, "World");
        // After start for getGreeting returns, the workflow is guaranteed to be started.
        // So we can send a signal to it using workflow stub.

        System.out.println(workflow.queryGreeting()); // Should print Hello...
        // Note that inside a workflow only WorkflowThread.sleep is allowed. Outside
        // WorkflowThread.sleep is not allowed.
        Thread.sleep(2500);
        System.out.println(workflow.queryGreeting()); // Should print Bye ...
        System.exit(0);
    }
}