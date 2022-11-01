package team.boolbee.poc.cadence.starters;

import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.CadenceHelper;
import team.boolbee.poc.cadence.entities.activities.GreetingActivities;
import team.boolbee.poc.cadence.entities.workflows.GreetingWorkflow;
import team.boolbee.poc.cadence.entities.workflows.GreetingWorkflowWithAsyncActivities;
import team.boolbee.poc.cadence.entities.workflows.IGreetingWorkflow;

import static team.boolbee.poc.cadence.entities.CadenceConstants.*;

public class GreetingWorkflowWithAsyncActivitiesStarter {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowWithAsyncActivitiesStarter.class);

    public static void main(String[] args) {
        var workflowClient = CadenceHelper.createWorkflowClient(DOMAIN);
        CadenceHelper.startOneWorker(workflowClient,
                TASK_LIST_GREETING_WITH_ASYNC_ACTIVITIES,
                new Class<?>[] { GreetingWorkflowWithAsyncActivities.class },
                new Object[] { new GreetingActivities() });

        // Get a workflow stub using the same task list the worker uses.
        IGreetingWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST_GREETING_WITH_ASYNC_ACTIVITIES)
                        .build());

        // Execute a workflow waiting for it to complete.
        String greeting = workflow.getGreeting("World");
        System.out.println(greeting);
        System.exit(0);
    }
}