package team.boolbee.poc.cadence.starters;

import com.google.common.base.Throwables;
import com.uber.cadence.TerminateWorkflowExecutionRequest;
import com.uber.cadence.WorkflowExecution;
import com.uber.cadence.client.*;
import com.uber.cadence.internal.compatibility.Thrift2ProtoAdapter;
import com.uber.cadence.internal.compatibility.proto.serviceclient.IGrpcServiceStubs;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import team.boolbee.poc.cadence.entities.CadenceHelper;
import team.boolbee.poc.cadence.entities.activities.GreetingActivities;
import team.boolbee.poc.cadence.entities.workflows.GreetingCronWorkflow;
import team.boolbee.poc.cadence.entities.workflows.GreetingPeriodicWorkflow;
import team.boolbee.poc.cadence.entities.workflows.IGreetingCronWorkflow;
import team.boolbee.poc.cadence.entities.workflows.IGreetingPeriodicWorkflow;

import java.time.Duration;
import java.util.Optional;

import static team.boolbee.poc.cadence.entities.CadenceConstants.DOMAIN;

public class GreetingPeriodicWorkflowStarter {
    private static Logger logger = LoggerFactory.getLogger(GreetingPeriodicWorkflowStarter.class);

    public static final String TASK_LIST = "poc-tl-greeting-periodic";
    public static final String WORKFLOW_ID = "PeriodicWorkflowId";

    public static void main(String[] args) throws InterruptedException {
        var workflowClient = CadenceHelper.createDefaultWorkflowClient(DOMAIN);
        CadenceHelper.startOneWorker(workflowClient,
                TASK_LIST,
                new Class<?>[] { GreetingPeriodicWorkflow.class },
                new Object[] { new GreetingActivities() });

        // Start a workflow execution. Usually this is done from another program.
        // To ensure that this daemon type workflow is always running try to start it periodically
        // ignoring the duplicated exception.
        // It is only to protect from application level failures.
        // Failures of a workflow worker don't lead to workflow failures.
        WorkflowExecution execution = null;
        for (int i = 0; i < 5; i++) {
            // Print reason of failure of the previous run, before restarting.
            /*if (execution != null) {
                WorkflowStub workflow = workflowClient.newUntypedWorkflowStub(execution, Optional.empty());
                try {
                    workflow.getResult(Void.class);
                } catch (WorkflowException e) {
                    System.out.println("Previous instance failed:\n" + Throwables.getStackTraceAsString(e));
                }
            }*/

            // New stub instance should be created for each new workflow start.
            //var workflow = workflowClient.newWorkflowStub(IGreetingPeriodicWorkflow.class);
            var workflow = workflowClient.newWorkflowStub(
                    IGreetingPeriodicWorkflow.class,
                    new WorkflowOptions.Builder()
                            .setTaskList(TASK_LIST)
                            .setWorkflowId(WORKFLOW_ID)
                            .build());
            try {
                execution = WorkflowClient.start(workflow::greetPeriodically, "World", Duration.ofSeconds(1));
                System.out.println("Started " + execution);
            } catch (DuplicateWorkflowException e) {
                System.out.println("Still running as " + e.getExecution());
            } catch (Throwable e) {
                e.printStackTrace();
                System.exit(1);
            }

            // This value is so low just for the sample purpose. In production workflow
            // it is usually much higher.
            Thread.sleep(10000);
        } // while

        System.exit(0);
    }
}