package team.boolbee.poc.cadence;

import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowClientOptions;
import com.uber.cadence.serviceclient.ClientOptions;
import com.uber.cadence.serviceclient.WorkflowServiceTChannel;
import com.uber.cadence.worker.Worker;
import com.uber.cadence.worker.WorkerFactory;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.workflows.PocWorkflowImpl;

public class Init {
    private static Logger logger = Workflow.getLogger(Init.class);
    private static String DOMAIN = "test-domain";
    private static String TASK_LIST = "PocTaskList";

    public static void main(String[] args) {
        WorkflowClient workflowClient =
                WorkflowClient.newInstance(
                        new WorkflowServiceTChannel(ClientOptions.defaultInstance()),
                        WorkflowClientOptions.newBuilder().setDomain(DOMAIN).build());
        // Get worker to poll the task list.
        WorkerFactory factory = WorkerFactory.newInstance(workflowClient);
        Worker worker = factory.newWorker(TASK_LIST);
        worker.registerWorkflowImplementationTypes(PocWorkflowImpl.class);
        factory.start();

//      The code is slightly different if you are using client version prior to 3.0.0:
//        Worker.Factory factory = new Worker.Factory(DOMAIN);
//        Worker worker = factory.newWorker(TASK_LIST);
//        worker.registerWorkflowImplementationTypes(PocWorkflowImpl.class);
//        factory.start();
    }
}