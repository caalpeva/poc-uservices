package team.boolbee.poc.cadence.entities.activities;

import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.testing.TestWorkflowEnvironment;
import com.uber.cadence.worker.Worker;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import team.boolbee.poc.cadence.entities.workflows.GreetingWorkflowWithRetries;
import team.boolbee.poc.cadence.entities.workflows.IGreetingWorkflow;

import java.time.Duration;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.*;

public class GreetingActivitiesWithDelayTest {

    private  final String TASK_LIST = "poc-tl-greeting-with-retries-test";
    private TestWorkflowEnvironment testWorkflowEnvironment;
    private WorkflowClient workflowClient;
    private Worker worker;

    @Before
    public void setUp() {
        testWorkflowEnvironment = TestWorkflowEnvironment.newInstance();
        worker = testWorkflowEnvironment.newWorker(TASK_LIST);
        worker.registerWorkflowImplementationTypes(GreetingWorkflowWithRetries.class);
        workflowClient = testWorkflowEnvironment.newWorkflowClient();
    }

    @After
    public void tearDown() {
        testWorkflowEnvironment.close();
    }

    @Test
    public void testGreetingWithDefaultActivities() {
        worker.registerActivitiesImplementations(new GreetingActivitiesWithDelay());
        testWorkflowEnvironment.start();

        // Get a workflow stub using the same task list the worker uses.
        IGreetingWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setExecutionStartToCloseTimeout(Duration.ofSeconds(30))
                        .build());

        // Execute a workflow waiting for it to complete.
        String greeting = workflow.getGreeting("World");
        assertEquals("Hello World!", greeting);
    }

    @Test
    public void testGreetingWithMockActivities() {
        GreetingActivitiesWithDelay activities = mock(GreetingActivitiesWithDelay.class);
        when(activities.composeGreeting("Hello", "World"))
                .thenThrow(
                        new IllegalStateException("not yet"),
                        new IllegalStateException("not yet"),
                        new IllegalStateException("not yet"))
                .thenReturn("Hello World!");
        worker.registerActivitiesImplementations(activities);
        testWorkflowEnvironment.start();

        // Get a workflow stub using the same task list the worker uses.
        IGreetingWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setExecutionStartToCloseTimeout(Duration.ofSeconds(30))
                        .build());

        // Execute a workflow waiting for it to complete.
        String greeting = workflow.getGreeting("World");
        assertEquals("Hello World!", greeting);

        verify(activities, times(4)).composeGreeting(anyString(), anyString());
    }
}
