package team.boolbee.poc.cadence.starters;

import com.uber.cadence.TerminateWorkflowExecutionRequest;
import com.uber.cadence.WorkflowExecution;
import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.internal.compatibility.Thrift2ProtoAdapter;
import com.uber.cadence.internal.compatibility.proto.serviceclient.IGrpcServiceStubs;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import team.boolbee.poc.cadence.entities.CadenceHelper;
import team.boolbee.poc.cadence.entities.activities.GreetingActivities;
import team.boolbee.poc.cadence.entities.workflows.GreetingCronWorkflow;
import team.boolbee.poc.cadence.entities.workflows.IGreetingCronWorkflow;

import static team.boolbee.poc.cadence.entities.CadenceConstants.DOMAIN;

public class GreetingCronWorkflowStarter {
    private static Logger logger = LoggerFactory.getLogger(GreetingCronWorkflowStarter.class);

    public static final String TASK_LIST = "poc-tl-greeting-cron";
    public static final String WORKFLOW_ID = "CronWorkflowId";

    public static void main(String[] args) throws InterruptedException {
        Thrift2ProtoAdapter cadenceService = new Thrift2ProtoAdapter(IGrpcServiceStubs.newInstance());
        var workflowClient = CadenceHelper.createWorkflowClient(DOMAIN, cadenceService);
        CadenceHelper.startOneWorker(workflowClient,
                TASK_LIST,
                new Class<?>[] { GreetingCronWorkflow.class },
                new Object[] { new GreetingActivities() });

        // Get a workflow stub using the same task list the worker uses.
        var workflow = workflowClient.newWorkflowStub(
                IGreetingCronWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setWorkflowId(WORKFLOW_ID)
                        .build());

        // Start a workflow execution async. Usually this is done from another program.
        WorkflowClient.start(workflow::greetPeriodically, "World");
        //workflow.greetPeriodically("World");
        logger.info("Cron workflow is running");

        // Cron workflow will not stop until it is terminated or cancelled.
        // So we wait some time to see cron run twice then terminate the cron workflow.
        Thread.sleep(90000);

        // execution without RunID set will be used to terminate current run
        WorkflowExecution execution = new WorkflowExecution();
        execution.setWorkflowId(WORKFLOW_ID);
        TerminateWorkflowExecutionRequest request = new TerminateWorkflowExecutionRequest();
        request.setDomain(DOMAIN);
        request.setReason("Terminate cron workflow");
        request.setWorkflowExecution(execution);
        try {
            cadenceService.TerminateWorkflowExecution(request);
            logger.info("Cron workflow is terminated");
        } catch (Exception e) {
            logger.error(e.getMessage());
            e.printStackTrace();
        }

        System.exit(0);
    }
}