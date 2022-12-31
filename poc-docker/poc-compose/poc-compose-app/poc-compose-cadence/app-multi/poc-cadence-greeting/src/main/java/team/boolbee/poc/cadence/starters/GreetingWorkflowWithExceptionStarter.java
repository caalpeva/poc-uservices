package team.boolbee.poc.cadence.starters;

import com.google.common.base.Throwables;
import com.uber.cadence.client.WorkflowException;
import com.uber.cadence.client.WorkflowOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import team.boolbee.poc.cadence.entities.CadenceManager;
import team.boolbee.poc.cadence.entities.activities.GreetingActivitiesThrowsException;
import team.boolbee.poc.cadence.entities.workflows.GreetingChildWorkflow;
import team.boolbee.poc.cadence.entities.workflows.GreetingParentWorkflow;
import team.boolbee.poc.cadence.entities.workflows.IGreetingParentWorkflow;

import static team.boolbee.poc.cadence.Constants.CADENCE_DOMAIN;

public class GreetingWorkflowWithExceptionStarter {
    private static Logger logger = LoggerFactory.getLogger(GreetingWorkflowWithExceptionStarter.class);

    public static final String TASK_LIST = "poc-tl-greeting-exception";
    public static void main(String[] args) {
        var workflowClient = CadenceManager.createDefaultWorkflowClient(CADENCE_DOMAIN);
        CadenceManager.startOneWorker(workflowClient,
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
            System.out.println(greeting);
            throw new IllegalStateException("unreachable");
        } catch (WorkflowException e) {
            Throwable cause = Throwables.getRootCause(e);
            logger.error(cause.getMessage());
            //logger.error("\nStack Trace:\n" + Throwables.getStackTraceAsString(e));
            //e.printStackTrace();
        }

        System.exit(0);
    }
}