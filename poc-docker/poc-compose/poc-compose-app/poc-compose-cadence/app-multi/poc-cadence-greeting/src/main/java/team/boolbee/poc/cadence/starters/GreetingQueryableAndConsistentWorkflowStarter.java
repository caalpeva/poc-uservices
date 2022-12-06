package team.boolbee.poc.cadence.starters;

import com.uber.cadence.QueryConsistencyLevel;
import com.uber.cadence.WorkflowExecution;
import com.uber.cadence.client.QueryOptions;
import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.client.WorkflowStub;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.CadenceHelper;
import team.boolbee.poc.cadence.entities.workflows.GreetingQueryableAndConsistentWorkflow;
import team.boolbee.poc.cadence.entities.workflows.GreetingQueryableWorkflow;
import team.boolbee.poc.cadence.entities.workflows.IGreetingQueryableWorkflow;

import java.time.Duration;

import static team.boolbee.poc.cadence.entities.CadenceConstants.DOMAIN;

public class GreetingQueryableAndConsistentWorkflowStarter {
    private static Logger logger = Workflow.getLogger(GreetingQueryableAndConsistentWorkflowStarter.class);

    public static final String TASK_LIST = "poc-tl-greeting-queryable-and-consistent";

    public static void main(String[] args) throws InterruptedException {
        var workflowClient = CadenceHelper.createDefaultWorkflowClient(DOMAIN);
        CadenceHelper.startOneWorker(workflowClient,
                TASK_LIST,
                new Class<?>[]{ GreetingQueryableAndConsistentWorkflow.class },
                new Object[]{});

        // Start a workflow execution. Usually this is done from another program.
        // Get a workflow stub using the same task list the worker uses.
        final WorkflowStub workflow = workflowClient.newUntypedWorkflowStub(
                "IGreetingQueryableAndConsistentWorkflow::createGreeting",
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setExecutionStartToCloseTimeout(Duration.ofSeconds(30))
                        .build());


        // Start workflow asynchronously to not use another thread to query.
        final WorkflowExecution wf = workflow.start("World");
        System.out.println("started workflow " + wf.getWorkflowId() + ", " + wf.getRunId());
        System.out.println("initial value after started");
        System.out.println(workflow.queryWithOptions(
                "IGreetingQueryableAndConsistentWorkflow::getCounter",
                        new QueryOptions.Builder()
                                .setQueryConsistencyLevel(QueryConsistencyLevel.STRONG)
                                .build(),
                        Integer.class,
                        Integer.class)); // Should print 0

        // Now we can send a signal to it using workflow stub.
        workflow.signal("IGreetingQueryableAndConsistentWorkflow::increase");
        System.out.println("after increase 1 time");
        System.out.println(
                workflow.queryWithOptions(
                        "IGreetingQueryableAndConsistentWorkflow::getCounter",
                        new QueryOptions.Builder()
                                .setQueryConsistencyLevel(QueryConsistencyLevel.STRONG)
                                .build(),
                        Integer.class,
                        Integer.class)); // Should print 1

        workflow.signal("IGreetingQueryableAndConsistentWorkflow::increase");
        workflow.signal("IGreetingQueryableAndConsistentWorkflow::increase");
        workflow.signal("IGreetingQueryableAndConsistentWorkflow::increase");
        workflow.signal("IGreetingQueryableAndConsistentWorkflow::increase");
        System.out.println("after increase 1+4 times");
        System.out.println(
                workflow.queryWithOptions(
                        "IGreetingQueryableAndConsistentWorkflow::getCounter",
                        new QueryOptions.Builder()
                                .setQueryConsistencyLevel(QueryConsistencyLevel.STRONG)
                                .build(),
                        Integer.class,
                        Integer.class)); // Should print 5

        Thread.sleep(2500);
        System.exit(0);
    }
}