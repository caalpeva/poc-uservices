package team.boolbee.poc.cadence.entities.activities;

import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.testing.TestWorkflowEnvironment;
import com.uber.cadence.worker.Worker;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import team.boolbee.poc.cadence.entities.workflows.GreetingWorkflow;
import team.boolbee.poc.cadence.entities.workflows.IGreetingWorkflow;

import static org.junit.Assert.assertEquals;
import static org.mockito.Matchers.anyString;
import static org.mockito.Mockito.*;
import static org.mockito.Mockito.times;

public class GreetingActivitiesTest {

    private  final String TASK_LIST = "poc-tl-greeting-test";
    private TestWorkflowEnvironment testWorkflowEnvironment;
    private WorkflowClient workflowClient;
    private Worker worker;

    @Before
    public void setUp() {
        testWorkflowEnvironment = TestWorkflowEnvironment.newInstance();
        worker = testWorkflowEnvironment.newWorker(TASK_LIST);
        worker.registerWorkflowImplementationTypes(GreetingWorkflow.class);
        workflowClient = testWorkflowEnvironment.newWorkflowClient();
    }

    @After
    public void tearDown() {
        testWorkflowEnvironment.close();
    }

    @Test
    public void testGreetingWithDefaultActivities() {
        worker.registerActivitiesImplementations(new GreetingActivities());
        testWorkflowEnvironment.start();

        // Get a workflow stub using the same task list the worker uses.
        IGreetingWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .build());

        // Execute a workflow waiting for it to complete.
        String greeting = workflow.getGreeting("World");
        assertEquals("Hello World!", greeting);
    }

    @Test
    public void testGreetingWithMockActivities() {
        GreetingActivities activities = mock(GreetingActivities.class);
        when(activities.composeGreeting("Hello", "World")).thenReturn("Hello World!");
        worker.registerActivitiesImplementations(activities);
        testWorkflowEnvironment.start();

        // Get a workflow stub using the same task list the worker uses.
        IGreetingWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .build());

        // Execute a workflow waiting for it to complete.
        String greeting = workflow.getGreeting("World");
        assertEquals("Hello World!", greeting);

        verify(activities, times(1)).composeGreeting("Hello", "World");
    }
}
