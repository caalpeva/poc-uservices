package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.*;
import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.testing.TestWorkflowEnvironment;
import com.uber.cadence.worker.Worker;
import org.apache.thrift.TException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.verification.VerificationMode;
import team.boolbee.poc.cadence.entities.activities.GreetingActivities;

import java.time.Duration;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Matchers.anyString;
import static org.mockito.Mockito.*;

public class GreetingPeriodicWorkflowTest {

    private final String TASK_LIST = "poc-tl-greeting-periodic-test";
    private final String WORKFLOW_ID = "WorkflowId";
    private TestWorkflowEnvironment testWorkflowEnvironment;
    private WorkflowClient workflowClient;
    private Worker worker;

    @Before
    public void setUp() {
        testWorkflowEnvironment = TestWorkflowEnvironment.newInstance();
        worker = testWorkflowEnvironment.newWorker(TASK_LIST);
        worker.registerWorkflowImplementationTypes(GreetingPeriodicWorkflow.class);
        workflowClient = testWorkflowEnvironment.newWorkflowClient();
    }

    @After
    public void tearDown() {
        testWorkflowEnvironment.close();
    }

    @Test
    public void testGreetingWithDefaultActivities() throws TException {
        worker.registerActivitiesImplementations(new GreetingActivities());
        testWorkflowEnvironment.start();

        // Get a workflow stub using the same task list the worker uses.
        IGreetingPeriodicWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingPeriodicWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setWorkflowId(WORKFLOW_ID)
                        .build());

        // Start a workflow execution async
        WorkflowExecution workflowExecution = WorkflowClient.start(workflow::greetPeriodically,"World", Duration.ofSeconds(1));
        assertEquals(WORKFLOW_ID, workflowExecution.getWorkflowId());

        // Validate that workflow was continued as new at least once.
        // Use TestWorkflowEnvironment.sleep to execute the unit test without really sleeping.
        testWorkflowEnvironment.sleep(Duration.ofMinutes(1));
        ListClosedWorkflowExecutionsRequest request =
                new ListClosedWorkflowExecutionsRequest()
                        .setDomain(testWorkflowEnvironment.getDomain())
                        .setExecutionFilter(new WorkflowExecutionFilter().setWorkflowId(WORKFLOW_ID));
        ListClosedWorkflowExecutionsResponse listResponse =
                testWorkflowEnvironment.getWorkflowService().ListClosedWorkflowExecutions(request);
        assertTrue(listResponse.getExecutions().size() > 1);
        for (WorkflowExecutionInfo e : listResponse.getExecutions()) {
            assertEquals(WorkflowExecutionCloseStatus.CONTINUED_AS_NEW, e.getCloseStatus());
        }
    }

    @Test
    public void testGreetingWithMockActivities() throws TException {
        GreetingActivities activities = mock(GreetingActivities.class);
        worker.registerActivitiesImplementations(activities);
        testWorkflowEnvironment.start();

        // Get a workflow stub using the same task list the worker uses.
        IGreetingPeriodicWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingPeriodicWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setWorkflowId(WORKFLOW_ID)
                        .build());

        // Start a workflow execution async
        WorkflowExecution workflowExecution = WorkflowClient.start(workflow::greetPeriodically,"World", Duration.ofSeconds(1));
        assertEquals(WORKFLOW_ID, workflowExecution.getWorkflowId());

        // Validate that workflow was continued as new at least once.
        // Use TestWorkflowEnvironment.sleep to execute the unit test without really sleeping.
        testWorkflowEnvironment.sleep(Duration.ofMinutes(1));
        ListClosedWorkflowExecutionsRequest request =
                new ListClosedWorkflowExecutionsRequest()
                        .setDomain(testWorkflowEnvironment.getDomain())
                        .setExecutionFilter(new WorkflowExecutionFilter().setWorkflowId(WORKFLOW_ID));
        ListClosedWorkflowExecutionsResponse listResponse =
                testWorkflowEnvironment.getWorkflowService().ListClosedWorkflowExecutions(request);
        assertTrue(listResponse.getExecutions().size() > 1);
        for (WorkflowExecutionInfo e : listResponse.getExecutions()) {
            assertEquals(WorkflowExecutionCloseStatus.CONTINUED_AS_NEW, e.getCloseStatus());
        }

        verify(activities, atLeast(60)).composeGreeting(anyString(), anyString());
    }
}
