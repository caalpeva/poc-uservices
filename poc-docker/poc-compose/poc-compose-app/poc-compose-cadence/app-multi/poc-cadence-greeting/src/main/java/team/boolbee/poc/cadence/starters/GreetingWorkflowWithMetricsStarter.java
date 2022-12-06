package team.boolbee.poc.cadence.starters;

import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowClientOptions;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.internal.compatibility.Thrift2ProtoAdapter;
import com.uber.cadence.internal.compatibility.proto.serviceclient.IGrpcServiceStubs;
import com.uber.cadence.serviceclient.ClientOptions;
import com.uber.cadence.serviceclient.IWorkflowService;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.CadenceHelper;
import team.boolbee.poc.cadence.entities.activities.GreetingActivities;
import team.boolbee.poc.cadence.entities.workflows.GreetingWorkflow;
import team.boolbee.poc.cadence.entities.workflows.IGreetingWorkflow;
import team.boolbee.poc.cadence.prometheus.PrometheusHelper;

import java.io.IOException;

import static team.boolbee.poc.cadence.entities.CadenceConstants.DOMAIN;

public class GreetingWorkflowWithMetricsStarter {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowWithMetricsStarter.class);

    public static final String TASK_LIST = "poc-tl-greeting-metrics";
    public static void main(String[] args) throws IOException {
        //final ClientOptions clientOptions = ClientOptions.newBuilder().build();
        final ClientOptions clientOptions = ClientOptions.newBuilder()
                .setMetricsScope(PrometheusHelper.createMetricScope())
                .setPort(7833)
                .build();

        IWorkflowService cadenceService = new Thrift2ProtoAdapter(IGrpcServiceStubs.newInstance(clientOptions));
        var workflowClient = CadenceHelper.createWorkflowClient(DOMAIN, cadenceService);
        CadenceHelper.startOneWorker(workflowClient,
                TASK_LIST,
                new Class<?>[] { GreetingWorkflow.class },
                new Object[] { new GreetingActivities() });

        // Get a workflow stub using the same task list the worker uses.
        //IGreetingWorkflowWithTaskList workflow = workflowClient.newWorkflowStub(IGreetingWorkflowWithTaskList.class);
        IGreetingWorkflow workflow = workflowClient.newWorkflowStub(
                IGreetingWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .build());

        // Execute a workflow waiting for it to complete.
        String greeting = workflow.getGreeting("World");
        System.out.println(greeting);
        //System.exit(0);
    }
}