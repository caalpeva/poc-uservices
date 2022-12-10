package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.testing.TestWorkflowEnvironment;
import com.uber.cadence.worker.Worker;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import team.boolbee.poc.cadence.entities.activities.GreetingActivities;

import java.time.Duration;
import java.util.concurrent.atomic.AtomicReference;

import static org.junit.Assert.assertEquals;
import static org.mockito.Matchers.eq;
import static org.mockito.Mockito.*;

public class GreetingQueryableWorkflowTest {

    private  final String TASK_LIST = "poc-tl-greeting-queryable-test";
    private TestWorkflowEnvironment testWorkflowEnvironment;
    private WorkflowClient workflowClient;
    private Worker worker;

    @Before
    public void setUp() {
        testWorkflowEnvironment = TestWorkflowEnvironment.newInstance();
        worker = testWorkflowEnvironment.newWorker(TASK_LIST);
        worker.registerWorkflowImplementationTypes(GreetingQueryableWorkflow.class);
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
        assertEquals("Hello World!", workflow.queryGreeting());

        // Unit tests should call TestWorkflowEnvironment.sleep.
        // It allows skipping the time if workflow is just waiting on a timer
        // and executing tests of long running workflows very fast.
        // Note that this unit test executes under a second and not
        // over 3 as it would if Thread.sleep(3000) was called.
        testWorkflowEnvironment.sleep(Duration.ofSeconds(3));

        assertEquals("Bye World!", workflow.queryGreeting());
    }
}