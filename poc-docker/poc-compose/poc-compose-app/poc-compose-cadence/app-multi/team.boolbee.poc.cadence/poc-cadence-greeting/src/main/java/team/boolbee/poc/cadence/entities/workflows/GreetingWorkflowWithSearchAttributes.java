package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.SearchAttributes;
import com.uber.cadence.workflow.Workflow;
import com.uber.cadence.workflow.WorkflowUtils;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.activities.IGreetingActivities;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

import java.util.HashMap;
import java.util.Map;

public class GreetingWorkflowWithSearchAttributes implements IGreetingWorkflow {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowStarter.class);

    private final IGreetingActivities activities =
            Workflow.newActivityStub(IGreetingActivities.class);

    @Override
    public String getGreeting(String name) {
        logger.info("Search Attributes on start: ");
        printSearchAttributes(Workflow.getWorkflowInfo().getSearchAttributes());

        // update some of the search attributes
        Map<String, Object> upsertedMap = new HashMap<>();
        upsertedMap.put("CustomKeywordField", name);
        Workflow.upsertSearchAttributes(upsertedMap);

        logger.info("Search Attributes after upsert: ");
        printSearchAttributes(Workflow.getWorkflowInfo().getSearchAttributes());

        // This is a blocking call that returns only after the activity has completed.
        return activities.composeGreeting("Hello", name);
    }

    // private methods

    private void printSearchAttributes(SearchAttributes searchAttributes) {
        if (searchAttributes == null) {
            return;
        }

        searchAttributes.getIndexedFields().forEach((k, v) -> {
            logger.info(String.format("%s: %s", k, getValueForKey(k, searchAttributes)));
        });
    }

    private String getValueForKey(String key, SearchAttributes searchAttributes) {
        switch (key) {
            case "CustomKeywordField":
            case "CustomDatetimeField":
            case "CustomStringField":
                return WorkflowUtils.getValueFromSearchAttributes(searchAttributes, key, String.class);
            case "CustomIntField":
                return WorkflowUtils.getValueFromSearchAttributes(searchAttributes, key, Integer.class)
                        .toString();
            case "CustomDoubleField":
                return WorkflowUtils.getValueFromSearchAttributes(searchAttributes, key, Double.class)
                        .toString();
            case "CustomBoolField":
                return WorkflowUtils.getValueFromSearchAttributes(searchAttributes, key, Boolean.class)
                        .toString();
        }

        return "Unknown key";
    }
}