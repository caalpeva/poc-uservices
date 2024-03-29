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

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.*;

public class GreetingActivityCompletionTest {

    private  final String TASK_LIST = "poc-tl-greeting-with-activity-completion-test";
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
    public void testGreetingWithDefaultActivities() throws ExecutionException, InterruptedException {
        worker.registerActivitiesImplementations(new GreetingActivitiesWithCompletion(
                workflowClient.newActivityCompletionClient()));
        testWorkflowEnvironment.start();

        // Get a workflow stub using the same task list the worker uses.
        IGreetingWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .build());

        // Execute a workflow asynchronously and wait for workflow completion.
        CompletableFuture<String> completableFuture = WorkflowClient.execute(workflow::getGreeting, "World");
        assertEquals("Hello World!", completableFuture.get());
    }

    @Test
    public void testGreetingWithMockActivities() throws ExecutionException, InterruptedException {
        GreetingActivitiesWithCompletion activities = mock(GreetingActivitiesWithCompletion.class);
        when(activities.composeGreeting("Hello", "World")).thenReturn("Hello World!");
        worker.registerActivitiesImplementations(activities);
        testWorkflowEnvironment.start();

        // Get a workflow stub using the same task list the worker uses.
        IGreetingWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .build());

        // Execute a workflow asynchronously and wait for workflow completion.
        CompletableFuture<String> completableFuture = WorkflowClient.execute(workflow::getGreeting, "World");
        assertEquals("Hello World!", completableFuture.get());

        verify(activities, times(1)).composeGreeting("Hello", "World");
    }
}