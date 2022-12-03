package team.boolbee.poc.cadence.starters;

import com.uber.cadence.DescribeWorkflowExecutionRequest;
import com.uber.cadence.DescribeWorkflowExecutionResponse;
import com.uber.cadence.SearchAttributes;
import com.uber.cadence.WorkflowExecution;
import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.converter.JsonDataConverter;
import com.uber.cadence.workflow.Workflow;
import com.uber.cadence.workflow.WorkflowUtils;
import org.apache.commons.lang.RandomStringUtils;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.CadenceHelper;
import team.boolbee.poc.cadence.entities.SignaledWorkflowStatus;
import team.boolbee.poc.cadence.entities.workflows.GreetingWorkflowWithSignalsAndPollResponse;
import team.boolbee.poc.cadence.entities.workflows.IGreetingWorkflowWithSignals;

import java.time.Duration;

import static team.boolbee.poc.cadence.entities.CadenceConstants.DOMAIN;

public class GreetingSignaledAndPollResponseWorkflowStarter {
    private static Logger logger = Workflow.getLogger(GreetingSignaledAndPollResponseWorkflowStarter.class);

    public static final String TASK_LIST = "poc-tl-greeting-with-signals";

    public static final String WORKFLOW_ID = RandomStringUtils.randomAlphabetic(10); // In a real application use a business ID like customer ID or order ID

    public static void main(String[] args) throws Exception {
        var workflowClient = CadenceHelper.createDefaultWorkflowClient(DOMAIN);
        CadenceHelper.startOneWorker(workflowClient,
                TASK_LIST,
                new Class<?>[] { GreetingWorkflowWithSignalsAndPollResponse.class },
                new Object[] {});

        // Get a workflow stub using the same task list the worker uses.
        IGreetingWorkflowWithSignals workflow = workflowClient.newWorkflowStub(
                IGreetingWorkflowWithSignals.class,
                new WorkflowOptions.Builder().setTaskList(TASK_LIST)
                        .setWorkflowId(WORKFLOW_ID)
                        .setExecutionStartToCloseTimeout(Duration.ofSeconds(30))
                        .build());

        // Start workflow asynchronously to not use another thread to signal.
        WorkflowClient.start(workflow::getGreetings);
        // After start for getGreeting returns, the workflow is guaranteed to be started.
        // So we can send a signal to it using the workflow stub.
        // This workflow keeps receiving signals until exit is called
        String signal = "World";

        final SignaledWorkflowStatus workflowStatus = CadenceHelper.signalAndWait(workflowClient,
                DOMAIN,
                WORKFLOW_ID,
                "",
                () -> { workflow.waitForName(signal); }, // sends waitForName signal
                JsonDataConverter.getInstance(),
                "IGreetingWorkflowWithSignals::waitForName",
                signal);

        System.out.printf("result: isReceived: %b, isProccessed: %b, isRunning: %b, runID: %s \n",
                workflowStatus.isSignalReceived(),
                workflowStatus.isSignalProcessed(),
                workflowStatus.isWorkflowRunning(),
                workflowStatus.getRunId());

        if (workflowStatus.isSignalProcessed()) {
            // Get results from search attribute `CustomKeywordField`
            WorkflowExecution execution = new WorkflowExecution();
            execution.setWorkflowId(WORKFLOW_ID);
            execution.setRunId(workflowStatus.getRunId()); // make sure to sure the same runID in case the current run changes

            DescribeWorkflowExecutionRequest request = new DescribeWorkflowExecutionRequest();
            request.setDomain(DOMAIN);
            request.setExecution(execution);

            DescribeWorkflowExecutionResponse resp = workflowClient.getService().DescribeWorkflowExecution(request);
            SearchAttributes searchAttributes = resp.workflowExecutionInfo.getSearchAttributes();
            String keyword = WorkflowUtils.getValueFromSearchAttributes(searchAttributes, "CustomKeywordField", String.class);
            System.out.printf("Signal result is: %s\n", keyword);
        } else {
            System.out.printf("No result because signal was not processed");
        }

        System.exit(0);
    }
}