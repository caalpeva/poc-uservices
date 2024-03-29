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

public class GreetingChildWorkflowTest {

    private  final String TASK_LIST = "poc-tl-greeting-child-test";
    private TestWorkflowEnvironment testWorkflowEnvironment;
    private WorkflowClient workflowClient;
    private Worker worker;

    @Before
    public void setUp() {
        testWorkflowEnvironment = TestWorkflowEnvironment.newInstance();
        workflowClient = testWorkflowEnvironment.newWorkflowClient();
        worker = testWorkflowEnvironment.newWorker(TASK_LIST);
    }

    @After
    public void tearDown() {
        testWorkflowEnvironment.close();
    }

    @Test
    public void testGreetingWithDefaultChildWorkflowAndActivities() {
        worker.registerWorkflowImplementationTypes(GreetingParentWorkflow.class, GreetingChildWorkflow.class);
        worker.registerActivitiesImplementations(new GreetingActivities());
        testWorkflowEnvironment.start();

        // Get a workflow stub using the same task list the worker uses.
        IGreetingParentWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingParentWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setExecutionStartToCloseTimeout(Duration.ofSeconds(30))
                        .build());

        // Execute a workflow waiting for it to complete.
        String greeting = workflow.getGreeting("World", false);
        assertEquals("Hello World!", greeting);
    }

    @Test
    public void testGreetingWithMockChildWorkflow() {
        worker.registerWorkflowImplementationTypes(GreetingParentWorkflow.class);

        // As new mock is created on each decision the only last one is useful to verify calls.
        AtomicReference<IGreetingChildWorkflow> lastChildMock = new AtomicReference<>();
        // Factory is called to create a new workflow object on each decision.
        worker.addWorkflowImplementationFactory(GreetingChildWorkflow.class,
                () -> {
                    GreetingChildWorkflow child = mock(GreetingChildWorkflow.class);
                    when(child.composeGreeting("Hello", "World")).thenReturn("Hello World!");
                    lastChildMock.set(child);
                    return child;
                });

        testWorkflowEnvironment.start();

        // Get a workflow stub using the same task list the worker uses.
        IGreetingParentWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingParentWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setExecutionStartToCloseTimeout(Duration.ofSeconds(30))
                        .build());

        // Execute a workflow waiting for it to complete.
        String greeting = workflow.getGreeting("World", false);
        assertEquals("Hello World!", greeting);

        IGreetingChildWorkflow childWorkflow = lastChildMock.get();
        verify(childWorkflow, times(1)).composeGreeting(eq("Hello"), eq("World"));
    }
}