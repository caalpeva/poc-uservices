package team.boolbee.poc.cadence.entities.workflows;

import com.google.common.base.Throwables;
import com.uber.cadence.*;
import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowException;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.testing.SimulatedTimeoutException;
import com.uber.cadence.testing.TestWorkflowEnvironment;
import com.uber.cadence.worker.Worker;
import com.uber.cadence.workflow.ActivityFailureException;
import com.uber.cadence.workflow.ActivityTimeoutException;
import com.uber.cadence.workflow.ChildWorkflowFailureException;
import com.uber.cadence.workflow.ChildWorkflowTimedOutException;
import org.apache.thrift.TException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import team.boolbee.poc.cadence.entities.activities.GreetingActivities;
import team.boolbee.poc.cadence.entities.activities.GreetingActivitiesThrowsException;

import java.io.IOException;
import java.time.Duration;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Matchers.anyString;
import static org.mockito.Mockito.*;

public class GreetingWorkflowWithExceptionTest {

    private  final String TASK_LIST = "poc-tl-greeting-exception-test";
    private final String WORKFLOW_ID = "WorkflowId";
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
    public void testIOExceptionWithDefaultActivities() throws TException {
        worker.registerWorkflowImplementationTypes(GreetingParentWorkflow.class, GreetingChildWorkflow.class);
        worker.registerActivitiesImplementations(new GreetingActivitiesThrowsException());
        testWorkflowEnvironment.start();

        // Get a workflow stub using the same task list the worker uses.
        IGreetingParentWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingParentWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setExecutionStartToCloseTimeout(Duration.ofSeconds(30))
                        .build());

        try {
            String greeting = workflow.getGreeting("World", false);
            throw new IllegalStateException("unreachable");
        } catch (WorkflowException e) {
            assertTrue(e.getCause() instanceof ChildWorkflowFailureException);
            assertTrue(e.getCause().getCause() instanceof ActivityFailureException);
            assertTrue(e.getCause().getCause().getCause() instanceof IOException);
            assertEquals("Hello World!, this is an exception.", e.getCause().getCause().getCause().getMessage());
        }
    }

    @Test
    public void testTimeoutWithMockActivities() throws TException {
        worker.registerWorkflowImplementationTypes(GreetingParentWorkflow.class, GreetingChildWorkflow.class);

        // Mock an activity that times out.
        GreetingActivities activities = mock(GreetingActivities.class);
        when(activities.composeGreeting(anyString(), anyString()))
                .thenThrow(new SimulatedTimeoutException(TimeoutType.SCHEDULE_TO_START));
        worker.registerActivitiesImplementations(activities);
        testWorkflowEnvironment.start();

        // Get a workflow stub using the same task list the worker uses.
        IGreetingParentWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingParentWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setExecutionStartToCloseTimeout(Duration.ofSeconds(30))
                        .build());

        try {
            String greeting = workflow.getGreeting("World", false);
            throw new IllegalStateException("unreachable");
        } catch (WorkflowException e) {
            assertTrue(e.getCause() instanceof ChildWorkflowFailureException);
            Throwable doubleCause = e.getCause().getCause();
            assertTrue(doubleCause instanceof ActivityTimeoutException);
            ActivityTimeoutException timeoutException = (ActivityTimeoutException) doubleCause;
            assertEquals(TimeoutType.SCHEDULE_TO_START, timeoutException.getTimeoutType());
        }
    }

    @Test
    public void testTimeoutWithMockChildWorkflow() throws TException {
        worker.registerWorkflowImplementationTypes(GreetingParentWorkflow.class);

        // Mock a child workflow that times out.
        worker.addWorkflowImplementationFactory(GreetingChildWorkflow.class,
                () -> {
                    GreetingChildWorkflow child = mock(GreetingChildWorkflow.class);
                    when(child.composeGreeting(anyString(), anyString()))
                            .thenThrow(new SimulatedTimeoutException());
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

        try {
            String greeting = workflow.getGreeting("World", false);
            throw new IllegalStateException("unreachable");
        } catch (WorkflowException e) {
            assertTrue(e.getCause() instanceof ChildWorkflowTimedOutException);
        }
    }
}