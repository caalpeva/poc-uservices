package team.boolbee.poc.cadence.starters;

import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowOptions;
import org.apache.commons.lang.RandomStringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import team.boolbee.poc.cadence.entities.CadenceManager;
import team.boolbee.poc.cadence.entities.workflows.GreetingWorkflowWithSignals;
import team.boolbee.poc.cadence.entities.workflows.IGreetingWorkflowWithSignals;

import java.time.Duration;
import java.util.List;

import static team.boolbee.poc.cadence.Constants.CADENCE_DOMAIN;

public class GreetingSignaledWorkflowStarter {
    private static Logger logger = LoggerFactory.getLogger(GreetingSignaledWorkflowStarter.class);

    public static final String TASK_LIST = "poc-tl-greeting-with-signals";

    public static void main(String[] args) throws InterruptedException {
        var workflowClient = CadenceManager.createDefaultWorkflowClient(CADENCE_DOMAIN);
        CadenceManager.startOneWorker(workflowClient,
                TASK_LIST,
                new Class<?>[]{ GreetingWorkflowWithSignals.class },
                new Object[]{});

        // In a real application use a business ID like customer ID or order ID
        String workflowId = RandomStringUtils.randomAlphabetic(10);

        // Get a workflow stub using the same task list the worker uses.
        IGreetingWorkflowWithSignals workflow = workflowClient.newWorkflowStub(
                IGreetingWorkflowWithSignals.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setWorkflowId(workflowId)
                        .setExecutionStartToCloseTimeout(Duration.ofSeconds(30))
                        .build());

        // Start workflow asynchronously to not use another thread to signal.
        WorkflowClient.start(workflow::getGreetings);
        // After start for getGreeting returns, the workflow is guaranteed to be started.
        // So we can send a signal to it using the workflow stub.
        // This workflow keeps receiving signals until exit is called
        workflow.waitForName("World"); // sends waitForName signal

        // Create a new stub using the workflowId.
        // This is to demonstrate that to send a signal only the workflowId is required.
        IGreetingWorkflowWithSignals workflowById = workflowClient.newWorkflowStub(
                IGreetingWorkflowWithSignals.class, workflowId);
        workflowById.waitForName("Universe"); // sends waitForName signal
        workflowById.exit(); // sends exit signal

        // Calling synchronous getGreeting after workflow has started reconnects to the existing
        // workflow and blocks until a result is available. Note that this behavior assumes that
        // WorkflowOptions are not configured with WorkflowIdReusePolicy.AllowDuplicate. In that case
        // the call would fail with WorkflowExecutionAlreadyStartedException.
        List<String> greetings = workflowById.getGreetings();
        System.out.println(greetings);
        System.exit(0);
    }
}