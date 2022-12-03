package team.boolbee.poc.cadence.starters;

import com.uber.cadence.DescribeWorkflowExecutionRequest;
import com.uber.cadence.DescribeWorkflowExecutionResponse;
import com.uber.cadence.SearchAttributes;
import com.uber.cadence.WorkflowExecution;
import com.uber.cadence.client.WorkflowOptions;
import com.uber.cadence.internal.compatibility.Thrift2ProtoAdapter;
import com.uber.cadence.internal.compatibility.proto.serviceclient.IGrpcServiceStubs;
import com.uber.cadence.workflow.WorkflowUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import team.boolbee.poc.cadence.entities.CadenceHelper;
import team.boolbee.poc.cadence.entities.activities.GreetingActivities;
import team.boolbee.poc.cadence.entities.workflows.GreetingWorkflowWithSearchAttributes;
import team.boolbee.poc.cadence.entities.workflows.IGreetingWorkflow;

import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import static team.boolbee.poc.cadence.entities.CadenceConstants.DOMAIN;

public class GreetingWorkflowWithSearchAttributesStarter {
    private static Logger logger = LoggerFactory.getLogger(GreetingWorkflowWithSearchAttributesStarter.class);

    public static final String TASK_LIST = "poc-tl-greeting-search-attributes";
    public static final String WORKFLOW_ID = UUID.randomUUID().toString();

    public static void main(String[] args) throws InterruptedException {
        Thrift2ProtoAdapter cadenceService = new Thrift2ProtoAdapter(IGrpcServiceStubs.newInstance());
        var workflowClient = CadenceHelper.createWorkflowClient(DOMAIN, cadenceService);
        CadenceHelper.startOneWorker(workflowClient,
                TASK_LIST,
                new Class<?>[] { GreetingWorkflowWithSearchAttributes.class },
                new Object[] { new GreetingActivities() });

        // Get a workflow stub using the same task list the worker uses.
        // Set search attributes in workflowOptions
        var workflow = workflowClient.newWorkflowStub(
                IGreetingWorkflow.class,
                new WorkflowOptions.Builder()
                        .setTaskList(TASK_LIST)
                        .setWorkflowId(WORKFLOW_ID)
                        .setSearchAttributes(generateSearchAttributes())
                        .build());

        // Execute a workflow waiting for it to complete. Usually this is done from another program.
        String greeting = workflow.getGreeting("World");
        System.out.println(greeting);

        // Bellow shows how to read search attributes using DescribeWorkflowExecution API
        // You can do similar things using ListWorkflowExecutions
        WorkflowExecution execution = new WorkflowExecution();
        execution.setWorkflowId(WORKFLOW_ID);

        DescribeWorkflowExecutionRequest request = new DescribeWorkflowExecutionRequest();
        request.setDomain(DOMAIN);
        request.setExecution(execution);

        try {
            DescribeWorkflowExecutionResponse response = cadenceService.DescribeWorkflowExecution(request);
            SearchAttributes searchAttributes = response.workflowExecutionInfo.getSearchAttributes();
            String value = WorkflowUtils.getValueFromSearchAttributes(searchAttributes, "CustomKeywordField", String.class);
            logger.info(String.format("In workflow we get CustomKeywordField is: %s", value));
        } catch (Exception e) {
            logger.error(e.getMessage());
            e.printStackTrace();
        }

        System.exit(0);
    }

    // private methods

    private static Map<String, Object> generateSearchAttributes() {
        Map<String, Object> searchAttributes = new HashMap<>();
        searchAttributes.put("CustomKeywordField", "old world"); // each field can also be array such as: String[] keys = {"k1", "k2"};
        searchAttributes.put("CustomIntField", 1);
        searchAttributes.put("CustomDoubleField", 0.1);
        searchAttributes.put("CustomBoolField", true);
        searchAttributes.put("CustomDatetimeField", generateDateTimeFieldValue());
        searchAttributes.put("CustomStringField",
                "String field is for text. When query, it will be tokenized for partial match. StringTypeField cannot be used in Order By");
        return searchAttributes;
    }

    // CustomDatetimeField takes string like "2018-07-14T17:45:55.9483536" or
    // "2019-01-01T00:00:00-08:00" as value
    private static String generateDateTimeFieldValue() {
        ZonedDateTime currentDateTime = ZonedDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ISO_OFFSET_DATE_TIME;
        return currentDateTime.format(formatter);
    }
}