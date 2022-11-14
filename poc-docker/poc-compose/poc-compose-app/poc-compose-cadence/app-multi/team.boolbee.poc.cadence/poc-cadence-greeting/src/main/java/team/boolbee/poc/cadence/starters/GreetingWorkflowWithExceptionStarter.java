package team.boolbee.poc.cadence.starters;

import com.google.common.base.Throwables;
import com.uber.cadence.client.WorkflowException;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.CadenceHelper;
import team.boolbee.poc.cadence.entities.activities.GreetingActivities;
import team.boolbee.poc.cadence.entities.activities.GreetingActivitiesThrowsException;
import team.boolbee.poc.cadence.entities.workflows.GreetingChildWorkflow;
import team.boolbee.poc.cadence.entities.workflows.GreetingParentWorkflow;
import team.boolbee.poc.cadence.entities.workflows.IGreetingParentWorkflow;

import java.time.Duration;

import static team.boolbee.poc.cadence.entities.CadenceConstants.DOMAIN;

public class GreetingWorkflowWithExceptionStarter {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowWithExceptionStarter.class);

    public static final String TASK_LIST = "poc-tl-greeting-exception";
    public static void main(String[] args) {
        var workflowClient = CadenceHelper.createDefaultWorkflowClient(DOMAIN);
        CadenceHelper.startOneWorker(workflowClient,
                TASK_LIST,
                new Class<?>[] { GreetingParentWorkflow.class, GreetingChildWorkflow.class },
                new Object[] { new GreetingActivitiesThrowsException() });

        // Get a workflow stub using the same task list the worker uses.
        IGreetingParentWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingParentWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        //.setExecutionStartToCloseTimeout(Duration.ofSeconds(30))
                        .build());

        try {
            String greeting = workflow.getGreeting("World", false);
            throw new IllegalStateException("unreachable");
        } catch (WorkflowException e) {
            Throwable cause = Throwables.getRootCause(e);
            System.out.println(cause.getMessage());
            System.out.println("\nStack Trace:\n" + Throwables.getStackTraceAsString(e));
        }

        System.exit(0);
    }
}