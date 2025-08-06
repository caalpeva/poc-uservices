package team.boolbee.poc.cadence.entities;

import com.uber.cadence.*;
import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowClientOptions;
import com.uber.cadence.client.WorkflowStub;
import com.uber.cadence.converter.DataConverter;
import com.uber.cadence.internal.common.WorkflowExecutionUtils;
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
import org.slf4j.LoggerFactory;

import java.nio.charset.Charset;
import java.util.Arrays;
import java.util.Optional;

public class CadenceManager {
    private final static Logger logger = LoggerFactory.getLogger(CadenceManager.class);

    public CadenceManager() {

    }

    public boolean registerDomain(String name) {
        int retentionPeriodInDays = 1;
        IWorkflowService cadenceService = new WorkflowServiceTChannel(ClientOptions.defaultInstance());
        RegisterDomainRequest request = new RegisterDomainRequest();
        //request.setDescription("Proof of concept");
        request.setEmitMetric(false);
        request.setName(name);
        request.setWorkflowExecutionRetentionPeriodInDays(retentionPeriodInDays);
        try {
            cadenceService.RegisterDomain(request);
            logger.info(String.format("Successfully registered domain %s with retentionDays=%s", name, retentionPeriodInDays));
            return true;
        } catch (DomainAlreadyExistsError e) {
            logger.warn(String.format("Domain %s is already registered", name));
        } catch (TException e) {
            logger.warn(e.getCause().getCause().getMessage());
        }

        return false;
    }

    public WorkflowClient createDefaultWorkflowClient(String domain) {
        return createWorkflowClient(domain,
                //new Thrift2ProtoAdapter(IGrpcServiceStubs.newInstance()));
                new WorkflowServiceTChannel(ClientOptions.defaultInstance()));
    }

    public WorkflowClient createWorkflowClient(String domain, IWorkflowService service) {
        return WorkflowClient.newInstance(
                service,
                WorkflowClientOptions.newBuilder()
                        .setDomain(domain)
                        .build());
    }

    public void startWorker(WorkflowClient workflowClient,
                                      String taskList,
                                      Class<?>...workflowImplementationTypes) {
        startWorker(workflowClient, taskList, workflowImplementationTypes, null);
    }

    public void startWorker(WorkflowClient workflowClient,
                            String taskList,
                            Object...activitiesImplementations) {
        startWorker(workflowClient, taskList, null, activitiesImplementations);
    }

    public void startWorker(WorkflowClient workflowClient,
                            String taskList,
                            Class<?>[] workflowImplementationTypes,
                            Object[] activitiesImplementations) {
        WorkerFactory factory = WorkerFactory.newInstance(workflowClient,
                WorkerFactoryOptions.newBuilder()
                        .setMaxWorkflowThreadCount(1000)
                        .setStickyCacheSize(100)
                        .setDisableStickyExecution(false)
                        .build());

        Worker worker = factory.newWorker(taskList,
                WorkerOptions.newBuilder()
                        .setMaxConcurrentActivityExecutionSize(100)
                        .setMaxConcurrentWorkflowExecutionSize(100)
                        .build());

        if (workflowImplementationTypes != null) {
            worker.registerWorkflowImplementationTypes(workflowImplementationTypes);
        }

        if (activitiesImplementations != null) {
            worker.registerActivitiesImplementations(activitiesImplementations);
        }

        // Start all workers created by this factory
        factory.start();
    }

    public String queryWorkflowExecution(String domain, String queryType, String workflowId, String runId) {
        WorkflowExecution workflowExecution = new WorkflowExecution();
        workflowExecution.setWorkflowId(workflowId);
        workflowExecution.setRunId(runId);

        WorkflowClient workflowClient = createDefaultWorkflowClient(domain);
        WorkflowStub untypedWorkflow = workflowClient.newUntypedWorkflowStub(workflowExecution, Optional.empty());
        return untypedWorkflow.query(queryType, String.class);
    }

    public String printWorkflowExecutionHistory(String domain, String queryType, String workflowId, String runId) {
        WorkflowExecution workflowExecution = new WorkflowExecution();
        workflowExecution.setWorkflowId(workflowId);
        workflowExecution.setRunId(runId);

        IWorkflowService cadenceService = new WorkflowServiceTChannel(ClientOptions.defaultInstance());
        return WorkflowExecutionUtils.prettyPrintHistory(cadenceService, domain, workflowExecution, true);
    }

    public SignaledWorkflowStatus signalAndWait(WorkflowClient workflowClient,
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