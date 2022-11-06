package team.boolbee.poc.cadence.starters;

import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.CadenceHelper;
import team.boolbee.poc.cadence.entities.activities.GreetingActivitiesWithCompletion;
import team.boolbee.poc.cadence.entities.workflows.GreetingWorkflow;
import team.boolbee.poc.cadence.entities.workflows.IGreetingWorkflow;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;

import static team.boolbee.poc.cadence.entities.CadenceConstants.DOMAIN;

public class GreetingWorkflowWithActivityCompletionStarter {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowWithActivityCompletionStarter.class);
    public static final String TASK_LIST = "poc-tl-greeting-with-activity-completion";

    public static void main(String[] args) throws ExecutionException, InterruptedException {
        var workflowClient = CadenceHelper.createDefaultWorkflowClient(DOMAIN);
        CadenceHelper.startOneWorker(workflowClient,
                TASK_LIST,
                new Class<?>[] { GreetingWorkflow.class },
                new Object[] { new GreetingActivitiesWithCompletion(
                        workflowClient.newActivityCompletionClient()) });

        // Get a workflow stub using the same task list the worker uses.
        IGreetingWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .build());

        // Execute a workflow returning a future that can be used to wait for the workflow completion.
        CompletableFuture<String> completableFuture = WorkflowClient.execute(
                workflow::getGreeting, "World");
        // Wait for workflow completion.
        System.out.println(completableFuture.get());
        System.exit(0);
    }
}