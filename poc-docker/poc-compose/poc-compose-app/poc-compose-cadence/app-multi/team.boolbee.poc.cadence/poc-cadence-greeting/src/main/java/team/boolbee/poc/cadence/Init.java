package team.boolbee.poc.cadence;

import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowClientOptions;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.serviceclient.ClientOptions;
import com.uber.cadence.serviceclient.WorkflowServiceTChannel;
import com.uber.cadence.worker.Worker;
import com.uber.cadence.worker.WorkerFactory;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.activities.GreetingWithDelayActivities;
import team.boolbee.poc.cadence.workflows.GreetingWorkflow;
import team.boolbee.poc.cadence.workflows.IGreetingWorkflow;

import java.time.Duration;

import static team.boolbee.poc.cadence.Constants.DOMAIN;
import static team.boolbee.poc.cadence.Constants.TASK_LIST;

public class Init {
    private static Logger logger = Workflow.getLogger(Init.class);

    public static void main(String[] args) {
        WorkflowClient workflowClient =
                WorkflowClient.newInstance(
                        new WorkflowServiceTChannel(ClientOptions.defaultInstance()),
                        WorkflowClientOptions.newBuilder().setDomain(DOMAIN).build());
        // Get worker to poll the task list.
        WorkerFactory factory = WorkerFactory.newInstance(workflowClient);
        Worker worker = factory.newWorker(TASK_LIST);
        worker.registerWorkflowImplementationTypes(GreetingWorkflow.class);
        worker.registerActivitiesImplementations(new GreetingWithDelayActivities());
        factory.start();

        // Get a workflow stub using the same task list the worker uses.
//        IGreetingWorkflow workflow = workflowClient.newWorkflowStub(IGreetingWorkflow.class);
        IGreetingWorkflow workflow = workflowClient.newWorkflowStub(IGreetingWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setExecutionStartToCloseTimeout(Duration.ofSeconds(30))
                        .build());
        // Execute a workflow waiting for it to complete.
        String greeting = workflow.getGreeting("World");
        System.out.println(greeting);

        System.exit(0);

    }
}