package team.boolbee.poc.cadence.entities;

import com.uber.cadence.*;
import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowClientOptions;
import com.uber.cadence.converter.DataConverter;
import com.uber.cadence.internal.compatibility.Thrift2ProtoAdapter;
import com.uber.cadence.internal.compatibility.proto.serviceclient.IGrpcServiceStubs;
import com.uber.cadence.serviceclient.ClientOptions;
import com.uber.cadence.serviceclient.IWorkflowService;
import com.uber.cadence.serviceclient.WorkflowServiceTChannel;
import com.uber.cadence.worker.Worker;
import com.uber.cadence.worker.WorkerFactory;
import com.uber.cadence.worker.WorkerFactoryOptions;
import com.uber.cadence.worker.WorkerOptions;
import com.uber.cadence.workflow.Workflow;
import org.apache.thrift.TException;
import org.slf4j.Logger;

import java.nio.charset.Charset;
import java.util.Arrays;

public class CadenceHelper {
    private static Logger logger = Workflow.getLogger(CadenceHelper.class);


    public static WorkflowClient createDefaultWorkflowClient(String domain) {
        return createWorkflowClient(domain,
                //new Thrift2ProtoAdapter(IGrpcServiceStubs.newInstance()));
                new WorkflowServiceTChannel(ClientOptions.defaultInstance()));
    }

    public static WorkflowClient createWorkflowClient(String domain, IWorkflowService service) {
        return WorkflowClient.newInstance(
                service,
                WorkflowClientOptions.newBuilder()
                        .setDomain(domain)
                        .build());
    }

    // Get worker to poll the task list.
    public static void startOneWorker(WorkflowClient workflowClient,
                                      String taskList,
                                      Class<?>[] workflowImplementationTypes,
                                      Object[] activitiesImplementations) {
        //WorkerFactory factory = WorkerFactory.newInstance(workflowClient);
        WorkerFactory factory = WorkerFactory.newInstance(workflowClient,
                WorkerFactoryOptions.newBuilder()
                        .setMaxWorkflowThreadCount(1000)
                        .setStickyCacheSize(100)
                        .setDisableStickyExecution(false)
                        .build());

        //Worker worker = factory.newWorker(taskList);
        Worker worker = factory.newWorker(taskList,
                WorkerOptions.newBuilder()
                        .setMaxConcurrentActivityExecutionSize(100)
                        .setMaxConcurrentWorkflowExecutionSize(100)
                        .build());
        worker.registerWorkflowImplementationTypes(workflowImplementationTypes);
        worker.registerActivitiesImplementations(activitiesImplementations);

        // Start all workers created by this factory
        factory.start();
    }

    public static SignaledWorkflowStatus signalAndWait(WorkflowClient workflowClient,
                                String domain,
                                String workflowId,
                                String runId,
                                Runnable signalOperation,
                                DataConverter dataConverter,
                                String signalName,
                                Object... signalArgs) throws Exception {
        final byte[] signalData = dataConverter.toData(signalArgs);
        SignaledWorkflowStatus workflowStatus = new SignaledWorkflowStatus();

        // get the current eventID
        WorkflowExecution execution = new WorkflowExecution();
        execution.setWorkflowId(workflowId);
        execution.setRunId(runId);

        DescribeWorkflowExecutionRequest request = new DescribeWorkflowExecutionRequest();
        request.setDomain(domain);
        request.setExecution(execution);

        DescribeWorkflowExecutionResponse response = workflowClient.getService().DescribeWorkflowExecution(request);
        long currentEventId = response.workflowExecutionInfo.historyLength;
        workflowStatus.setRunId(response.workflowExecutionInfo.execution.runId);

        // send signal
        signalOperation.run();

        // Poll history starting from currentEventId,
        // then wait until the signal is received, and then wait until it's
        // processed(decisionTaskCompleted)
        workflowStatus.setSignalReceived(false);
        workflowStatus.setSignalProcessed(false);
        workflowStatus.setWorkflowRunning(!response.workflowExecutionInfo.isSetCloseStatus());

        while (workflowStatus.isWorkflowRunning() && !workflowStatus.isSignalProcessed()) {
            GetWorkflowExecutionHistoryRequest historyRequest = new GetWorkflowExecutionHistoryRequest();
            historyRequest.setDomain(domain);
            historyRequest.setExecution(execution);
            historyRequest.setWaitForNewEvent(true);
            String token = String.format("{\"RunID\":\"%s\",\"FirstEventID\":0,\"NextEventID\":%d,\"IsWorkflowRunning\":true,\"PersistenceToken\":null,\"TransientDecision\":null,\"BranchToken\":null}",
                    workflowStatus.getRunId(), currentEventId + 1);
            historyRequest.setNextPageToken(token.getBytes(Charset.defaultCharset()));

            GetWorkflowExecutionHistoryResponse historyResponse = workflowClient.getService().GetWorkflowExecutionHistory(historyRequest);
            token = new String(historyResponse.getNextPageToken(), Charset.defaultCharset());
            workflowStatus.setWorkflowRunning(token.contains("\"IsWorkflowRunning\":true"));

            for (HistoryEvent event : historyResponse.history.events) {
                if (!workflowStatus.isSignalReceived()) {
                    // wait for signal received
                    if (event.getEventType() == EventType.WorkflowExecutionSignaled) {
                        final byte[] eventSignalData = event.getWorkflowExecutionSignaledEventAttributes().getInput();
                        final String eventSignalName = event.getWorkflowExecutionSignaledEventAttributes().getSignalName();
                        if (Arrays.equals(eventSignalData, signalData) && eventSignalName.equals(signalName)) {
                            workflowStatus.setSignalReceived(true);
                        } else if (Arrays.equals(eventSignalData, signalData) || eventSignalName.equals(signalName)) {
                            System.out.println(
                                    "[WARN] either signal event data or signalName doesn't match, is the signalArgs and signalName correct?");
                        }
                    }
                } else {
                    // signal is received, now wait for first decision task complete
                    if (event.getEventType() == EventType.DecisionTaskCompleted) {
                        workflowStatus.setSignalProcessed(true);
                        break;
                    }
                }
                currentEventId = event.getEventId();
            } // for
        } // while

        return workflowStatus;
    }
}