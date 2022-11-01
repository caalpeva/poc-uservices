package team.boolbee.poc.cadence.entities;

import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowClientOptions;
import com.uber.cadence.serviceclient.ClientOptions;
import com.uber.cadence.serviceclient.WorkflowServiceTChannel;
import com.uber.cadence.worker.Worker;
import com.uber.cadence.worker.WorkerFactory;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;

public class CadenceHelper {
    private static Logger logger = Workflow.getLogger(CadenceHelper.class);

    public static WorkflowClient createWorkflowClient(String domain) {
        return WorkflowClient.newInstance(
                new WorkflowServiceTChannel(ClientOptions.defaultInstance()),
                WorkflowClientOptions.newBuilder()
                        .setDomain(domain)
                        .build());
    }

    // Get worker to poll the task list.
    public static void startOneWorker(WorkflowClient workflowClient,
                            String taskList,
                            Class<?>[] workflowImplementationTypes,
                            Object[] activitiesImplementations) {
        WorkerFactory factory = WorkerFactory.newInstance(workflowClient);
        Worker worker = factory.newWorker(taskList);
        worker.registerWorkflowImplementationTypes(workflowImplementationTypes);
        worker.registerActivitiesImplementations(activitiesImplementations);
        // Start all workers created by this factory
        factory.start();
    }
}