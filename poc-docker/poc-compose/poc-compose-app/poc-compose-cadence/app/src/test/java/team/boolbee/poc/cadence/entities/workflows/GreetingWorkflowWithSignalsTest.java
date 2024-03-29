package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.testing.TestWorkflowEnvironment;
import com.uber.cadence.worker.Worker;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.time.Duration;
import java.util.List;

import static org.junit.Assert.assertEquals;

public class GreetingWorkflowWithSignalsTest {

    private  final String TASK_LIST = "poc-tl-greeting-signaled-test";
    private TestWorkflowEnvironment testWorkflowEnvironment;
    private WorkflowClient workflowClient;
    private Worker worker;

    @Before
    public void setUp() {
        testWorkflowEnvironment = TestWorkflowEnvironment.newInstance();
        worker = testWorkflowEnvironment.newWorker(TASK_LIST);
        worker.registerWorkflowImplementationTypes(GreetingWorkflowWithSignals.class);
        workflowClient = testWorkflowEnvironment.newWorkflowClient();
    }

    @After
    public void tearDown() {
        testWorkflowEnvironment.close();
    }

    @Test
    public void testGreetings() {
        testWorkflowEnvironment.start();

        // Get a workflow stub using the same task list the worker uses.
        IGreetingWorkflowWithSignals workflow = workflowClient.newWorkflowStub(
                IGreetingWorkflowWithSignals.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setExecutionStartToCloseTimeout(Duration.ofSeconds(30))
                        .build());

        // Start workflow asynchronously to not use another thread to signal.
        WorkflowClient.start(workflow::getGreetings);

        // After start for getGreeting returns, the workflow is guaranteed to be started.
        // So we can send a signal to it using workflow stub immediately.
        // But just to demonstrate the unit testing of a long running workflow adding a long sleep here.
        //testWorkflowEnvironment.sleep(Duration.ofDays(1));
        testWorkflowEnvironment.sleep(Duration.ofSeconds(10));
        // This workflow keeps receiving signals until exit is called
        workflow.waitForName("World");
        workflow.waitForName("Universe");
        workflow.exit();

        // Calling synchronous getGreeting after workflow has started reconnects to the existing
        // workflow and blocks until result is available. Note that this behavior assumes that WorkflowOptions
        // are not configured with WorkflowIdReusePolicy.AllowDuplicate. In that case the call would fail with
        // WorkflowExecutionAlreadyStartedException.
        List<String> greetings = workflow.getGreetings();
        assertEquals(2, greetings.size());
        assertEquals("Hello World!", greetings.get(0));
        assertEquals("Hello Universe!", greetings.get(1));
    }
}